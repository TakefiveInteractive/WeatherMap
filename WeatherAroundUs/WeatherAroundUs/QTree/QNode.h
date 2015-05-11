//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

@import CoreLocation;
@import MapKit;

#import "QCluster.h"

@interface QNode : NSObject

+(instancetype)nodeWithRegion:(MKCoordinateRegion)region;


-(instancetype)initWithRegion:(MKCoordinateRegion)region;

@property(nonatomic, readonly) MKCoordinateRegion region;
@property(nonatomic, readonly) NSUInteger count;
// Shortcuts
@property(nonatomic, readonly) CLLocationDegrees centerLatitude;
@property(nonatomic, readonly) CLLocationDegrees centerLongitude;

-(BOOL)insertObject:(id<QTreeInsertable>)insertableObject;
-(BOOL)removeObject:(id<QTreeInsertable>)insertableObject;

-(NSArray*)getObjectsInRegion:(MKCoordinateRegion)region minNonClusteredSpan:(CLLocationDegrees)span;

-(QNode*)childNodeForLocation:(CLLocationCoordinate2D)location;

@end
