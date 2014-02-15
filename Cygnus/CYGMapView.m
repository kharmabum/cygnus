//
//  CYGMapView.m
//  Cygnus
//
//  Created by IO on 2/15/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGMapView.h"
#import "CYGPoint.h"
#import "CYGPointAnnotation.h"

@implementation CYGMapView

#pragma mark - Actions, Gestures, Notification Handlers

- (void)centerMapUserLocation
{
    CLLocation *location = self.userLocation.location;
    if (location) {
        [self setCenterCoordinate:location.coordinate animated:YES];
    }
}

- (void)zoomToFitAnnotationsWithUserLocation:(BOOL)fitToUserLocation
{
    NSArray *annotations = self.annotations;
    if (fitToUserLocation) {
        annotations = [annotations arrayByAddingObject:self.userLocation];
    }
    [self showAnnotations:annotations animated:YES];
}

- (void)focusOnCoordinate:(CLLocationCoordinate2D)coordinate withBufferDistance:(CLLocationDistance)buffer;
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude),
                                                                   buffer,
                                                                   buffer);
    [self setRegion:region animated:NO];
}



#pragma mark - Private

- (CYGPointAnnotation *)updateWithAnnotation:(CYGPointAnnotation *)newAnnotation
{
    // Find presented annotation that's just been updated.
    CYGPointAnnotation *oldAnnotation;
    for (CYGPointAnnotation *currentAnnotation in self.annotations) {
        if ([newAnnotation.point.objectId isEqualToString:currentAnnotation.point.objectId]) {
            oldAnnotation = currentAnnotation;
            break;
        }
    }
    
    [self addAnnotation:newAnnotation];
    [self zoomToFitAnnotationsWithUserLocation:YES];
    if (oldAnnotation) [self removeAnnotation:oldAnnotation];
    return oldAnnotation;
}


#pragma mark - UIView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.opaque = YES;
        self.showsUserLocation = YES;
        self.tintColor = [UIColor cyg_greenColor];
        
        _userLocationButton = [UIButton autoLayoutView];
        [self addSubview:self.userLocationButton];
        [_userLocationButton pinEdges:CYGUIViewEdgePinTop toSuperViewWithInset:25];
        [_userLocationButton pinEdges:CYGUIViewEdgePinLeft toSuperViewWithInset:10];
        [_userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];
        [_userLocationButton setBackgroundImage:[UIImage imageNamed:@"user-location-icon"] forState:UIControlStateNormal];
        [_userLocationButton setAlpha:0.8];

    }
    return self;
}


@end
