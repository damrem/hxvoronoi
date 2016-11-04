package;

import hxlpers.geom.Polygon;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Vector3D;
import openfl.Lib;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
import voronoimap.IslandShape;
import voronoimap.VoronoiMap;
using hxlpers.lime.math.Vector2Extender;
using CenterExtender;
using hxlpers.geom.PolygonExtender;
/**
 * ...
 * @author damrem
 */
class Sample extends Sprite
{

	//var cellViewByCenter:Map<Center, CellView>;
	public static inline var ELEVATION_FACTOR:Float = 100;
	var cellViewBySpriteName:Map<String, CellView>;
	var lightVector:Vector3D = new Vector3D(-1, -1, 0);
	
	public function new() 
	{
		super();
		
		cellViewBySpriteName = new Map<String, CellView>();
		
		var stg = Lib.current.stage;
		
		var map = new VoronoiMap( { width:stg.stageWidth, height:stg.stageHeight } );
		
		for (i in 0...1000)
		{
			map.points.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		map.go1ImprovePoints(8);
		map.go2BuildGraph();
		
		map.islandShape = IslandShape.makeRadial(1);
		//map.islandShape = IslandShape.makeBlob();
		//map.islandShape = IslandShape.makeNoise(123456789);
		//map.islandShape = IslandShape.makePerlin(10);
		
		map.go3AssignElevations(0.3);
		
		
		map.go4AssignMoisture(99);
		map.go5DecorateMap();
		
		
		
		var zoneCanvas = createCellViews(map.centers);
		zoneCanvas.name = "zoneCanvas";
		
		var edgeCanvas = createEdgeViews(map.edges);
		edgeCanvas.name = "edgeCanvas";
		
		var cornerCanvas = createCorners(map.corners);
		cornerCanvas.name = "cornerCanvas";
		
		//zoneCanvas.alpha = edgeCanvas.alpha = 0.25;
		//zoneCanvas.alpha = 0.25;
		
		
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
		//zoneCanvas.mouseChildren = true;
		//zoneCanvas.addEventListener(MouseEvent.ROLL_OVER, onMouseOverOut);
		//zoneCanvas.addEventListener(MouseEvent.ROLL_OUT, onMouseOverOut);
		zoneCanvas.addEventListener(MouseEvent.MOUSE_MOVE, updateLight);
		updateLight();
		
	}
	
	private function updateLight(?e:MouseEvent):Void 
	{
		lightVector.x = e != null ? e.stageX - Lib.current.stage.stageWidth / 2 : 1;
		lightVector.y = e != null ? e.stageY - Lib.current.stage.stageHeight / 2 : 1;
		lightVector.normalize();
		
		for (cellView in cellViewBySpriteName.iterator())
		{
			cellView.updateSlopes(lightVector);
		}
	}
	
	private function onMouseOverOut(e:MouseEvent):Void 
	{
		var openflSprite = cast(e.target, openfl.display.Sprite);
				
		var name = "instance" + ((Std.parseInt(openflSprite.name.split("instance")[1]))/* - 1*/);
		
		var cellView = cellViewBySpriteName.get(name);
		
		if (cellView == null)	return;
		
		var over = e.type == MouseEvent.ROLL_OVER || e.type == MouseEvent.MOUSE_OVER;
		
		cellView.highlight(over?0.25:0);
		
		var center = cellView.center;
		
		for (neighbor in center.getNeighbors())
		{
			var neighborCellView = neighbor.data;
			if (neighborCellView != null)
			{
				neighborCellView.highlight(over?0.125:0);
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
	
	function createCellViews(centers:Array<Center<CellView>>):Sprite
	{
		var sprite = new Sprite();
		sprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverOut);
		sprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOverOut);
		centers.sort(function(centerA:Center<CellView>, centerB:Center<CellView>):Int
		{
			return Std.int((centerA.point.y - centerB.point.y)*1000);
		});
		for (center in centers)
		{
			var cellView = new CellView(center);
			sprite.addChild(cellView.sprite);
			
			center.data = cellView;
			cellViewBySpriteName.set(cellView.sprite.name, cellView);
		}
		return sprite;
	}
	
	function createEdgeViews(edges:Array<Edge<CellView>>):Sprite
	{
		var sprite = new Sprite();
		for (edge in edges)
		{
			createEdge(edge, sprite.graphics);
		}
		return sprite;
	}
	
	function createEdge(edge:Edge<CellView>, graphics:Graphics)
	{
		if (edge.v0 != null && edge.v1 != null)
		{
			graphics.lineStyle(2, 0xff0000);
			graphics.moveTo(edge.v0.point.x, edge.v0.point.y);
			graphics.lineTo(edge.v1.point.x, edge.v1.point.y);
		}
	}
	
	
	function createCorners(corners:Array<Corner<CellView>>):Sprite
	{
		var sprite = new Sprite();
		for (corner in corners)
		{
			drawCorner(corner, sprite.graphics);
		}
		return sprite;
	}
	
	function drawCorner(corner:Corner<CellView>, graphics:Graphics) 
	{
		graphics.beginFill(0xffffff);
		graphics.drawCircle(corner.point.x, corner.point.y, 1);
		graphics.endFill();
		trace( corner.elevation);
	}
	
	
	
	
}