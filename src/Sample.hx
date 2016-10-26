package;

import hxlpers.colors.RndColor;
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
import voronoimap.graph.Edge;
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
		
		var innerCenters = map.centers.filter(function(center:Center)
		{
			return center.getNeighbors().length == center.corners.length;
		});
		
		for (center in map.centers)
		{
			if (center.borders.length != center.corners.length)
			{
				trace(center.borders.length, center.corners.length);
				for (border in center.borders)
				{
					trace(border.d0, border.d1, border.d0 == border.d1);
				}
			}
		}
		
		
		
		
		
		
		var zoneCanvas = createCellViews(innerCenters);
		zoneCanvas.name = "zoneCanvas";
		var edgeCanvas = createEdgeViews(map.edges);
		edgeCanvas.name = "edgeCanvas";
		
		zoneCanvas.alpha = 
		edgeCanvas.alpha = 
		0.1;
		//zoneCanvas.alpha = 0.1;
		
		
		/*var centerCanvas = drawPoints(map.centers.map(function(center)
		{
			return center.point;
		}));*/

		zoneCanvas.scaleY = 
		edgeCanvas.scaleY = 
		//centerCanvas.scaleY = 
		stg.stageHeight / stg.stageWidth;

		addChild(zoneCanvas);
		//addChild(edgeCanvas);
		//addChild(centerCanvas);
		
		zoneCanvas.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverOut);
		zoneCanvas.addEventListener(MouseEvent.MOUSE_OUT, onMouseOverOut);
		
	}
	
	private function onMouseOverOut(e:MouseEvent):Void 
	{
		var center = cellBySprite.get(e.target);
		for (neighbor in center.getNeighbors())
		{
			var neighborSprite = spriteByCell.get(neighbor);
			if (neighborSprite != null)
			{
				var colorOffset = e.type == MouseEvent.MOUSE_OVER ? 128 : 0;
				neighborSprite.transform.colorTransform = new ColorTransform(1, 1, 1, 1, colorOffset, colorOffset, colorOffset);
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
	
	function createCellViews(centers:Array<Center>):Sprite
	{
		var sprite = new Sprite();
		for (center in centers)
		{
			var cellView = new CellView(center);
			sprite.addChild(cellView.sprite);
			cellBySprite.set(cellView.sprite, center); 
			spriteByCell.set(center, cellView.sprite);
		}
		return sprite;
	}
	
	function createEdgeViews(edges:Array<Edge>):Sprite
	{
		var sprite = new Sprite();
		for (edge in edges)
		{
			createEdge(edge, sprite.graphics);
		}
		return sprite;
	}
	
	function createEdge(edge:Edge, graphics:Graphics)
	{
		if (edge.v0 != null && edge.v1 != null)
		{
			graphics.lineStyle(2, 0xff0000);
			graphics.moveTo(edge.v0.point.x, edge.v0.point.y);
			graphics.lineTo(edge.v1.point.x, edge.v1.point.y);
		}
	}
	
	
}