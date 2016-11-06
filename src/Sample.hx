package;

import hxlpers.geom.Polygon;
import openfl.display.FPS;
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
import voronoimap.IHasCenter;
import voronoimap.IslandShape;
import voronoimap.VoronoiMap;
using hxlpers.lime.math.Vector2Extender;
using hxlpers.geom.PolygonExtender;
/**
 * ...
 * @author damrem
 */
class Sample extends Sprite
{

	//var cellViewByCenter:Map<Center, CellView>;
	public static inline var ELEVATION_FACTOR:Float = 100;
	var cellViewBySpriteName:Map<String, Zone>;
	var lightVector:Vector3D = new Vector3D(-1, -1, 0);
	
	public function new() 
	{
		super();
		
		cellViewBySpriteName = new Map<String, Zone>();
		
		var stg = Lib.current.stage;
		
		var map = new VoronoiMap( { width:stg.stageWidth, height:stg.stageHeight } );
		
		for (i in 0...Conf.NB_CELLS)
		{
			map.points.push(new Point(Math.random() * stg.stageWidth, Math.random() * stg.stageHeight));
		}
		map.go1ImprovePoints(8);
		map.go2BuildGraph(createZone);
		
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
		addChild(edgeCanvas);
		//addChild(centerCanvas);
		//addChild(cornerCanvas);
		//zoneCanvas.mouseChildren = true;
		//zoneCanvas.addEventListener(MouseEvent.ROLL_OVER, onMouseOverOut);
		//zoneCanvas.addEventListener(MouseEvent.ROLL_OUT, onMouseOverOut);
		zoneCanvas.addEventListener(MouseEvent.MOUSE_MOVE, updateLight);
		updateLight();
		
		addChild(new FPS(10,10,0xff0000));
		
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
	
	function createZone(center:Center<Zone>):Zone
	{
		return new Zone(center);
	}
	
	private function onMouseOverOut(e:MouseEvent):Void 
	{
		var openflSprite = cast(e.target, openfl.display.Sprite);
				
		var name = "instance" + ((Std.parseInt(openflSprite.name.split("instance")[1]))/* - 1*/);
		
		var cellView = cellViewBySpriteName.get(name);
		
		if (cellView == null)	return;
		
		var over = e.type == MouseEvent.ROLL_OVER || e.type == MouseEvent.MOUSE_OVER;
		
		cellView.highlight(this, over);
		
		/*var center = cellView.center;
		
		for (neighbor in center.getActualNeighbors())
		{
			var neighborCellView = neighbor.data;
			if (neighborCellView != null)
			{
				neighborCellView.highlight(over?0.125:0);
			}
		}*/
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
	
	function createCellViews(centers:Array<Center<Zone>>):Sprite
	{
		var sprite = new Sprite();
		sprite.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverOut);
		sprite.addEventListener(MouseEvent.MOUSE_OUT, onMouseOverOut);
		centers.sort(function(centerA:Center<Zone>, centerB:Center<Zone>):Int
		{
			return Std.int((centerA.point.y - centerB.point.y)*1000);
		});
		for (center in centers)
		{
			var cellView = center.data;
			cellView.draw();
			sprite.addChild(cellView.sprite);
			
			center.data = cellView;
			cellViewBySpriteName.set(cellView.sprite.name, cellView);
		}
		return sprite;
	}
	
	function createEdgeViews(edges:Array<Edge<Zone>>):Sprite
	{
		var sprite = new Sprite();
		sprite.mouseEnabled = false;
		for (edge in edges)
		{
			createEdge(edge, sprite.graphics);
		}
		return sprite;
	}
	
	function createEdge(edge:Edge<Zone>, graphics:Graphics)
	{
		if (edge.v0 != null && edge.v1 != null && !edge.d0.water && !edge.d1.water)
		{
			var isRiver = edge.river >= 1;
			var edgeThickness = isRiver ? 2 : 1;
			var edgeColor = isRiver ? 0x0080ff : 0xffffff;
			var edgeAlpha = isRiver ? 1 : 0.25;
			graphics.lineStyle(edgeThickness, edgeColor, edgeAlpha);
			graphics.moveTo(edge.v0.elevatedPoint.x, edge.v0.elevatedPoint.y);
			graphics.lineTo(edge.v1.elevatedPoint.x, edge.v1.elevatedPoint.y);
		}
	}
	
	
	function createCorners(corners:Array<Corner<Zone>>):Sprite
	{
		var sprite = new Sprite();
		for (corner in corners)
		{
			drawCorner(corner, sprite.graphics);
		}
		return sprite;
	}
	
	function drawCorner(corner:Corner<Zone>, graphics:Graphics) 
	{
		graphics.beginFill(0xffffff);
		graphics.drawCircle(corner.point.x, corner.point.y, 1);
		graphics.endFill();
		//trace( corner.elevation);
	}
	
	
	
	
}