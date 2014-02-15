//
//  CYGMapView.h
//  Cygnus
//
//  Created by IO on 2/15/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import MapKit;

@class CYGPointAnnotation;

@interface CYGMapView : MKMapView

@property (strong, nonatomic)  UIButton *userLocationButton;

- (void)centerMapUserLocation;
- (void)zoomToFitAnnotationsWithUserLocation:(BOOL)fitToUserLocation;
- (void)focusOnCoordinate:(CLLocationCoordinate2D)coordinate;
- (CYGPointAnnotation *)updateWithAnnotation:(CYGPointAnnotation *)annotation;

@end
