//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "QNode.h"
#import "QTreeGeometryUtils.h"

static const CLLocationDistance MinDistinguishableMetersDistance = 0.5;

static CLLocationDegrees DegreesMetric(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2)
{
  return sqrt(pow(c1.latitude - c2.latitude, 2) + pow(c1.longitude - c2.longitude, 2));
}

static CLLocationCoordinate2D MeanCoordinate(NSArray* insertableObjects)
{
  CLLocationDegrees meanLatitude = 0;
  CLLocationDegrees meanLongitude = 0;
  for( id<QTreeInsertable> object in insertableObjects ) {
    meanLongitude += object.coordinate.longitude;
    meanLatitude += object.coordinate.latitude;
  }
  meanLatitude /= insertableObjects.count;
  meanLongitude /= insertableObjects.count;
  return CLLocationCoordinate2DMake(meanLatitude, meanLongitude);
}

static CLLocationDegrees CircumscribedDegreesRadius(NSArray* insertableObjects, CLLocationCoordinate2D center)
{
  CLLocationDegrees radius = 0;
  for( id<QTreeInsertable> object in insertableObjects ) {
    radius = MAX(radius, DegreesMetric(object.coordinate, center));
  }
  return radius;
}

@interface QNode()

@property(nonatomic, assign) MKCoordinateRegion region;

@property(nonatomic, strong) id<QTreeInsertable> leadObject;
@property(nonatomic, strong) NSMutableSet* satellites;

@property(nonatomic, assign) NSUInteger count;

@property(nonatomic, strong) QCluster* cachedCluster;

@property(nonatomic, retain) QNode* upLeft;
@property(nonatomic, retain) QNode* upRight;
@property(nonatomic, retain) QNode* downLeft;
@property(nonatomic, retain) QNode* downRight;

@end

@implementation QNode

+(instancetype)nodeWithRegion:(MKCoordinateRegion)region
{
  return [[QNode alloc] initWithRegion:region];
}


-(id)initWithRegion:(MKCoordinateRegion)region
{
  self = [super init];
  if( !self ) {
    return nil;
  }
  self.region = region;
  return self;
}

-(CLLocationDegrees)centerLatitude
{
  return self.region.center.latitude;
}

-(CLLocationDegrees)centerLongitude
{
  return self.region.center.longitude;
}

-(BOOL)isLeaf
{
  return !self.upLeft && !self.downLeft && !self.upRight && !self.downRight;
}

-(BOOL)insertObject:(id<QTreeInsertable>)insertableObject
{
  if( self.leadObject ) {
    if( CLMetersBetweenCoordinates(self.leadObject.coordinate, insertableObject.coordinate) >= MinDistinguishableMetersDistance ) {
      // Move self objects deeper
      NSAssert([self isLeaf], @"Node containing objects should be a leaf");
      [self insertLeadObject:self.leadObject withSatellites:self.satellites];
      self.leadObject = nil;
      self.satellites = nil;
    } else {
      if( ![self.leadObject isEqual:insertableObject] ) {
        self.count += 1;
        self.cachedCluster = nil;
        if( !self.satellites ) {
          self.satellites = [NSMutableSet set];
        }
        [self.satellites addObject:insertableObject];
        return YES;
      } else {
        // Can't distinguish two objects
        return NO;
      }
    }
  }
  if( [self insertLeadObject:insertableObject withSatellites:nil] ) {
    self.count += 1;
    return YES;
  } else {
    return NO;
  }
}

-(BOOL)removeObject:(id<QTreeInsertable>)insertableObject
{
  if( self.leadObject ) {
    if( [self.satellites containsObject:insertableObject] ) {
      [self.satellites removeObject:insertableObject];
      self.cachedCluster = nil;
      self.count -= 1;
      return YES;
    } else if( [self.leadObject isEqual:insertableObject] ) {
      self.leadObject = [self.satellites anyObject];
      if( self.leadObject ) {
        [self.satellites removeObject:self.leadObject];
      } // else should delete this node then
      self.cachedCluster = nil;
      self.count -= 1;
      return YES;
    } else {
      return NO;
    }
  }

  QNode* __strong *pNode = [self childNodeForObject:insertableObject];

  if( *pNode ) {
    BOOL result = [*pNode removeObject:insertableObject];
    if( result ) {
      self.cachedCluster = nil;
      self.count -= 1;
      if( (*pNode).count == 0 ) {
        *pNode = nil;
      }
      QNode* __strong *pChild = [self theOnlyChildNode];
      if( pChild != nil && [(*pChild) isLeaf] ) {
        self.leadObject = (*pChild).leadObject;
        self.satellites = (*pChild).satellites;
        NSAssert(self.count == (*pChild).count, @"Should be in sync already");
        *pChild = nil;
      }
    }
    return result;
  } else {
    return NO;
  }
}

