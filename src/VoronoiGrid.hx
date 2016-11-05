package;
using co.janicek.core.NullCore;
import com.nodename.delaunay.Voronoi;
import com.nodename.geom.LineSegment;
import de.polygonal.math.PM_PRNG;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
import voronoimap.IHasCenter;
import voronoimap.Size;

using Lambda;
using com.nodename.delaunay.BoolExtender;

class VoronoiGrid<T:(IHasCenter<T>)> {

	public static inline var DEFAULT_LLOYD_ITERATIONS = 2;
	public static inline var DEFAULT_NUMBER_OF_POINTS = 1000;
	
    /**
     * Passed in by the caller:
     */
    public var SIZE:Size;
	
	/**
	 * Island details are controlled by this random generator. The
	 * initial map upon loading is always deterministic, but
	 * subsequent maps reset this random number generator with a
	 * random seed.
	 */
    public var mapRandom:PM_PRNG;
	
    
    
	/**
	 * Only useful during map construction
	 */
    public var points:Array<Point>;
    public var centers:Array<Center<T>>;
    public var corners:Array<Corner<T>>;
    public var edges:Array<Edge<T>>;
	static public inline var DEFAULT_ELEVATION_FACTOR:Float = 50;

	/**
	 * Make a new map.
	 * @param	size width and height of map
	 * @param	riverChance 0 = no rivers, > 0 = more rivers, default = map area / 4
	 */
	public function new( size : Size)
	{
		SIZE = size;
		reset();
	}
	
	/**
	 * Generate the initial random set of points.
	 */
	public function go0PlacePoints( numberOfPoints = DEFAULT_NUMBER_OF_POINTS ) : Void {
		reset();
		points = generateRandomPoints(numberOfPoints);
	}
	
	public function go1ImprovePoints( numLloydIterations = DEFAULT_LLOYD_ITERATIONS ) : Void {
		improveRandomPoints(points, numLloydIterations);
	}
	
	/**
	 * Create a graph structure from the Voronoi edge list. The
     * methods in the Voronoi object are somewhat inconvenient for
     * my needs, so I transform that data into the data I actually
     * need: edges connected to the Delaunay triangles and the
     * Voronoi polygons, a reverse map from those four points back
     * to the edge, a map from these four points to the points
     * they connect to (both along the edge and crosswise).
	 */
	public function go2BuildGraph(dataConstructor:Center<T>->T) : Void {
	   var voronoi:Voronoi = new Voronoi(points, null, new Rectangle(0, 0, SIZE.width, SIZE.height));
	   buildGraph(points, voronoi, dataConstructor);
	   improveCorners();
	   voronoi.dispose();
	   voronoi = null;
	   points = null;
	}
	
	public function reset():Void {
		var p:Center<T>, q:Corner<T>, edge:Edge<T>;

		// Break cycles so the garbage collector will release data.
		if (points != null) {
			points.splice(0, points.length);
		}
		if (edges != null) {
			for (edge in edges) {
				edge.d0 = edge.d1 = null;
				edge.v0 = edge.v1 = null;
			}
			edges.splice(0, edges.length);
		}
		if (centers != null) {
			for (p in centers) {
				p.neighbors.splice(0, p.neighbors.length);
				p.corners.splice(0, p.corners.length);
				p.edges.splice(0, p.edges.length);
			}
			centers.splice(0, centers.length);
		}
		if (corners != null) {
			for (q in corners) {
				q.adjacent.splice(0, q.adjacent.length);
				q.touches.splice(0, q.touches.length);
				q.protrudes.splice(0, q.protrudes.length);
				q.downslope = null;
				q.watershed = null;
			}
			corners.splice(0, corners.length);
		}
		// Clear the previous graph data.
		if (points == null) points = new Array<Point>();
		if (edges == null) edges = new Array<Edge<T>>();
		if (centers == null) centers = new Array<Center<T>>();
		if (corners == null) corners = new Array<Corner<T>>();
	}

	/**
	 * Generate random points and assign them to be on the island or
	 * in the water. Some water points are inland lakes; others are
	 * ocean. Well determine ocean later by looking at whats
	 * connected to ocean.
	 */
    public function generateRandomPoints( NUM_POINTS : Int ) : Array<Point> {
		var p:Point, i:Int, points:Array<Point> = new Array<Point>();
		for (i in 0...NUM_POINTS) {
			p = new Point(mapRandom.nextDoubleRange(10, SIZE.width-10),
			mapRandom.nextDoubleRange(10, SIZE.height-10));
			points.push(p);
		}
		return points;
	}
	
