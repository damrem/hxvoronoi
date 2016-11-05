package voronoimap.graph;
import openfl.geom.Point;

class Corner<T> extends AbstractGraphPoint
{
    public var touches:Array<Center<T>>;
    public var protrudes:Array<Edge<T>>;
    public var adjacent:Array<Corner<T>>;
  
    public var river:Int;  // 0 if no river, or volume of water in river
    public var downslope:Corner<T>;  // pointer to adjacent corner most downhill
    public var watershed:Corner<T>;  // pointer to coastal corner, or null
    public var watershed_size:Int;
	
	public function new(/*elevationFactor:Float*/) {
		super(/*elevationFactor*/);
		
	}
}