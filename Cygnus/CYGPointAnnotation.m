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

@property (nonatomic, strong, readwrite) CYGPoint *point;

@end

static NSNumberFormatter *_numberFormatter = nil;
static NSDateFormatter *_dateFormatter = nil;


@implementation CYGPointAnnotation

+ (NSNumberFormatter *)numberFormatter
{
    if (!_numberFormatter) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.maximumFractionDigits = 3;
    }
    return _numberFormatter;
}

+ (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

#pragma mark - Initialization

- (id)initWithPoint:(CYGPoint *)aPoint
{
    self = [super init];
    if (self) {
        _point = aPoint;
        _coordinate = CLLocationCoordinate2DMake(aPoint.location.latitude, aPoint.location.longitude);
        
        // Bindings
        __weak __typeof(&*self)weakSelf = self;
        RAC(self, title) = [[RACObserve(self.point, title) deliverOn:RACScheduler.mainThreadScheduler]
                            map:^id(NSString *title) {
                                return (title) ?: [[CYGPointAnnotation dateFormatter] stringFromDate:weakSelf.point.createdAt];
                            }];
        RAC(self, subtitle) = [[RACObserve(self.point, location) deliverOn:RACScheduler.mainThreadScheduler]
                            map:^id(PFGeoPoint *geoPoint) {
                                return [NSString stringWithFormat:@"%@, %@",
                                        [[CYGPointAnnotation numberFormatter] stringFromNumber:@(geoPoint.latitude)],
                                        [[CYGPointAnnotation numberFormatter] stringFromNumber:@(geoPoint.longitude)]];
                            }];
                            
}
    return self;
}

#pragma mark - MKAnnotation

// Called when the annotation is dragged and dropped. Updates the backing point with new coordinates if it's not being created.
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
    self.point.location = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
    if (!self.isNewlyCreatedPoint) {
        [self.point saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationPointAnnotationUpdated object:self.point];
                NSLog(@"Point annotation updated.");
            }
        }];
    }
}

@end
