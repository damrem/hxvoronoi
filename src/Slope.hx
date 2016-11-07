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
	var _subtractedVectors:Array<Vector3D>;
	
	public function new(center:Center<Zone>, edge:Edge<Zone>, vector3DPool:Pool<Vector3D>) 
	{
		super();
		this.vector3DPool = vector3DPool;
		
		_subtractedVectors = [vector3DPool.provide(), vector3DPool.provide()];
		
		colorTransform = new ColorTransform();
		
		_a = new Vector3D();
		_b = new Vector3D();
		_c = new Vector3D();
		_crossProduct = new Vector3D();
		
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
		
		transform.colorTransform = blankColorTransform;
		transform.colorTransform = colorTransform;
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
		
		_bMinusA = subtractVector3D(_b, _a, 0);
		_cMinusA = subtractVector3D(_c, _a, 1);
		_normal = crossProductVector3D(_bMinusA, _cMinusA);
		
		if (_normal.z < 0) { _normal.scaleBy( -1); }
		_normal.normalize();
		light = 0.5 + 35 * _normal.dotProduct(lightVector);
		if (light < 0) light = 0;
		if (light > 1) light = 1;
		return light;
    }
	
	function subtractVector3D(a:Vector3D, b:Vector3D, i:Int):Vector3D
	{
		_subtractedVectors[i].x = a.x - b.x;
		_subtractedVectors[i].y = a.y - b.y;
		_subtractedVectors[i].z = a.z - b.z;
		_subtractedVectors[i].w = 0;
		return _subtractedVectors[i];
	}
	
	function crossProductVector3D(a:Vector3D, b:Vector3D):Vector3D
	{
		_crossProduct.x = a.y * b.z - a.z * b.y;
		_crossProduct.y = a.z * b.x - a.x * b.z;
		_crossProduct.z = a.x * b.y - a.y * b.x;
		_crossProduct.w = 1;
		return _crossProduct;
	}
	
	
	
}