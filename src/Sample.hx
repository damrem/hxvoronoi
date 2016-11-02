package;

import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.Lib;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
import voronoimap.IslandShape;
import voronoimap.VoronoiMap;
using hxlpers.lime.math.Vector2Extender;
using CenterExtender;
/**
 * ...
 * @author damrem
 */
class Sample extends Sprite
{

	var cellViewByCenter:Map<Center, CellView>;
	var cellViewBySpriteName:Map<String, CellView>;
	
	public function new() 
	{
		super();
		
		cellViewByCenter = new Map<Center, CellView>();
		cellViewBySpriteName = new Map<String, CellView>();
		
		var stg = Lib.current.stage;
		
		var map = new VoronoiMap( { width:stg.stageWidth, height:stg.stageHeight } );
		
		
		//map.go0PlacePoints(10);
		for (i in 0...500)
		{
			map.points.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		map.go1ImprovePoints(8);
		map.go2BuildGraph();
		
		map.islandShape = IslandShape.makeRadial(1);
		map.islandShape = IslandShape.makeBlob();
		map.islandShape = IslandShape.makeNoise(1);
		map.islandShape = IslandShape.makePerlin(1);
		map.go3AssignElevations();
		
		map.centers = map.centers.filter(function(center:Center)
		{
			//return true;
			return center.getNeighbors().length == center.corners.length;
		});
		
		/*map.centers = map.centers.filter(function(center:Center)
		{
			//return true;
			return center.getNeighbors().length == center.corners.length;
		});*/
		
		/*for (center in map.centers)
		{
			if (center.borders.length != center.corners.length)
			{
				trace(center.borders.length, center.corners.length);
				for (border in center.borders)
				{
					trace(border.d0, border.d1, border.d0 == border.d1);
				}
			}
		}*/
		
		
		
		
		
		
		var zoneCanvas = createCellViews(map.centers);
		zoneCanvas.name = "zoneCanvas";
		
		var edgeCanvas = createEdgeViews(map.edges);
		edgeCanvas.name = "edgeCanvas";
		
		var cornerCanvas = createCorners(map.corners);
		cornerCanvas.name = "cornerCanvas";
		
		//zoneCanvas.alpha = edgeCanvas.alpha = 0.25;
		//zoneCanvas.alpha = 0.1;
		
		
		/*var centerCanvas = drawPoints(map.centers.map(function(center)
		{
			return center.point;
		}));*/

		zoneCanvas.scaleY = 
		edgeCanvas.scaleY = 
		//centerCanvas.scaleY = 
		cornerCanvas.scaleY = 1;
		stg.stageHeight / stg.stageWidth;

		addChild(zoneCanvas);
		//addChild(edgeCanvas);
		//addChild(centerCanvas);
		//addChild(cornerCanvas);
		
		//zoneCanvas.addEventListener(MouseEvent.ROLL_OVER, onMouseOverOut);
		//zoneCanvas.addEventListener(MouseEvent.ROLL_OUT, onMouseOverOut);
		
	}
	
	private function onMouseOverOut(e:MouseEvent):Void 
	{
		
		var openflSprite = cast(e.target, openfl.display.Sprite);
				
		var name = "instance" + ((Std.parseInt(openflSprite.name.split("instance")[1])) - 1);
		
		var cellView = cellViewBySpriteName.get(name);
		
		if (cellView == null)	return;
		
		var center = cellView.center;
		//trace(name, cellViewBySpriteName.get(name), center.point);
		
		for (neighbor in center.getNeighbors())
		{
			var neighborCellView = cellViewByCenter.get(neighbor);
			//trace(neighborCellView, neighborCellView.center.point, neighborCellView.sprite);
			if (neighborCellView != null)
			{
				neighborCellView.highlight(e.type == MouseEvent.ROLL_OVER || e.type == MouseEvent.MOUSE_OVER);
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
			
			cellViewByCenter.set(center, cellView);
			cellViewBySpriteName.set(cellView.sprite.name, cellView);
			
			cellView.sprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverOut);
			cellView.sprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOverOut);
		}
		for (key in cellViewBySpriteName.keys())
		{
			trace(key, cellViewBySpriteName.get(key));
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
	
	
	function createCorners(corners:Array<Corner>):Sprite
	{
		var sprite = new Sprite();
		for (corner in corners)
		{
			drawCorner(corner, sprite.graphics);
		}
		return sprite;
	}
	
	function drawCorner(corner:Corner, graphics:Graphics) 
	{
		graphics.beginFill(0xffffff);
		graphics.drawCircle(corner.point.x, corner.point.y, 1);
		graphics.endFill();
		trace( corner.elevation);
	}
	
	
	
	
}