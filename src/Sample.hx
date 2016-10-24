package;

import lime.math.Vector2;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.Lib;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.VoronoiMap;
using Vector2Extender;
using CenterExtender;
/**
 * ...
 * @author damrem
 */
class Sample extends Sprite
{

	var cellBySprite:Map<Sprite, Center>;
	var spriteByCell:Map<Center, Sprite>;
	
	public function new() 
	{
		super();
		
		cellBySprite = new Map<Sprite, Center>();
		spriteByCell = new Map<Center, Sprite>();
		
		var stg = Lib.current.stage;
		
		var map = new VoronoiMap( { width:stg.stageWidth, height:stg.stageWidth} );
		//map.go0PlacePoints(10);
		for (i in 0...100)
		{
			map.points.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		map.go1ImprovePoints(8);
		map.go2BuildGraph();
		
		
		map.centers = map.centers.filter(function(center:Center)
		{
			return center.getNeighbors().length == center.corners.length;
		});
		
		
		var zoneCanvas = createCells(map.centers);
		zoneCanvas.alpha = 0.1;
		
		
		/*var centerCanvas = drawPoints(map.centers.map(function(center)
		{
			return center.point;
		}));*/

		zoneCanvas.scaleY = /*centerCanvas.scaleY = */stg.stageHeight / stg.stageWidth;

		addChild(zoneCanvas);
		//addChild(centerCanvas);
		
		zoneCanvas.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		zoneCanvas.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		
	}
	
	private function onMouseOut(e:MouseEvent):Void 
	{
		var center = cast(cellBySprite.get(e.target), Center);
		for (neighbor in center.getNeighbors())
		{
			var neighborSprite = spriteByCell.get(neighbor);
			if (neighborSprite != null)
			{
				spriteByCell.get(neighbor).transform.colorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0);
			}
		}
	}
	
	private function onMouseOver(e:MouseEvent):Void 
	{
		var center = cast(cellBySprite.get(e.target), Center);
		trace(center.borders.length, center.getNeighbors().length, center.corners.length);
		for (neighbor in center.getNeighbors())
		{
			var neighborSprite = spriteByCell.get(neighbor);
			if (neighborSprite != null)
			{
				neighborSprite.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 128, 128, 128);
			}
		}
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
	
	function createCells(centers:Array<Center>):Sprite
	{
		var sprite = new Sprite();
		for (center in centers)
		{
			var cellView = createCellView(center);
			sprite.addChild(cellView);
			cellBySprite.set(cellView, center); 
			spriteByCell.set(center, cellView);
		}
		return sprite;
	}
	
	function createCellView(center:Center):Sprite
	{
		var sprite = new Sprite();
		var graphics = sprite.graphics;
		//trace(center.borders.length, center.getNeighbors().length);
		
		graphics.beginFill(Std.random(0xffffff));
		var corners = center.corners.copy();
		corners.sort(function(cornerA:Corner, cornerB:Corner)
		{
			var va = new Vector2(cornerA.point.x - center.point.x, cornerA.point.y - center.point.y);
			var vb = new Vector2(cornerB.point.x - center.point.x, cornerB.point.y - center.point.y);
			return Std.int(va.getAngle()*100 - vb.getAngle()*100);
		});
		var lastCorner = corners[corners.length - 1];
		graphics.moveTo(lastCorner.point.x, lastCorner.point.y);
		for (corner in corners)
		{
			graphics.lineTo(corner.point.x, corner.point.y);
		}
		graphics.endFill();
		return sprite;
	}
	
	
}