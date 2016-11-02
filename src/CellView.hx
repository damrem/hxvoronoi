package;
import hxlpers.colors.RndColor;
import lime.math.color.ARGB;
import lime.math.Vector2;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
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
	public var center(default, null):Center;
	public var sprite:Sprite;
	static var uid:UInt = 0;
	var defaultColorTransform:ColorTransform;
	var highlightedColorTransform:ColorTransform;
	var baseColor:UInt;

	public function new(center:Center) 
	{
		this.center = center;
		sprite = new Sprite();
		sprite.useHandCursor = sprite.buttonMode = true;
		//sprite.scaleY = 3 / 4;
		trace(sprite.name);
		//sprite.alpha = (4+ center.elevation)/5;
		//sprite.alpha = center.elevation;
		
		//sprite.name = "cellView" + uid++;// center.point.x + ',' + center.point.y;
		//sprite.mouseChildren = false;
		
		this.baseColor = 0x00ff00;
		//sprite.addChild(createBorders());
		//sprite.addChild(createCorners());
		
		baseColor = !center.ocean 
		? RndColor.green(0.5, 1) + RndColor.red(0.25, 0.5) 
		: 0x0080ff;
		
		trace(baseColor);
		sprite.addChild(createZone());
		//sprite.addChild(createCenter());
		
		//var bc = new ARGB();
		//bc.
		
		var defaultOffset = Math.round((center.elevation - 0.25) * 256);
		trace(defaultOffset);
		//defaultOffset = 0;
		defaultColorTransform = new ColorTransform(1, 1, 1, 1, defaultOffset, defaultOffset, defaultOffset);
		highlightedColorTransform = defaultColorTransform.clone();
		highlightedColorTransform.redOffset = highlightedColorTransform.greenOffset = highlightedColorTransform.blueOffset = defaultOffset * 2;
	
		highlight(false);
	}
	
	public function highlight(?yes:Bool = true)
	{
		trace("highlight", yes);
		sprite.transform.colorTransform = yes ? highlightedColorTransform : defaultColorTransform;
	}
	
	function createZone():Sprite
	{
		var sprite = new Sprite();
		
		var graphics = sprite.graphics;
		
		trace(baseColor);
		graphics.beginFill(baseColor);
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
	
	function drawBorder(edge:Edge, graphics:Graphics)
	{
		if (edge.v0 != null && edge.v1 != null)
		{
			graphics.lineStyle(2, 0x000000, 0.125);
			graphics.moveTo(edge.v0.point.x, edge.v0.point.y);
			graphics.lineTo(edge.v1.point.x, edge.v1.point.y);
		}
	}
	
	
	
	
	
}