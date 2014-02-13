//
//  CYGPointAnnotation.m
//  Cygnus
//
//  Created by IO on 2/12/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGPointAnnotation.h"
#import "CYGPoint.h"

@interface CYGPointAnnotation ()

@property (nonatomic, strong) CYGPoint *point;

@end
@implementation CYGPointAnnotation

#pragma mark - Initialization

- (id)initWithPoint:(CYGPoint *)aPoint
{
    self = [super init];
    if (self) {
        _point = aPoint;
        
        PFGeoPoint *geoPoint = self.point.location;
        [self setGeoPoint:geoPoint];
    }
    return self;
}

#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    [self setGeoPoint:geoPoint];
    self.point.location = geoPoint;
    [self.point saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationPointAnnotationUpdated object:self.point];
        }
    }];
}


#pragma mark - ()

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    _coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    
    static NSNumberFormatter *_numberFormatter = nil;
    if (_numberFormatter == nil) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.maximumFractionDigits = 3;
    }
    
    _title = self.point.title;
    _subtitle = [NSString stringWithFormat:@"%@, %@", [_numberFormatter stringFromNumber:@(geoPoint.latitude)],
                 [_numberFormatter stringFromNumber:@(geoPoint.longitude)]];
}

@end
