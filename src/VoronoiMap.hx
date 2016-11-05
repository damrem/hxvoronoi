package;
using co.janicek.core.NullCore;
import com.nodename.delaunay.Voronoi;
import com.nodename.geom.LineSegment;
import de.polygonal.math.PM_PRNG;
import haxe.Timer;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import voronoimap.Biome;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
import voronoimap.Size;

using Lambda;
using com.nodename.delaunay.BoolExtender;

class VoronoiMap<T> extends VoronoiGrid<T>{
	var elevationFactor:Float;

	public static inline var DEFAULT_LAKE_THRESHOLD = 0.3;
	
	/**
	 * Island shape is controlled by the islandRandom seed and the
	 * type of island, passed in when we set the island shape. The
	 * islandShape function uses both of them to determine whether any
	 * point should be water or land.
	 */
    public var islandShape:Point->Bool;

	static public inline var DEFAULT_ELEVATION_FACTOR:Float = 50;

	/**
	 * Make a new map.
	 * @param	size width and height of map
	 * @param	riverChance 0 = no rivers, > 0 = more rivers, default = map area / 4
	 */
	public function new( size : Size, elevationFactor:Float = DEFAULT_ELEVATION_FACTOR)
	{
		super(size);
		this.elevationFactor = elevationFactor;
		mapRandom = new PM_PRNG();
		SIZE = size;
		reset();
	}
	
    /**
     * Random parameters governing the overall shape of the island
     */
    public function newIsland(islandShape:Point->Bool, variant:Int):Void {
		this.islandShape = islandShape;
		mapRandom.seed = variant;
    }
    
	/**
	 * 
	 * @param	lakeThreshold 0 to 1, fraction of water corners for water polygon, default = 0.3
	 */
	public function go3AssignElevations( lakeThreshold = DEFAULT_LAKE_THRESHOLD ) : Void {
		// Determine the elevations and water at Voronoi corners.
		assignCornerElevations();

		// Determine polygon and corner type: ocean, coast, land.
		assignOceanCoastAndLand(lakeThreshold);
		
		// Rescale elevations so that the highest is 1.0, and theyre
		// distributed well. We want lower elevations to be more common
		// than higher elevations, in proportions approximately matching
		// concentric rings. That is, the lowest elevation is the
		// largest ring around the island, and therefore should more
		// land area than the highest elevation, which is the very
		// center of a perfectly circular island.
		redistributeElevations(landCorners(corners));

		// Assign elevations to non-land corners
		for (q in corners) {
			if (q.ocean || q.coast) {
				q.elevation = 0.0;
			}
		}

		// Polygon elevations are the average of their corners
		assignPolygonElevations();
	}
	
	public function go4AssignMoisture( riverChance : Null<Int> = null ) : Void {
		// Determine downslope paths.
		calculateDownslopes();

		// Determine watersheds: for every Corner<T>, where does it flow
		// out into the ocean? 
		calculateWatersheds();

		// Create rivers.
		createRivers(riverChance);

		// Determine moisture at corners, starting at rivers
		// and lakes, but not oceans. Then redistribute
		// moisture to cover the entire range evenly from 0.0
		// to 1.0. Then assign polygon moisture as the average
		// of the corner moisture.
		assignCornerMoisture();
		redistributeMoisture(landCorners(corners));
		assignPolygonMoisture();		
	}
	
	public function go5DecorateMap() : Void {
		assignBiomes();
	}
	
	/**
	 * Create an array of corners that are on land only, for use by
	 * algorithms that work only on land.  We return an array instead
	 * of a vector because the redistribution algorithms want to sort
	 * this array using Array.sortOn.
	 */
    public function landCorners(corners:Array<Corner<T>>):Array<Corner<T>> {
		var q:Corner<T>, locations:Array<Corner<T>> = [];
		for (q in corners) {
			if (!q.ocean && !q.coast) {
				locations.push(q);
			}
		}
		return locations;
	}

