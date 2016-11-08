package hxlpers.openfl.geom;
import openfl.geom.Vector3D;


/**
 * ...
 * @author damrem
 */
class Vector3DExtender
{

	static public inline function inlineDotProduct(v:Vector3D, w:Vector3D):Float 
	{
		return v.x * w.x + v.y * w.y + v.z * w.z;
	}
	
	static public inline function inlineScaleBy (v:Vector3D, s:Float)
	{
		v.x *= s;
		v.y *= s;
		v.z *= s;
	}
	
	static public inline function inlineNormalize (v:Vector3D):Float {
		var l = inlineLength(v);
		if (l != 0) {
			v.x /= l;
			v.y /= l;
			v.z /= l;
		}
		return l;
	}
	
	static public inline function inlineLength(v:Vector3D):Float
	{
		return Math.sqrt (v.x * v.x + v.y * v.y + v.z * v.z);
	}
	
}