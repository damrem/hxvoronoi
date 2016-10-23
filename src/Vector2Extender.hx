package;
import lime.math.Vector2;
import openfl.geom.Point;

/**
 * ...
 * @author damrem
 */
class Vector2Extender
{

	static public function fromPoint(v2:Vector2, p:Point)
	{
		v2.x = p.x;
		v2.y = p.y;
	}
	
	static public function getAngle(v2:Vector2):Float
	{
		return Math.atan2(v2.y, v2.x);
	}
	
}