	/**
	 * Determine elevations and water at Voronoi corners. By
	 * construction, we have no local minima. This is important for
	 * the downslope vectors later, which are used in the river
	 * construction algorithm. Also by construction, inlets/bays
	 * push low elevation areas inland, which means many rivers end
	 * up flowing out through them. Also by construction, lakes
	 * often end up on river paths because they dont raise the
	 * elevation as much as other terrain does.
	 */
    public function assignCornerElevations():Void {
      var q:Corner<T>, s:Corner<T>;
      var queue:Array<Corner<T>> = [];
      
      for (q in corners) {
          q.water = !inside(q.point);
        }

      for (q in corners) {
          // The edges of the map are elevation 0
          if (q.border) {
            q.elevation = 0.0;
            queue.push(q);
          } else {
            q.elevation = Math.POSITIVE_INFINITY;
          }
        }
      // Traverse the graph and assign elevations to each point. As we
      // move away from the map border, increase the elevations. This
      // guarantees that rivers always have a way down to the coast by
      // going downhill (no local minima).
      while (queue.length > 0) {
        q = queue.shift();

        for (s in q.adjacent) {
            // Every step up is epsilon over water or 1 over land. The
            // number doesnt matter because well rescale the
            // elevations later.
            var newElevation:Float = 0.01 + q.elevation;
            if (!q.water && !s.water) {
              newElevation += 1;
            }
            // If this point changed, well add it to the queue so
            // that we can process its neighbors too.
            if (newElevation < s.elevation) {
              s.elevation = newElevation;
              queue.push(s);
            }
          }
      }
    }
	
	/**
	 * Change the overall distribution of elevations so that lower
	 * elevations are more common than higher
	 * elevations. Specifically, we want elevation X to have frequency
	 * (1-X).  To do this we will sort the corners, then set each
	 * corner to its desired elevation.
	 */
    public function redistributeElevations(locations:Array<Corner<T>>):Void {
      // SCALE_FACTOR increases the mountain area. At 1.0 the maximum
      // elevation barely shows up on the map, so we set it to 1.1.
      var SCALE_FACTOR:Float = 1.1;
      var i:Int, y:Float, x:Float;

	  //Haxe port
      //locations.sortOn(elevation, Array.NUMERIC);
	  locations.sort(function(c1, c2) {
		  if (c1.elevation > c2.elevation) return 1;
		  if (c1.elevation < c2.elevation) return -1;
 		  if (c1.index > c2.index) return 1;
		  if (c1.index < c2.index) return -1;
		  return 0;
	  } );
	  
      for (i in 0...locations.length) {
        // Let y(x) be the total area that we want at elevation <= x.
        // We want the higher elevations to occur less than lower
        // ones, and set the area to be y(x) = 1 - (1-x)^2.
        y = i/(locations.length-1);
        // Now we have to solve for x, given the known y.
        //  *  y = 1 - (1-x)^2
        //  *  y = 1 - (1 - 2x + x^2)
        //  *  y = 2x - x^2
        //  *  x^2 - 2x + y = 0
        // From this we can use the quadratic equation to get:
        x = Math.sqrt(SCALE_FACTOR) - Math.sqrt(SCALE_FACTOR * (1 - y));
        if (x > 1.0) x = 1.0;  // TODO: does this break downslopes?
        locations[i].elevation = x;
      }
    }	
	
    /**
     * Change the overall distribution of moisture to be evenly distributed.
     */
    public function redistributeMoisture(locations:Array<Corner<T>>):Void {
		var i:Int;
      
		locations.sort(function(c1, c2) {
			if (c1.moisture > c2.moisture) return 1;
			if (c1.moisture < c2.moisture) return -1;
			if (c1.index > c2.index) return 1;
			if (c1.index < c2.index) return -1;
			return 0;
		} );
	  
		for (i in 0...locations.length) {
			locations[i].moisture = i / (locations.length - 1);
		}
	}
	
    /**
     * Determine polygon and corner types: ocean, coast, land.
     */
    public function assignOceanCoastAndLand( lakeThreshold : Float ):Void {
      // Compute polygon attributes ocean and water based on the
      // corner attributes. Count the water corners per
      // polygon. Oceans are all polygons connected to the edge of the
      // map. In the first pass, mark the edges of the map as ocean;
      // in the second pass, mark any water-containing polygon
      // connected an ocean as ocean.
      var queue:Array<Center<T>> = [];
      var p:Center<T>, q:Corner<T>, r:Center<T>, numWater:Int;
      
      for (p in centers) {
          numWater = 0;
          for (q in p.corners) {
              if (q.border) {
                p.border = true;
                p.ocean = true;
                q.water = true;
                queue.push(p);
              }
              if (q.water) {
                numWater += 1;
              }
            }
          p.water = (p.ocean || numWater >= p.corners.length * lakeThreshold);
        }
      while (queue.length > 0) {
        p = queue.shift();
        for (r in p.neighbors) {
            if (r.water && !r.ocean) {
              r.ocean = true;
              queue.push(r);
            }
          }
      }
      
      // Set the polygon attribute coast based on its neighbors. If
      // it has at least one ocean and at least one land neighbor,
      // then this is a coastal polygon.
      for (p in centers) {
          var numOcean:Int = 0;
          var numLand:Int = 0;
          for (r in p.neighbors) {
              numOcean += r.ocean.intFromBoolean();
              numLand += (!r.water).intFromBoolean();
            }
          p.coast = (numOcean > 0) && (numLand > 0);
        }


      // Set the corner attributes based on the computed polygon
      // attributes. If all polygons connected to this corner are
      // ocean, then its ocean; if all are land, then its land;
      // otherwise its coast.
      for (q in corners) {
          var numOcean:Int = 0;
          var numLand:Int = 0;
          for (p in q.touches) {
              numOcean += p.ocean.intFromBoolean();
              numLand += (!p.water).intFromBoolean();
            }
          q.ocean = (numOcean == q.touches.length);
          q.coast = (numOcean > 0) && (numLand > 0);
          q.water = q.border || ((numLand != q.touches.length) && !q.coast);
        }
    }
	
