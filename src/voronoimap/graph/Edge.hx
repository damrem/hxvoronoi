package voronoimap.graph;
import openfl.geom.Point;

class Edge<T:IHasCenter<T>> extends AbstractGraphItem
{
    public var d0:Center<T>; public var d1:Center<T>;  // Delaunay edge
    public var v0:Corner<T>; public var v1:Corner<T>;  // Voronoi edge
    public var midpoint(get, null):Point;  // halfway between v0,v1
    public var river:Int;  // volume of water, or 0
	
	public function new() {
		
	}
	
	function get_midpoint():Point
	{
		return (v0 != null && v1 != null) ? Point.interpolate(v0.point, v1.point, 0.5) : null;
	}
}