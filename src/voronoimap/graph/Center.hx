package voronoimap.graph;
import openfl.geom.Point;

class Center<T> extends AbstractGraphPoint
{
    public var biome:Biome;  // biome type (see article)
    
    public var data:T;
    public var neighbors:Array<Center<T>>;
    public var edges:Array<Edge<T>>;
    public var corners:Array<Corner<T>>;
	
	public function new(elevationFactor:Float) {
		super(elevationFactor);
	}
}