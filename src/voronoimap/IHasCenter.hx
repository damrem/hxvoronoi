package voronoimap;
import voronoimap.graph.Center;

/**
 * @author damrem
 */

interface IHasCenter<T:(IHasCenter<T>)>
{
	var center(default, default):Center<T>;
}