    /**
     * Polygon elevations are the average of the elevations of their corners.
     */
    public function assignPolygonElevations():Void {
		var p:Center<T>, q:Corner<T>, sumElevation:Float;
		for (p in centers) {
			sumElevation = 0.0;
			for (q in p.corners) {
				sumElevation += q.elevation;
			}
			p.elevation = sumElevation / p.corners.length;
		}
	}

	/**
	 * Calculate downslope pointers.  At every point, we point to the
	 * point downstream from it, or to itself.  This is used for
	 * generating rivers and watersheds.
	 */
    public function calculateDownslopes():Void {
      var q:Corner<T>, s:Corner<T>, r:Corner<T>;
      
      for (q in corners) {
          r = q;
          for (s in q.adjacent) {
              if (s.elevation <= r.elevation) {
                r = s;
              }
            }
          q.downslope = r;
        }
    }

	/**
	 * Calculate the watershed of every land point. The watershed is
	 * the last downstream land point in the downslope graph. TODO:
	 * watersheds are currently calculated on corners, but itd be
	 * more useful to compute them on polygon centers so that every
	 * polygon can be marked as being in one watershed.
	 */
    public function calculateWatersheds():Void {
      var q:Corner<T>, r:Corner<T>, i:Int, changed:Bool;
      
      // Initially the watershed pointer points downslope one step.      
      for (q in corners) {
          q.watershed = q;
          if (!q.ocean && !q.coast) {
            q.watershed = q.downslope;
          }
        }
      // Follow the downslope pointers to the coast. Limit to 100
      // iterations although most of the time with NUM_POINTS=2000 it
      // only takes 20 iterations because most points are not far from
      // a coast.  TODO: can run faster by looking at
      // p.watershed.watershed instead of p.downslope.watershed.
      for (i in 0...100) {
        changed = false;
        for (q in corners) {
            if (!q.ocean && !q.coast && !q.watershed.coast) {
              r = q.downslope.watershed;
              if (!r.ocean) q.watershed = r;
              changed = true;
            }
          }
        if (!changed) break;
      }
      // How big is each watershed?
      for (q in corners) {
          r = q.watershed;
		  
		  //Haxe port
		  //r.watershed_size = 1 + (r.watershed_size || 0);
		  r.watershed_size = 1 + r.watershed_size;
        }
    }
	
	/**
	 * Create rivers along edges. Pick a random corner point,
	 * then move downslope. Mark the edges and corners as rivers.
	 * @param	riverChance Higher = more rivers.
	 */
    public function createRivers( riverChance : Null<Int> ) : Void {
		
		riverChance = riverChance.coalesce(Std.int((SIZE.width + SIZE.height) / 4));
		
		var i:Int, q:Corner<T>, edge:Edge<T>;
      
		for (i in 0...riverChance) {
			q = corners[mapRandom.nextIntRange(0, corners.length-1)];
			if (q==null || q.ocean || q.elevation < 0.3 || q.elevation > 0.9) continue;
			// Bias rivers to go west: if (q.downslope.x > q.x) continue;
			while (!q.coast) {
				if (q == q.downslope) {
					break;
				}
				edge = lookupEdgeFromCorner(q, q.downslope);
				edge.river = edge.river + 1;
	  
				//Haxe port
				//q.river = (q.river || 0) + 1;
				q.river = q.river + 1;
	  
				//Haxe port
				//q.downslope.river = (q.downslope.river || 0) + 1;  // TODO: fix double count
				q.downslope.river = q.downslope.river + 1;
	  
				q = q.downslope;
			}
		}
	}

