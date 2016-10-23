package;

import openfl.display.Sprite;
import voronoimap.VoronoiMap;

/**
 * ...
 * @author damrem
 */
class Sample extends Sprite
{

	public function new() 
	{
		super();
		
		var map = new VoronoiMap({width:100, height:100});
	}
	
}