    /**
     * Improve the random set of points with Lloyd Relaxation.
     */
    public function improveRandomPoints( points : Array<Point>, numLloydIterations : Int ) : Void {
      // Wed really like to generate "blue noise". Algorithms:
      // 1. Poisson dart throwing: check each new point against all
      //     existing points, and reject it if its too close.
      // 2. Start with a hexagonal grid and randomly perturb points.
      // 3. Lloyd Relaxation: move each point to the centroid of the
      //     generated Voronoi polygon, then generate Voronoi again.
      // 4. Use force-based layout algorithms to push points away.
      // 5. More at http://www.cs.virginia.edu/~gfx/pubs/antimony/
      // Option 3 is implemented here. If its run for too many iterations,
      // it will turn into a grid, but convergence is very slow, and we only
      // run it a few times.
		var i:Int, p:Point, q:Point, voronoi:Voronoi, region:Array<Point>;
		for (i in 0...numLloydIterations) {
			voronoi = new Voronoi(points, null, new Rectangle(0, 0, SIZE.width, SIZE.height));
			for (p in points) {
				region = voronoi.region(p);
				p.x = 0.0;
				p.y = 0.0;
				for (q in region) {
					p.x += q.x;
					p.y += q.y;
				}
				p.x /= region.length;
				p.y /= region.length;
				region.splice(0, region.length);
			}
			voronoi.dispose();
		}
	}

	/**
	 * Although Lloyd relaxation improves the uniformity of polygon
	 * sizes, it doesnt help with the edge lengths. Short edges can
	 * be bad for some games, and lead to weird artifacts on
	 * rivers. We can easily lengthen short edges by moving the
	 * corners, but **we lose the Voronoi property**.  The corners are
	 * moved to the average of the polygon centers around them. Short
	 * edges become longer. Long edges tend to become shorter. The
	 * polygons tend to be more uniform after this step.
	 */
    public function improveCorners():Void {
		var newCorners:Array<Point> = new Array<Point>();
		var q:Corner<T>, r:Center<T>, point:Point, i:Int, edge:Edge<T>;

		// First we compute the average of the centers next to each corner.
		for (q in corners) {
			if (q.border) {
				newCorners[q.index] = q.point;
			} else {
				point = new Point();
				for (r in q.touches) {
					point.x += r.point.x;
					point.y += r.point.y;
				}
				point.x /= q.touches.length;
				point.y /= q.touches.length;
				newCorners[q.index] = point;
			}
		}

		// Move the corners to the new locations.
		for (i in 0...corners.length) {
			corners[i].point = newCorners[i];
		}
	}

