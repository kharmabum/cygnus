//
//  CYGPointAnnotation.h
//  Cygnus
//
//  Created by IO on 2/12/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import MapKit;
@class CYGPoint;

@interface CYGPointAnnotation : NSObject <MKAnnotation>

- (id)initWithPoint:(CYGPoint *)aPoint;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@end
