package voronoimap.graph;
import openfl.geom.Point;

/**
 * ...
 * @author damrem
 */
class AbstractGraphPoint extends AbstractGraphItem
{
	public var elevationFactor:Float;
	public var point:Point;  // location
	
	public var elevation:Float;  // 0.0-1.0
	
	public var elevatedPoint(get, null):Point;
	inline function get_elevatedPoint():Point
	{
		return new Point(point.x, point.y - elevation * elevationFactor);
	}
	
	public var water:Bool;  // lake or ocean
    public var ocean:Bool;  // ocean
    public var coast:Bool;  // land polygon touching an ocean
    public var border:Bool;  // at the edge of the map
    public var moisture:Float;  // 0.0-1.0

	public function new()
	{
		//this.elevationFactor = elevationFactor;
		
	}
	
}