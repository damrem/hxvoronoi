package voronoimap.graph;
import openfl.geom.Point;

class Corner<T> {
	public function new() { }
	
    public var index:Int;
  
    public var point:Point;  // location
    public var ocean:Bool;  // ocean
    public var water:Bool;  // lake or ocean
    public var coast:Bool;  // touches ocean and land polygons
    public var border:Bool;  // at the edge of the map
    public var elevation:Float;  // 0.0-1.0
    public var moisture:Float;  // 0.0-1.0

    public var touches:Array<Center<T>>;
    public var protrudes:Array<Edge<T>>;
    public var adjacent:Array<Corner<T>>;
  
    public var river:Int;  // 0 if no river, or volume of water in river
    public var downslope:Corner<T>;  // pointer to adjacent corner most downhill
    public var watershed:Corner<T>;  // pointer to coastal corner, or null
    public var watershed_size:Int;
}