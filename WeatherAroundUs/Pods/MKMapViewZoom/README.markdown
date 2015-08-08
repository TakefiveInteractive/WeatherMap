# About MKMapView category
The included MKMapView category for supporting zoom level, code belongs to Troy Brant
http://troybrant.net/blog/2010/01/mkmapview-and-zoom-levels-a-visual-guide/

If you have ever built a web application using the Google Maps API, you are likely intimately familiar with this line of code:

map.setCenter(new google.maps.LatLng(37.4419, -122.1419), 13);
To implement this you can use the attached category. 

In your view controller where you declare MKMapView simply import "MKMapView+ZoomLevel.h" 


# Example


	MKCoordinateRegion region;
    CLLocationCoordinate2D c;
    c.latitude =  37.4419;
    c.longitude = -122.1419;
    region.center = c;
    [mapView setCenterCoordinate:c zoomLevel:13 animated:YES];



# Note
To get the current zoom level 

	int level = [mapView zoomLevel];


# Questions
http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/


# License
Copyright (c) 2010 Troy Brant

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

