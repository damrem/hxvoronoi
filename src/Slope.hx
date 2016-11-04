package;

import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Vector3D;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;

/**
 * ...
 * @author damrem
 */
class Slope extends Sprite
{
	var center:Center<CellView>;
	var edge:Edge<CellView>;
	public function new(center:Center<CellView>, edge:Edge<CellView>) 
	{
		super();
		this.edge = edge;
		this.center = center;
		graphics.beginFill(0x808080);
		graphics.moveTo(center.point.x, center.point.y);
		graphics.lineTo(edge.v0.point.x, edge.v0.point.y);
		graphics.lineTo(edge.v1.point.x, edge.v1.point.y);
		graphics.endFill();
	}
	
	public function update(lightVector:Vector3D)
	{
		var light = calculateLighting(lightVector, center, edge.v0, edge.v1);
		var lightOffset = light < 0.5? -255:255;// (light * 2 - 1) * 256;
		var alphaMultiplier = Math.abs(light - 0.5);
		//var alphaOffset = Std.int( -Math.abs(light - 0.5) * 255 - 128);
		//trace(light, lightOffset, alphaMultiplier);
		transform.colorTransform = new ColorTransform(1, 1, 1, alphaMultiplier, lightOffset, lightOffset, lightOffset/*, alphaOffset*/);
	}
	
	function calculateLighting(lightVector:Vector3D, p:Center<CellView>, r:Corner<CellView>, s:Corner<CellView>):Float 
	{
		var A:Vector3D = new Vector3D(p.point.x, p.point.y, p.elevation);
		var B:Vector3D = new Vector3D(r.point.x, r.point.y, r.elevation);
		var C:Vector3D = new Vector3D(s.point.x, s.point.y, s.elevation);
		var normal:Vector3D = B.subtract(A).crossProduct(C.subtract(A));
		if (normal.z < 0) { normal.scaleBy( -1); }
		normal.normalize();
		var light:Float = 0.5 + 35 * normal.dotProduct(lightVector);
		if (light < 0) light = 0;
		if (light > 1) light = 1;
		return light;
    }
	
	
	
}