-(QNode* __strong *)childNodeForObject:(id<QTreeInsertable>)insertableObject
{
  QNode* __strong *pNode = nil;

  const BOOL down = insertableObject.coordinate.latitude < self.centerLatitude;
  const BOOL left = insertableObject.coordinate.longitude < self.centerLongitude;

  if( down ) {
    if( left ) {
      pNode = &_downLeft;
    } else {
      pNode = &_downRight;
    }
  } else {
    if( left ) {
      pNode = &_upLeft;
    } else {
      pNode = &_upRight;
    }
  }

  return pNode;
}

// returns nil if there are more than one child
-(QNode* __strong *)theOnlyChildNode
{
  QNode* __strong *pChild = nil;

  while( YES ) {
    if( self.upLeft ) {
      pChild = &_upLeft;
    }
    if( self.downLeft ) {
      if( pChild ) {
        pChild = nil;
        break;
      }
      pChild = &_downLeft;
    }
    if( self.upRight ) {
      if( pChild ) {
        pChild = nil;
        break;
      }
      pChild = &_upRight;
    }
    if( self.downRight ) {
      if( pChild ) {
        pChild = nil;
        break;
      }
      pChild = &_downRight;
    }
    break;
  }

  return pChild;
}

-(BOOL)insertLeadObject:(id<QTreeInsertable>)leadObject withSatellites:(NSSet*)satellites
{
  self.cachedCluster = nil;

  QNode* __strong *pNode = [self childNodeForObject:leadObject];

  if( !*pNode ) {
    const BOOL down = leadObject.coordinate.latitude < self.centerLatitude;
    const BOOL left = leadObject.coordinate.longitude < self.centerLongitude;

    const CLLocationDegrees latDeltaBy2 = self.region.span.latitudeDelta / 2;
    const CLLocationDegrees newLat = self.centerLatitude + latDeltaBy2 * (down ? -1 : +1) / 2;

    const CLLocationDegrees lngDeltaBy2 = self.region.span.longitudeDelta / 2;
    const CLLocationDegrees newLng = self.centerLongitude + lngDeltaBy2 * (left ? -1 : +1) / 2;

    const CLLocationCoordinate2D newCenter = CLLocationCoordinate2DMake(newLat, newLng);
    const MKCoordinateSpan newSpan = MKCoordinateSpanMake(latDeltaBy2, lngDeltaBy2);

    QNode* newNode = [QNode nodeWithRegion:MKCoordinateRegionMake(newCenter, newSpan)];
    newNode.leadObject = leadObject;
    newNode.satellites = [satellites mutableCopy];
    newNode.count = 1 + satellites.count;

    *pNode = newNode;

    return YES;
  } else {
    NSAssert(!satellites, @"Satellites should be non-nil only when moving objects deeper");
    return [*pNode insertObject:leadObject];
  }
}

-(NSArray*)getObjectsInRegion:(MKCoordinateRegion)region minNonClusteredSpan:(CLLocationDegrees)span
{
  if( !MKCoordinateRegionIntersectsRegion(self.region, region) ) {
    return @[];
  }
  NSMutableArray* result = [NSMutableArray array];
  if( self.leadObject ) {
    if( MKCoordinateRegionContainsCoordinate(region, self.leadObject.coordinate) ) {
      [result addObject:self.leadObject];
      [result addObjectsFromArray:self.satellites.allObjects];
    }
  } else if( MIN(self.region.span.latitudeDelta, self.region.span.longitudeDelta) >= span ) {
    [result addObjectsFromArray:[self.upLeft getObjectsInRegion:region minNonClusteredSpan:span]];
    [result addObjectsFromArray:[self.upRight getObjectsInRegion:region minNonClusteredSpan:span]];
    [result addObjectsFromArray:[self.downLeft getObjectsInRegion:region minNonClusteredSpan:span]];
    [result addObjectsFromArray:[self.downRight getObjectsInRegion:region minNonClusteredSpan:span]];
  } else {
    if( !self.cachedCluster ) {
      QCluster* cluster = [[QCluster alloc] init];

      NSArray* allChildren = [self getObjectsInRegion:self.region minNonClusteredSpan:0];
      CLLocationCoordinate2D meanCenter = MeanCoordinate(allChildren);
      cluster.coordinate = meanCenter;
      cluster.objectsCount = allChildren.count;
      cluster.radius = CircumscribedDegreesRadius(allChildren, meanCenter);

      self.cachedCluster = cluster;
    }
    [result addObject:self.cachedCluster];
  }
  return result;
}

-(QNode*)childNodeForLocation:(CLLocationCoordinate2D)location
{
  if( self.downRight && MKCoordinateRegionContainsCoordinate(self.downRight.region, location) ) {
    return self.downRight;
  } else if( self.downLeft && MKCoordinateRegionContainsCoordinate(self.downLeft.region, location) ) {
    return self.downLeft;
  } else if( self.upRight && MKCoordinateRegionContainsCoordinate(self.upRight.region, location) ) {
    return self.upRight;
  } else if( self.upLeft && MKCoordinateRegionContainsCoordinate(self.upLeft.region, location) ) {
    return self.upLeft;
  } else {
    return nil;
  }
}

@end
