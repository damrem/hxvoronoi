package;

import lime.math.Vector2;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Point;
import openfl.Lib;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.VoronoiMap;
using Vector2Extender;
/**
 * ...
 * @author damrem
 */
class Sample extends Sprite
{

	public function new() 
	{
		super();
		
		var stg = Lib.current.stage;
		
		var map = new VoronoiMap( { width:stg.stageWidth, height:stg.stageWidth} );
		//map.go0PlacePoints(10);
		for (i in 0...100)
		{
			map.points.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		map.go1ImprovePoints(8);
		map.go2BuildGraph();
		
		var zoneCanvas = drawZones(map.centers);
		
		var centerCanvas = drawPoints(map.centers.map(function(center)
		{
			return center.point;
		}));

		zoneCanvas.scaleY = centerCanvas.scaleY = stg.stageHeight / stg.stageWidth;

		addChild(zoneCanvas);
		addChild(centerCanvas);
		
		
		var v2 = new Vector2(1, 1);
	}
	
	function drawPoints(points:Array<Point>):Shape
	{
		var canvas = new Shape();
		canvas.graphics.beginFill(0xffffff);
		for (p in points)
		{
			canvas.graphics.drawCircle(p.x, p.y, 1);
		}
		canvas.graphics.endFill();
		return canvas;
	}
	
	function drawZones(centers:Array<Center>):Shape
	{
		var canvas = new Shape();
		for (center in centers)
		{
			canvas.graphics.beginFill(Std.random(0xffffff));
			var corners = center.corners.copy();
			corners.sort(function(cornerA:Corner, cornerB:Corner)
			{
				var va = new Vector2(cornerA.point.x - center.point.x, cornerA.point.y - center.point.y);
				var vb = new Vector2(cornerB.point.x - center.point.x, cornerB.point.y - center.point.y);
				return Std.int(va.getAngle()*100 - vb.getAngle()*100);
			});
			var lastCorner = corners[corners.length - 1];
			canvas.graphics.moveTo(lastCorner.point.x, lastCorner.point.y);
			for (corner in corners)
			{
				canvas.graphics.lineTo(corner.point.x, corner.point.y);
			}
			canvas.graphics.endFill();
		}
		return canvas;
	}
	
	
	
}