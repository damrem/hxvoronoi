package voronoimap.graph;
import openfl.geom.Point;

class Center<T> {
	public function new() { }
	
    public var index:Int;
  
    public var point:Point;  // location
    public var water:Bool;  // lake or ocean
    public var ocean:Bool;  // ocean
    public var coast:Bool;  // land polygon touching an ocean
    public var border:Bool;  // at the edge of the map
    public var biome:Biome;  // biome type (see article)
    public var elevation:Float;  // 0.0-1.0
    public var moisture:Float;  // 0.0-1.0

	public var data:T;
    public var neighbors:Array<Center<T>>;
    public var borders:Array<Edge<T>>;
    public var corners:Array<Corner<T>>;
	
	public var elevatedPoint(get, null):Point;
	inline function get_elevatedPoint():Point
	{
		return new Point(point.x, point.y - elevation * CellView.ELEVATION_FACTOR);
	}
}