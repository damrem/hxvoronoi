package com.nodename.delaunay;

class Node {
	public static var pool:Array<Node> = new Array<Node>();
	public var parent:Node;
	public var treeSize:Int;
	public function new() {}
}