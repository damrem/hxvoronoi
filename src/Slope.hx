package;

import flash.Vector;
import hxlpers.pooling.Pool;
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
	var center:Center<Zone>;
	var edge:Edge<Zone>;
	//var A:Vector3D;
	//var B:Vector3D;
	//var C:Vector3D;
	var normal:Vector3D;
	var light:Float;
	
	//static var shadowColorTransforms:Array<ColorTransform>;
	//static var lightColorTransforms:Array<ColorTransform>;
	static var colorTransformPool:Pool<ColorTransform>;
	static var vector3DPool:Pool<Vector3D>;
	var _subtractedVector3D:Vector3D;
	
	public function new(center:Center<Zone>, edge:Edge<Zone>) 
	{
		super();
		
		_subtractedVector3D = new Vector3D();
		
		if (colorTransformPool == null) colorTransformPool = new Pool<ColorTransform>(ColorTransform, Conf.NB_CELLS);
		if (vector3DPool == null) vector3DPool = new Pool<Vector3D>(Vector3D, Conf.NB_CELLS * 10);
		/*if (shadowColorTransforms==null) {
			shadowColorTransforms = [];
			lightColorTransforms = [];
			for (i in 0...5 + 1)
			{
				shadowColorTransforms[i] = new ColorTransform(1, 1, 1, i / 10, -255, -255, -255);
				lightColorTransforms[i] = new ColorTransform(1, 1, 1, i / 10, 255, 255, 255);
			}
		}*/
		
		this.edge = edge;
		this.center = center;
		graphics.beginFill(0x808080);
		graphics.moveTo(center.elevatedPoint.x, center.elevatedPoint.y);
		graphics.lineTo(edge.v0.elevatedPoint.x, edge.v0.elevatedPoint.y);
		graphics.lineTo(edge.v1.elevatedPoint.x, edge.v1.elevatedPoint.y);
		graphics.endFill();
	}
	
	public function update(lightVector:Vector3D)
	{
		calculateLighting(lightVector, center, edge.v0, edge.v1);
		//var lightOffset:Int = light < 0.5? -255:255;// (light * 2 - 1) * 256;
		//var alphaMultiplier = Math.abs(light - 0.5);
		//var alphaOffset = Std.int( -Math.abs(light - 0.5) * 255 - 128);
		//trace(light, lightOffset, alphaMultiplier);
		//transform.colorTransform = new ColorTransform(1, 1, 1, alphaMultiplier, lightOffset, lightOffset, lightOffset/*, alphaOffset*/);
		
		colorTransformPool.retake(transform.colorTransform);
		
		var tmpCt = colorTransformPool.provide();
		tmpCt.alphaMultiplier = Math.abs(light - 0.5);
		tmpCt.redOffset = tmpCt.greenOffset = tmpCt.blueOffset = light < 0.5? -255:255;
		transform.colorTransform = tmpCt;
		
		//transform.colorTransform = (light < 0.5?shadowColorTransforms:lightColorTransforms)[Math.round(Math.abs(light - 0.5) * 10)];
		
		//var ct = transform.colorTransform;
		//ct.alphaMultiplier = alphaMultiplier;
		//ct.redOffset = ct.greenOffset = ct.blueOffset = lightOffset;
	}
	
	function calculateLighting(lightVector:Vector3D, p:Center<Zone>, r:Corner<Zone>, s:Corner<Zone>):Float 
	{
		var A = vector3DPool.provide();
		var B = vector3DPool.provide();
		var C = vector3DPool.provide();
		
		A.x = p.point.x;
		A.y = p.point.y;
		A.z = p.elevation;
		
		B.x = r.point.x;
		B.y = r.point.y;
		B.z = r.elevation;
		
		C.x = s.point.x;
		C.y = s.point.y;
		C.z = s.elevation;
		
		//var bMinusA = B.subtract(A);
		//var cMinusA = C.subtract(A);
		//var bMinusA2 = subtractVector3D(B, A);
		//var cMinusA2 = subtractVector3D(C, A);
		//trace(bMinusA, bMinusA2);
		//trace(cMinusA, cMinusA2);
		
		//normal = B.subtract(A).crossProduct(C.subtract(A));
		
		normal = subtractVector3D(B, A).crossProduct(subtractVector3D(C, A));
		//trace(normal, normal2);
		if (normal.z < 0) { normal.scaleBy( -1); }
		normal.normalize();
		light = 0.5 + 35 * normal.dotProduct(lightVector);
		if (light < 0) light = 0;
		if (light > 1) light = 1;
		return light;
    }
	
	function subtractVector3D(a:Vector3D, b:Vector3D):Vector3D
	{
		var v = vector3DPool.provide();
		v.x = a.x - b.x;
		v.y = a.y - b.y;
		v.z = a.z - b.z;
		return v;
	}
	
	
	
}