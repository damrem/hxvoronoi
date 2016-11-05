package;
import flash.display.DisplayObjectContainer;
import lime.math.Vector2;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Vector3D;
import voronoimap.Biome;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
import voronoimap.IHasCenter;
using hxlpers.lime.math.Vector2Extender;
using hxlpers.openfl.geom.ColorTransformExtender;
/**
 * ...
 * @author damrem
 */
class Zone implements IHasCenter<Zone>
{
	public var center(default, default):Center<Zone>;
	public var sprite:Sprite;
	public var biome:Biome;  // biome type (see article)
	static var colorByBiome:Map<Biome, Int> = [
		OCEAN => 0x0080ff,
		MARSH => 0x808000,
		ICE => 0xeeeeff,
		LAKE => 0x0040ff,
		BEACH => 0xffff80,
		SNOW => 0xffffff,
		TUNDRA => 0xeeffee,
		BARE => 0x808080,
		SCORCHED => 0xff8000,
		TAIGA => 0xffeeee,
		SHRUBLAND => 0x80ff00,
		TEMPERATE_DESERT => 0xeeff00,
		TEMPERATE_RAIN_FOREST => 0x00ff40,
		TEMPERATE_DECIDUOUS_FOREST => 0x00ff80,
		GRASSLAND => 0x40ff80,
		TROPICAL_RAIN_FOREST => 0x00ff40,
		TROPICAL_SEASONAL_FOREST => 0x00ff80,
		SUBTROPICAL_DESERT => 0xffee00
	];
    
	
	static var uid:UInt = 0;
	var defaultColorTransform:ColorTransform;
	var highlightedColorTransform:ColorTransform;
	var slopes:Array<Slope>;
	var sortedCorners:Array<Corner<Zone>>;
	public var border:Sprite;

	public function new(center:Center<Zone>) 
	{
		this.center = center;
		
		slopes = [];
		
		
		//sprite.addChild(draw(0x0080ff, center.moisture / 2));
		
		//if(!center.water)	sprite.addChild(createCenter(0.25));
		
		
		
	}
	
	public function highlight(container:DisplayObjectContainer, yes:Bool=true)
	{
		//var o = lightness * 256;
		//sprite.transform.colorTransform = new ColorTransform(1,1,1,1,o,o,o);
		//trace(center.border, center.coast, center.moisture, center.biome);
		if (yes)	container.addChild(border);
		else 		container.removeChild(border);
	}
	
	public function draw():Sprite
	{
		sortedCorners = center.corners.copy();
		sortedCorners.sort(sortCorners);
		
		sprite = new Sprite();
		sprite.mouseChildren = false;
		sprite.useHandCursor = sprite.buttonMode = true;
		
		var graphics = sprite.graphics;
		
		//trace(baseColor);
		
		//if (biome == null) biome = SUBTROPICAL_DESERT;
		
		graphics.beginFill(colorByBiome[biome]/*, center.moisture / 2*/);
		
		var lastCorner = sortedCorners[sortedCorners.length - 1];
		graphics.moveTo(lastCorner.elevatedPoint.x, lastCorner.elevatedPoint.y);
		for (corner in sortedCorners)
		{
			graphics.lineTo(corner.elevatedPoint.x, corner.elevatedPoint.y);
		}
		graphics.endFill();
		
		if (biome != Biome.LAKE)	sprite.addChild(createSlopes(/*0.25*/));
		
		border = createBorders();
		
		return sprite;
	}
	
	function sortCorners(cornerA:Corner<Zone>, cornerB:Corner<Zone>)
		{
			var va = new Vector2(cornerA.point.x - center.point.x, cornerA.point.y - center.point.y);
			var vb = new Vector2(cornerB.point.x - center.point.x, cornerB.point.y - center.point.y);
			return Std.int(va.getAngle()*100 - vb.getAngle()*100);
		}
	
	function createSlopes(alpha:Float=1):Sprite
	{
		var sprite = new Sprite();
		
		for (edge in center.edges)
		{
			if (edge.v0 == null || edge.v1 == null) continue;
			
			var slope = new Slope(center, edge);
			sprite.addChild(slope);
			slopes.push(slope);
		}
		
		return sprite;
	}
	
	
	public function updateSlopes(lightVector:Vector3D)
	{
		for (slope in slopes)
		{
			slope.update(lightVector);
		}
	}
	
	
	
	function createCenter(alpha:Float=1):Sprite
	{
		var sprite = new Sprite();
		var graphics = sprite.graphics;
		graphics.beginFill(0xffffff, alpha);
		graphics.drawCircle(center.elevatedPoint.x, center.elevatedPoint.y, 1);
		graphics.endFill();
		return sprite;
	}
	
	function createBorders():Sprite
	{
		var sprite = new Sprite();
		sprite.mouseEnabled = false;
		//sprite.alpha = 0.5;
		var graphics = sprite.graphics;
		var lastCorner = sortedCorners[sortedCorners.length - 1];
		graphics.moveTo(lastCorner.elevatedPoint.x, lastCorner.elevatedPoint.y);
		graphics.lineStyle(2, 0xffffff, 0.5);
		
		for (corner in sortedCorners)
		{
			graphics.lineTo(corner.elevatedPoint.x, corner.elevatedPoint.y);
		}
		
		return sprite;
	}
	
	function drawBorder(edge:Edge<Zone>, graphics:Graphics)
	{
		if (edge.v0 != null && edge.v1 != null)
		{
			graphics.lineStyle(2, 0x000000);
			graphics.moveTo(edge.v0.elevatedPoint.x, edge.v0.elevatedPoint.y);
			graphics.lineTo(edge.v1.elevatedPoint.x, edge.v1.elevatedPoint.y);
		}
	}
	
	
	
	
	
}