	/**
	 * Build graph data structure in edges, centers, corners,
	 * based on information in the Voronoi results: point.neighbors
	 * will be a list of neighboring points of the same type (corner
	 * or center); point.edges will be a list of edges that include
	 * that point. Each edge connects to four points: the Voronoi edge
	 * edge.{v0,v1} and its dual Delaunay triangle edge edge.{d0,d1}.
	 * For boundary polygons, the Delaunay edge will have one null
	 * point, and the Voronoi edge may be null.
	 */
    public function buildGraph(points:Array<Point>, voronoi:Voronoi, dataConstructor:Center<T> -> T):Void {
      var p:Center<T>, q:Corner<T>, point:Point, other:Point;
      var libedges:Array<com.nodename.delaunay.Edge> = voronoi.edges();
      var centerLookup:Map<String, Center<T>> = new Map<String, Center<T>>();

      // Build Center objects for each of the points, and a lookup map
      // to find those Center objects again as we build the graph
      for (point in points) {
          p = new Center<T>();//FIXME
		  p.data = dataConstructor(p);
		  p.data.center = p;
          p.index = centers.length;
          p.point = point;
          p.neighbors = new  Array<Center<T>>();
          p.edges = new Array<Edge<T>>();
          p.corners = new Array<Corner<T>>();
          centers.push(p);
          centerLookup.set(point.toString(), p);
        }
      
      // Workaround for Voronoi lib bug: we need to call region()
      // before Edges or neighboringSites are available
      for (p in centers) {
          voronoi.region(p.point);
        }
      
      // The Voronoi library generates multiple Point objects for
      // corners, and we need to canonicalize to one Corner object.
      // To make lookup fast, we keep an array of Points, bucketed by
      // x value, and then we only have to look at other Points in
      // nearby buckets. When we fail to find one, well create a new
      // Corner object.
      var _cornerMap:Array<Array<Corner<T>>> = [];
      function makeCorner(point:Point):Corner<T> {
        var q:Corner<T>;
        
        if (point == null) return null;
		var bucket:Int;
		for (bucket in Std.int(point.x) - 1...Std.int(point.x) + 2) {
			if (_cornerMap[bucket] != null) {
				for (q in _cornerMap[bucket]) {
				  var dx:Float = point.x - q.point.x;
				  var dy:Float = point.y - q.point.y;
				  if (dx * dx + dy * dy < 1e-6) {
					return q;
				  }
				}
			}
        }
        bucket = Std.int(point.x);
        if (_cornerMap[bucket] == null) _cornerMap[bucket] = [];
        q = new Corner<T>(/*elevationFactor*/);
        q.index = corners.length;
        corners.push(q);
        q.point = point;
        q.border = (point.x == 0 || point.x == SIZE.width
                    || point.y == 0 || point.y == SIZE.height);
        q.touches = new Array<Center<T>>();
        q.protrudes = new Array<Edge<T>>();
        q.adjacent = new Array<Corner<T>>();
        _cornerMap[bucket].push(q);
        return q;
      }
    
      for (libedge in libedges) {
          var dedge:LineSegment = libedge.delaunayLine();
          var vedge:LineSegment = libedge.voronoiEdge();

          // Fill the graph data. Make an Edge object corresponding to
          // the edge from the voronoi library.
          var edge:Edge<T> = new Edge<T>();
          edge.index = edges.length;
          edge.river = 0;
          edges.push(edge);
		  
          // Edges point to corners. Edges point to centers. 
          edge.v0 = makeCorner(vedge.p0);
          edge.v1 = makeCorner(vedge.p1);
          edge.d0 = centerLookup.get(dedge.p0.toString());
          edge.d1 = centerLookup.get(dedge.p1.toString());

          // Centers point to edges. Corners point to edges.
          if (edge.d0 != null) { edge.d0.edges.push(edge); }
          if (edge.d1 != null) { edge.d1.edges.push(edge); }
          if (edge.v0 != null) { edge.v0.protrudes.push(edge); }
          if (edge.v1 != null) { edge.v1.protrudes.push(edge); }

          function addToCornerList(v:Array<Corner<T>>, x:Corner<T>):Void {
            if (x != null && v.indexOf(x) < 0) { v.push(x);}
          }
          function addToCenterList(v:Array<Center<T>>, x:Center<T>):Void {
            if (x != null && v.indexOf(x) < 0) { v.push(x); }
          }
          
          // Centers point to centers.
          if (edge.d0 != null && edge.d1 != null) {
            addToCenterList(edge.d0.neighbors, edge.d1);
            addToCenterList(edge.d1.neighbors, edge.d0);
          }

          // Corners point to corners
          if (edge.v0 != null && edge.v1 != null) {
            addToCornerList(edge.v0.adjacent, edge.v1);
            addToCornerList(edge.v1.adjacent, edge.v0);
          }

          // Centers point to corners
          if (edge.d0 != null) {
            addToCornerList(edge.d0.corners, edge.v0);
            addToCornerList(edge.d0.corners, edge.v1);
          }
          if (edge.d1 != null) {
            addToCornerList(edge.d1.corners, edge.v0);
            addToCornerList(edge.d1.corners, edge.v1);
          }

          // Corners point to centers
          if (edge.v0 != null) {
            addToCenterList(edge.v0.touches, edge.d0);
            addToCenterList(edge.v0.touches, edge.d1);
          }
          if (edge.v1 != null) {
            addToCenterList(edge.v1.touches, edge.d0);
            addToCenterList(edge.v1.touches, edge.d1);
          }
        }
    }

	/**
	 * Look up a Voronoi Edge object given two adjacent Voronoi
	 * polygons, or two adjacent Voronoi corners
	 */
    public function lookupEdgeFromCenter(p:Center<T>, r:Center<T>):Edge<T> {
      for (edge in p.edges) {
          if (edge.d0 == r || edge.d1 == r) return edge;
        }
      return null;
    }

    public function lookupEdgeFromCorner(q:Corner<T>, s:Corner<T>):Edge<T> {
      for (edge in q.protrudes) {
          if (edge.v0 == s || edge.v1 == s) return edge;
        }
      return null;
    }
	
}