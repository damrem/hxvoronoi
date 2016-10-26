package;
import hxlpers.colors.RndColor;
import lime.math.Vector2;
import openfl.display.Sprite;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
using Vector2Extender;
/**
 * ...
 * @author damrem
 */
class CellView
{
	public var center(default, null):Center;
	public var sprite:Sprite;
	static var uid:UInt = 0;

	public function new(center:Center) 
	{
		
		this.center = center;
		sprite = new Sprite();
		
		sprite.name = "cellView" + uid++;// center.point.x + ',' + center.point.y;
		sprite.mouseChildren = false;
		
		sprite.addChild(createZone());
		//addChild(createCenter());
	}
	
	function createZone():Sprite
	{
		var sprite = new Sprite();
		
		var graphics = sprite.graphics;
		
		graphics.beginFill(RndColor.green(0.5, 1));
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
	
}