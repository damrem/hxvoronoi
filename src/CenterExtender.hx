package;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;

/**
 * ...
 * @author damrem
 */
class CenterExtender
{

	static public function getNeighbors<T>(centerA:Center<T>):Array<Center<T>>
	{
		return centerA.neighbors.filter(function(centerB:Center<T>):Bool
		{
			return centerA.corners.filter(function(cornerA:Corner<T>)
			{
				return centerB.corners.indexOf(cornerA) >= 0;
			})
			.length>0;
		});
		
	}
	
}