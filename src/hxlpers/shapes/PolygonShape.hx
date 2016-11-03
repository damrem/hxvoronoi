package hxlpers.shapes;
import hxlpers.geom.Pt;
import hxlpers.geom.V2d;
import openfl.display.Shape;
import openfl.geom.Point;

/**
 * ...
 * @author damrem
 */
class PolygonShape extends Shape
{
	var vertices:Array<Point>;
	
	
	public function new(vertices:Array<Point>, ?center:Point) 
	{
		super();
		
		this.vertices = vertices;
		
		if (center == null)
		{
			center = Pt.centroid(vertices);
		}
		
		PolygonShape.orderPoints(vertices, center);
	}
	
	public function draw()
	{
		graphics.moveTo(vertices[0].x, vertices[0].y);
		for (i in 1...vertices.length)
		{
			graphics.lineTo(vertices[i].x, vertices[i].y);
		}
		graphics.lineTo(vertices[0].x, vertices[0].y);
	}
	
	public static function orderPoints(points:Array<Point>, center)
	{
		points.sort(
			function(p0:Point, p1:Point):Int
			{
				var a0 = V2d.fromPoints(p0, center).getAngle();
				var a1 = V2d.fromPoints(p1, center).getAngle();
				if (a0 > a1)
				{
					return 1;
				}
				else if (a1 > a0)
				{
					return -1;
				}
				return 0;
			}
		);
		
	
	}
	
}