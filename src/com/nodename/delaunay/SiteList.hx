package com.nodename.delaunay;

import com.nodename.geom.Circle;
import com.nodename.utils.IDisposable;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using Std;

class SiteList implements IDisposable {

	private var _sites:Array<Site>;
	private var _currentIndex:Int;
	
	private var _sorted:Bool;
	
	public function new()
	{
		_sites = new Array<Site>();
		_sorted = false;
	}

	public function dispose():Void
	{
		if (_sites != null)
		{
			for (site in _sites)
			{
				site.dispose();
			}
			_sites = null;
		}
	}

	public function push(site:Site):Int
	{
		_sorted = false;
		return _sites.push(site);
	}
	
	public var length(get_length, null):Int;
	private inline function get_length():Int
	{
		return _sites.length;
	}

	public function next():Site
	{
		if (_sorted == false)
		{
			throw "SiteList::next():  sites have not been sorted";
		}
		if (_currentIndex < _sites.length)
		{
			return _sites[_currentIndex++];
		}
		else
		{
			return null;
		}
	}
	
	public function getSitesBounds():Rectangle
	{
		if (_sorted == false)
		{
			Site.sortSites(_sites);
			_currentIndex = 0;
			_sorted = true;
		}
		var xmin:Float, xmax:Float, ymin:Float, ymax:Float;
		if (_sites.length == 0)
		{
			return new Rectangle(0, 0, 0, 0);
		}
		
		xmin = Math.POSITIVE_INFINITY;
		xmax = Math.NEGATIVE_INFINITY;
		for (site in _sites)
		{
			if (site.x < xmin)
			{
				xmin = site.x;
			}
			if (site.x > xmax)
			{
				xmax = site.x;
			}
		}
		// here's where we assume that the sites have been sorted on y:
		ymin = _sites[0].y;
		ymax = _sites[_sites.length - 1].y;
		
		return new Rectangle(xmin, ymin, xmax - xmin, ymax - ymin);
	}

	public function siteColors(referenceImage:BitmapData = null):Array<Int>
	{
		var colors:Array<Int> = new Array<Int>();
		for (site in _sites)
		{
			colors.push(referenceImage != null ? referenceImage.getPixel(site.x.int(), site.y.int()) : site.color);
		}
		return colors;
	}

	public function siteCoords():Array<Point>
	{
		var coords:Array<Point> = new Array<Point>();
		for (site in _sites)
		{
			coords.push(site.coord);
		}
		return coords;
	}

	/**
	 * 
	 * @return the largest circle centered at each site that fits in its region;
	 * if the region is infinite, return a circle of radius 0.
	 * 
	 */
	public function circles():Array<Circle>
	{
		var circles:Array<Circle> = new Array<Circle>();
		for (site in _sites)
		{
			//var radius:Float = 0;
			var nearestEdge:Edge = site.nearestEdge();
			
			var radius = (!nearestEdge.isPartOfConvexHull())? (nearestEdge.sitesDistance() * 0.5): 0;
			//!nearestEdge.isPartOfConvexHull() && (radius = nearestEdge.sitesDistance() * 0.5);
			circles.push(new Circle(site.x, site.y, radius));
		}
		return circles;
	}

	public function regions(plotBounds:Rectangle):Array<Array<Point>>
	{
		var regions:Array<Array<Point>> = new Array<Array<Point>>();
		for (site in _sites)
		{
			regions.push(site.region(plotBounds));
		}
		return regions;
	}
	
	/**
	 * 
	 * @param proximityMap a BitmapData whose regions are filled with the site index values; see PlanePointsCanvas::fillRegions()
	 * @param x
	 * @param y
	 * @return coordinates of nearest Site to (x, y)
	 * 
	 */
	public function nearestSitePoint(proximityMap:BitmapData, x:Int, y:Int):Point
	{
		var index:Int = proximityMap.getPixel(x, y);
		if (index > _sites.length - 1)
		{
			return null;
		}
		return _sites[index].coord;
	}
	
}