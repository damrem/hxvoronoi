package hxlpers.geom;
import hxlpers.geom.Polygon;
import openfl.geom.Point;

/**
 * ...
 * @author damrem
 */
class PolygonExtender
{

	static public function getCentroid(points:Polygon):Point
	{
		var c = new Point();
		for (p in points)
		{
			c = c.add(p);
		}
		c.normalize(c.length / points.length);
		return c;
	}
	
}