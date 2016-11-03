package;
import hxlpers.colors.RndColor;
import lime.math.color.ARGB;
import lime.math.Vector2;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import voronoimap.Biome;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
using hxlpers.lime.math.Vector2Extender;
using hxlpers.openfl.geom.ColorTransformExtender;
/**
 * ...
 * @author damrem
 */
class CellView
{
	public var center(default, null):Center<CellView>;
	public var sprite:Sprite;
	static var uid:UInt = 0;
	var defaultColorTransform:ColorTransform;
	var highlightedColorTransform:ColorTransform;
	var baseColor:UInt;

	public function new(center:Center<CellView>) 
	{
		
		var colorByBiome:Map<Biome, Int> = [
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
		
		this.center = center;
		sprite = new Sprite();
		sprite.mouseChildren = false;
		sprite.useHandCursor = sprite.buttonMode = true;
		//sprite.scaleY = 3 / 4;
		trace(sprite.name);
		//sprite.alpha = (4+ center.elevation)/5;
		//sprite.alpha = center.elevation;
		
		//sprite.name = "cellView" + uid++;// center.point.x + ',' + center.point.y;
		//sprite.mouseChildren = false;
		
		this.baseColor = colorByBiome[center.biome];
		//sprite.addChild(createBorders());
		//sprite.addChild(createCorners());
		
		//baseColor = !center.water 
		//? RndColor.green(0.5, 1) + RndColor.red(0.25, 0.5) 
		//: 0x0080ff;
		
		trace(baseColor);
		sprite.addChild(createZone(baseColor));
		sprite.addChild(createZone(0x0080ff, center.moisture/2));
		//sprite.addChild(createCenter());
		
		//var bc = new ARGB();
		//bc.
		
		//var defaultOffset = Math.round((center.elevation - 0.25) * 256);
		//trace(defaultOffset);
		//defaultOffset = 0;
		//defaultColorTransform = new ColorTransform();
		//highlightedColorTransform = defaultColorTransform.clone();
		//highlightedColorTransform.redOffset = highlightedColorTransform.greenOffset = highlightedColorTransform.blueOffset = defaultOffset * 2;
	
	}
	
	public function highlight(lightness:Float = 0)
	{
		var o = lightness * 256;
		sprite.transform.colorTransform = new ColorTransform(1,1,1,1,o,o,o);
		trace(center.border, center.coast, center.moisture, center.biome);
	}
	
	function createZone(color:Int, alpha:Float=1):Sprite
	{
		var sprite = new Sprite();
		
		var graphics = sprite.graphics;
		
		trace(baseColor);
		graphics.beginFill(color, alpha);
		var corners = center.corners.copy();
		corners.sort(function(cornerA:Corner<CellView>, cornerB:Corner<CellView>)
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
	
	function createCenter():Sprite
	{
		var sprite = new Sprite();
		var graphics = sprite.graphics;
		graphics.beginFill(0xffffff);
		graphics.drawCircle(center.point.x, center.point.y, 1);
		graphics.endFill();
		return sprite;
	}
	
	function createBorders():Sprite
	{
		var sprite = new Sprite();
		for (edge in center.borders)
		{
			drawBorder(edge, sprite.graphics);
		}
		return sprite;
	}
	
	function drawBorder(edge:Edge<CellView>, graphics:Graphics)
	{
		if (edge.v0 != null && edge.v1 != null)
		{
			graphics.lineStyle(2, 0x000000, 0.125);
			graphics.moveTo(edge.v0.point.x, edge.v0.point.y);
			graphics.lineTo(edge.v1.point.x, edge.v1.point.y);
		}
	}
	
	
	
	
	
}