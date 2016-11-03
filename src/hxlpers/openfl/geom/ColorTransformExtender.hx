package hxlpers.openfl.geom;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author damrem
 */
class ColorTransformExtender
{

	static public function clone(ct:ColorTransform):ColorTransform
	{
		return new ColorTransform(ct.redMultiplier, ct.greenMultiplier, ct.blueMultiplier, ct.alphaMultiplier, ct.redOffset, ct.greenOffset, ct.blueOffset, ct.alphaOffset);
	}
	
}