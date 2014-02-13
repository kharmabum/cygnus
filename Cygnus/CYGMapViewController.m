//
//  CYGMapViewController.m
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import MapKit;
@import CoreLocation;
@import CoreGraphics;

#import "CYGMapViewController.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGUser.h"
#import "CYGPointAnnotation.h"

@interface CYGMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic)  UIToolbar *toolbar;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) BOOL mapViewIsOpen;


@end

@implementation CYGMapViewController


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kCYGPointAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kCYGPointAnnotationIdentifier];
        annotationView.pinColor = MKPinAnnotationColorPurple;
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        annotationView.animatesDrop = YES;
    }
    return annotationView;
}

#pragma mark - Private

- (void)centerMapUserLocation
{
    [self.mapView setCenterCoordinate:[[CYGManager sharedManager] currentLocation].coordinate animated:YES];
}

- (void)addPointAtCurrentLocation
{
	CLLocation *location = [[CYGManager sharedManager] currentLocation];
	if (!location) {
		return;
	}
    
    static NSDateFormatter *_dateFormatter = nil;
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
	CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude+1 longitude:coordinate.longitude+1];
    __block CYGPoint *newPoint = [CYGPoint object];
    newPoint.location = geoPoint;
    newPoint.author = [CYGUser currentUser];
    newPoint.tags = @[@"test"];
    newPoint.title = [_dateFormatter stringFromDate:[NSDate date]];

    [newPoint saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(newPoint.location.latitude, newPoint.location.longitude), kCYGRegionBufferInMeters, kCYGRegionBufferInMeters);
            [self.mapView setRegion:region animated:YES];
            CYGPointAnnotation *annotation = [[CYGPointAnnotation alloc] initWithPoint:newPoint];
            [self.mapView addAnnotation:annotation];
        }
    }];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapViewIsOpen = YES;
    self.mapView = [MKMapView autoLayoutView];
    self.mapView.opaque = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.mapView pinToSuperviewEdgesWithInset:UIEdgeInsetsZero];
    
    self.toolbar = [UIToolbar autoLayoutView];
    self.toolbar.translucent = YES;
    [self.view addSubview:self.toolbar];
    [self.toolbar pinToSuperviewEdges:(JRTViewPinBottomEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge) inset:0];
    [self.toolbar constrainToHeight:50];

//    UIBarButtonItem *locationButton;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tag-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(addPointAtCurrentLocation)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    NSArray *buttons = @[listButton, flexibleSpace, tagButton, flexibleSpace, addButton, flexibleSpace, refreshButton];
    self.toolbar.items = buttons;
    
    
    
    [[[[RACObserve([CYGManager sharedManager], currentLocation)
        ignore:nil]
       take:1]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(CLLocation *location) {
         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), kCYGRegionBufferInMeters, kCYGRegionBufferInMeters);
         [self.mapView setRegion:region animated:YES];
     }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[CYGManager sharedManager] findCurrentLocation];        
    }
    return self;
}

@end
