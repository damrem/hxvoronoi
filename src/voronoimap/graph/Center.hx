package voronoimap.graph;
import openfl.geom.Point;
using Lambda;

class Center<T:(IHasCenter<T>)> extends AbstractGraphPoint
{
    public var data:T;
    public var neighbors:Array<Center<T>>;
    public var edges:Array<Edge<T>>;
    public var corners:Array<Corner<T>>;
	
	public function new() {
		super();
	}
	
	public function getActualNeighbors():Array<Center<T>>
	{
		return neighbors.filter(function(center:Center<T>):Bool
		{
			return corners.exists(function(corner:Corner<T>)
			{
				return center.corners.indexOf(corner) >= 0;
			});
		});
	}
}