package hxlpers.pooling;

/**
 * ...
 * @author damrem
 */
class Pool<T/*:IRenewable*/>
{
	var unused:Array<T>;
	var cl:Class<T>;
	var _providedItem:T;
	public var nbProvided(default, null):Int;
	public var nbRetaken(default, null):Int;
	
	public function new(Cl:Class<T>, size:UInt=256) 
	{
		cl = Cl;
		unused = new Array<T>();
		
		nbProvided = 0;
		nbRetaken = 0;
		
		for (i in 0...size)
		{
			unused.push(Type.createInstance(cl, []));
		}
		//trace(unused.length, unused);
	}
	
	inline public function provide():T
	{
		if (unused.length > 0)
		{
			_providedItem = unused.pop();
		}
		else
		{
			_providedItem = Type.createInstance(cl, []);
			//_providedItem = null;
		}
		nbProvided++;
		return _providedItem;
	}
	
	inline public function retake(item:T):T
	{
		unused.unshift(item);
		nbRetaken++;
		return item;
	}
}