	/**
	 * Calculate moisture. Freshwater sources spread moisture: rivers
	 * and lakes (not oceans). Saltwater sources have moisture but do
	 * not spread it (we set it at the end, after propagation).
	 */
    public function assignCornerMoisture():Void {
      var q:Corner<T>, r:Corner<T>, newMoisture:Float;
      var queue:Array<Corner<T>> = [];
      // Fresh water
      for (q in corners) {
          if ((q.water || q.river > 0) && !q.ocean) {
            q.moisture = q.river > 0? Math.min(3.0, (0.2 * q.river)) : 1.0;
            queue.push(q);
          } else {
            q.moisture = 0.0;
          }
        }
      while (queue.length > 0) {
        q = queue.shift();

        for (r in q.adjacent) {
            newMoisture = q.moisture * 0.9;
            if (newMoisture > r.moisture) {
              r.moisture = newMoisture;
              queue.push(r);
            }
          }
      }
      // Salt water
      for (q in corners) {
          if (q.ocean || q.coast) {
            q.moisture = 1.0;
          }
        }
    }
	
    /**
     * Polygon moisture is the average of the moisture at corners
     */
    public function assignPolygonMoisture():Void {
      var p:Center<T>, q:Corner<T>, sumMoisture:Float;
      for (p in centers) {
          sumMoisture = 0.0;
          for (q in p.corners) {
              if (q.moisture > 1.0) q.moisture = 1.0;
              sumMoisture += q.moisture;
            }
          p.moisture = sumMoisture / p.corners.length;
        }
    }

	/**
	 * Assign a biome type to each polygon. If it has
	 * ocean/coast/water, then thats the biome; otherwise it depends
	 * on low/high elevation and low/medium/high moisture. This is
	 * roughly based on the Whittaker diagram but adapted to fit the
	 * needs of the island map generator.
	 */
    static public function getBiome<T>(p:Center<T>):Biome {
      if (p.ocean) {
        return OCEAN;
      } else if (p.water) {
        if (p.elevation < 0.1) return MARSH;
        if (p.elevation > 0.8) return ICE;
        return LAKE;
      } else if (p.coast) {
        return BEACH;
      } else if (p.elevation > 0.8) {
        if (p.moisture > 0.50) return SNOW;
        else if (p.moisture > 0.33) return TUNDRA;
        else if (p.moisture > 0.16) return BARE;
        else return SCORCHED;
      } else if (p.elevation > 0.6) {
        if (p.moisture > 0.66) return TAIGA;
        else if (p.moisture > 0.33) return SHRUBLAND;
        else return TEMPERATE_DESERT;
      } else if (p.elevation > 0.3) {
        if (p.moisture > 0.83) return TEMPERATE_RAIN_FOREST;
        else if (p.moisture > 0.50) return TEMPERATE_DECIDUOUS_FOREST;
        else if (p.moisture > 0.16) return GRASSLAND;
        else return TEMPERATE_DESERT;
      } else {
        if (p.moisture > 0.66) return TROPICAL_RAIN_FOREST;
        else if (p.moisture > 0.33) return TROPICAL_SEASONAL_FOREST;
        else if (p.moisture > 0.16) return GRASSLAND;
        else return SUBTROPICAL_DESERT;
      }
    }
	
    public function assignBiomes():Void {
      var p:Center<T>;
      for (p in centers) {
          p.biome = getBiome(p);
        }
    }
	
	/**
     * Determine whether a given point should be on the island or in the water.
     */
    public function inside(p:Point):Bool {
      return islandShape( new Point(2 * (p.x / SIZE.width - 0.5), 2 * (p.y / SIZE.height - 0.5)));
    }
	
	// ------------------------------------------------------------------------
	// Extensions
	
	public static function countLands<T>( centers : Array<Center<T>> ) : Int {
		return centers.count(function(c) { return !c.water; } );
	}
	
	/**
	 * Rebuilds the map varying the number of points until desired number of land centers are generated or timeout is reached.
	 * Not an efficient algorithim, but gets the job done.
	 */
	public static function tryMutateMapPointsToGetNumberLands<T>( map : VoronoiMap<T>, numberOfLands : Int, timeoutSeconds = 10, initialNumberOfPoints = VoronoiGrid.DEFAULT_NUMBER_OF_POINTS, numLloydIterations = VoronoiGrid.DEFAULT_LLOYD_ITERATIONS, lakeThreshold = DEFAULT_LAKE_THRESHOLD ) : VoronoiMap<T> {
		var pointCount = initialNumberOfPoints;
		var startTime = Timer.stamp();
		var targetLandCountFound = false;
		do {
			map.go0PlacePoints(pointCount);
			map.go1ImprovePoints(numLloydIterations);
			map.go2BuildGraph();
			map.go3AssignElevations(lakeThreshold);
			var lands = countLands(map.centers);
			if (lands == numberOfLands)
				targetLandCountFound = true;
			else
				pointCount += (lands < numberOfLands ? 1 : -1);
		} while (!targetLandCountFound && Timer.stamp() - startTime < timeoutSeconds);
		
		return map;
	}
	
}