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
#import "CYGPointCreationViewController.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGUser.h"
#import "CYGPointAnnotation.h"
#import "MRProgress.h"
#import "TSMessage.h"

@interface CYGMapViewController () <MKMapViewDelegate>

@property (strong, nonatomic)  NSArray *tags;
@property (strong, nonatomic)  NSMutableArray *annotations;
@property (strong, nonatomic)  MKMapView *mapView;
@property (strong, nonatomic)  UIToolbar *toolbar;
@property (strong, nonatomic)  UIButton *userLocationButton;
@property (assign, nonatomic)  BOOL mapViewIsOpen;

@end

@implementation CYGMapViewController


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kCYGPointAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kCYGPointAnnotationIdentifier];
        annotationView.pinColor = MKPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
        annotationView.draggable = YES;
        annotationView.animatesDrop = YES;
    }
    return annotationView;
}

#pragma mark - Private

- (void)centerMapUserLocation
{
    CLLocation *location = [[CYGManager sharedManager] currentLocation] ?: self.mapView.userLocation.location;
    if (location) {
        [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    }
}

- (void)zoomMapViewToFitAnnotationsWithUserLocation:(BOOL)fitToUserLocation
{
    NSArray *annotations = self.mapView.annotations;
    if (fitToUserLocation) {
        annotations = [annotations arrayByAddingObject:self.mapView.userLocation];
    }
    [self.mapView showAnnotations:annotations animated:YES];
}

- (void)pointAnnotationUpdated:(CYGPoint *)aPoint
{
    // TODO: Check to see if you editted point is currently visible.
}


- (void)refreshOnMapViewRegion
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    CLLocationDistance filterDistanceKm = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)/1000;
    filterDistanceKm = MAX(kCYGMinFilterDistanceInKilometers, filterDistanceKm);
    filterDistanceKm = MIN(kCYGMaxFilterDistanceInKilometers, filterDistanceKm);
    
    PFQuery *query = [CYGPoint query];
    [query setLimit:kCYGMaxQueryLimit];
    [query whereKey:kCYGPointLocationKey
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude
                                           longitude:self.mapView.centerCoordinate.longitude]
   withinKilometers:filterDistanceKm];
    [query whereKey:kCYGPointTagsKey containsAllObjectsInArray:self.tags];
    [query includeKey:kCYGPointAuthorKey];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"\n OBJECTS RETRIEVED: %lu \n ", (unsigned long)objects.count);
        
		if (error) {
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching points." type:TSMessageNotificationTypeError];
		} else {
            if (objects.count == 0) {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                [TSMessage showNotificationWithTitle:@"No results." subtitle:@"Sorry! :(" type:TSMessageNotificationTypeError];
                [self.mapView removeAnnotations:self.annotations];
                [self.annotations removeAllObjects];
                return;
            }
            
			// 1. Find genuinely new points:
			NSMutableArray *newPointAnnotations = [[NSMutableArray alloc] initWithCapacity:kCYGMaxQueryLimit/10];
			for (CYGPoint *newPoint in objects) {
				BOOL found = NO;
				for (CYGPointAnnotation *currentAnnotation in self.annotations) {
					if ([newPoint isEqual:currentAnnotation.point]) {
						found = YES;
                        break;
					}
				}
				if (!found) {
					[newPointAnnotations addObject:[[CYGPointAnnotation alloc] initWithPoint:newPoint]];
				}
			}
            
			// 2. Find currently presented point that didn't return with new results:
			NSMutableArray *annotationsToRemove = [[NSMutableArray alloc] initWithCapacity:kCYGMaxQueryLimit/10];
			for (CYGPointAnnotation *currentAnnotation in self.annotations) {
				BOOL found = NO;
				for (CYGPoint *newPoint in objects) {
					if ([newPoint isEqual:currentAnnotation.point]) {
						found = YES;
                        break;
					}
				}
				if (!found) {
					[annotationsToRemove addObject:currentAnnotation];
				}
			}
            
			[self.mapView removeAnnotations:annotationsToRemove];
			[self.mapView addAnnotations:newPointAnnotations];
			[self.annotations addObjectsFromArray:newPointAnnotations];
			[self.annotations removeObjectsInArray:annotationsToRemove];
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            [self zoomMapViewToFitAnnotationsWithUserLocation:YES];
		}
    }];
}


- (void)addPoint
{
    CYGPointCreationViewController *creationViewController = [[CYGPointCreationViewController alloc] init];
    creationViewController.tags = [self.tags copy];
    creationViewController.point.location = ({
        CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude
                                                                longitude:self.mapView.centerCoordinate.longitude];
        [PFGeoPoint geoPointWithLocation:centerLocation];
    });
    [self.navigationController pushViewController:creationViewController animated:YES];
}

#pragma mark - NSOBject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCYGNotificationPointAnnotationUpdated object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapViewIsOpen = YES;
    
    self.mapView = [MKMapView autoLayoutView];
    [self.view addSubview:self.mapView];
    [self.mapView pinToSuperviewEdgesWithInset:UIEdgeInsetsZero];
    self.mapView.opaque = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    self.mapView.tintColor = [UIColor cyg_greenColor];

    self.userLocationButton = [UIButton autoLayoutView];
    [self.mapView addSubview:self.userLocationButton];
    [self.userLocationButton pinToSuperviewEdges:JRTViewPinTopEdge inset:25];
    [self.userLocationButton pinToSuperviewEdges:JRTViewPinLeftEdge inset:10];
    [self.userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.userLocationButton setBackgroundImage:[UIImage imageNamed:@"user-location-icon"] forState:UIControlStateNormal];
    [self.userLocationButton setAlpha:0.8];

    self.toolbar = [UIToolbar autoLayoutView];
    [self.view addSubview:self.toolbar];
    [self.toolbar pinToSuperviewEdges:(JRTViewPinBottomEdge | JRTViewPinLeftEdge | JRTViewPinRightEdge) inset:0];
    [self.toolbar constrainToHeight:56];
    self.toolbar.translucent = YES;

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *tagButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tag-icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(addPoint)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"refresh-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(refreshOnMapViewRegion)];
    
    tagButton.tintColor = [UIColor cyg_blueColor];
    refreshButton.tintColor = [UIColor cyg_greenColor];
    listButton.tintColor = [UIColor whiteColor];
    self.toolbar.items = @[listButton, flexibleSpace, tagButton, flexibleSpace, addButton, flexibleSpace, refreshButton];;
    
    [[[[RACObserve([CYGManager sharedManager], currentLocation) ignore:nil] take:1] deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(CLLocation *location) {
         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude),
                                                                        kCYGRegionLargeBufferInMeters,
                                                                        kCYGRegionLargeBufferInMeters);
         [self.mapView setRegion:region animated:NO];
         [self refreshOnMapViewRegion];
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
        _annotations = [[NSMutableArray alloc] initWithCapacity:kCYGMaxQueryLimit/10];
        //TODO: get cached tags in userDefaults self.tags == ??

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pointAnnotationUpdated:)
                                                     name:kCYGNotificationPointAnnotationUpdated object:nil];
         }
    return self;
}

@end
