package;
import voronoimap.graph.Center;
import voronoimap.graph.Corner;

/**
 * ...
 * @author damrem
 */
class CenterExtender
{

	static public function getNeighbors(centerA:Center):Array<Center>
	{
		return centerA.neighbors.filter(function(centerB:Center):Bool
		{
			return centerA.corners.filter(function(cornerA:Corner)
			{
				return centerB.corners.indexOf(cornerA) >= 0;
			})
			.length>0;
		});
		
	}
	
}