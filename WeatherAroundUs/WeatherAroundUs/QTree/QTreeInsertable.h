//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

@import CoreLocation;

@protocol QTreeInsertable<NSObject>

@property(nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, assign, readonly) NSString * cityID;

@end
