package;

import flash.Vector;
import hxlpers.pooling.Pool;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Transform;
import openfl.geom.Vector3D;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;
import voronoimap.graph.Edge;
using hxlpers.openfl.geom.Vector3DExtender;

/**
 * ...
 * @author damrem
 */
class Slope extends Sprite
{
	var center:Center<Zone>;
	var edge:Edge<Zone>;
	var _normal:Vector3D;
	var light:Float;
	
	var colorTransform:ColorTransform;
	static var blankColorTransform:ColorTransform = new ColorTransform();
	var _a:openfl.geom.Vector3D;
	var _b:openfl.geom.Vector3D;
	var _c:openfl.geom.Vector3D;
	var _bMinusA:openfl.geom.Vector3D;
	var _cMinusA:openfl.geom.Vector3D;
	var _crossProduct:Vector3D;
	var vector3DPool:Pool<Vector3D>;
	//var _subtractedVectors:Array<Vector3D>;
	var _subtractedVectorA:Vector3D;
	var _subtractedVectorB:Vector3D;
	var _transform:Transform;
	
	public function new(center:Center<Zone>, edge:Edge<Zone>, vector3DPool:Pool<Vector3D>) 
	{
		super();
		this.vector3DPool = vector3DPool;
		
		//_subtractedVectors = [vector3DPool.provide(), vector3DPool.provide()];
		_subtractedVectorA = vector3DPool.provide();
		_subtractedVectorB = vector3DPool.provide();
		
		_transform = transform;
		colorTransform = new ColorTransform();
		
		_a = vector3DPool.provide();
		_b = vector3DPool.provide();
		_c = vector3DPool.provide();
		_bMinusA = vector3DPool.provide();
		_cMinusA = vector3DPool.provide();
		_crossProduct = vector3DPool.provide();
		_normal = vector3DPool.provide();
		
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
		
		colorTransform.alphaMultiplier = Math.abs(light - 0.5);
		colorTransform.redOffset = colorTransform.greenOffset = colorTransform.blueOffset = light < 0.5? -255:255;
		
		_transform.colorTransform = blankColorTransform;
		_transform.colorTransform = colorTransform;
	}
	
	function calculateLighting(lightVector:Vector3D, p:Center<Zone>, r:Corner<Zone>, s:Corner<Zone>):Float 
	{
		_a.x = p.point.x;
		_a.y = p.point.y;
		_a.z = p.elevation;
		
		_b.x = r.point.x;
		_b.y = r.point.y;
		_b.z = r.elevation;
		
		_c.x = s.point.x;
		_c.y = s.point.y;
		_c.z = s.elevation;
		
		subtractVector3D(_bMinusA, _b, _a);
		subtractVector3D(_cMinusA, _c, _a);
		crossProductVector3D(_normal, _bMinusA, _cMinusA);
		
		if (_normal.z < 0) { _normal.inlineScaleBy( -1); }
		_normal.inlineNormalize();
		light = 0.5 + 35 * _normal.inlineDotProduct(lightVector);
		if (light < 0) light = 0;
		if (light > 1) light = 1;
		return light;
    }
	
	inline function subtractVector3D(target:Vector3D, a:Vector3D, b:Vector3D)
	{
		target.x = a.x - b.x;
		target.y = a.y - b.y;
		target.z = a.z - b.z;
		target.w = 0;
	}
	
	inline function crossProductVector3D(target:Vector3D, a:Vector3D, b:Vector3D)
	{
		target.x = a.y * b.z - a.z * b.y;
		target.y = a.z * b.x - a.x * b.z;
		target.z = a.x * b.y - a.y * b.x;
		target.w = 1;
	}
	
	
	
	
}