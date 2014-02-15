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

#import "CYGMainViewController.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGUser.h"
#import "CYGMapView.h"
#import "CYGToolbar.h"
#import "CYGPointAnnotation.h"
#import "CYGPointCreationView.h"
#import "MRProgress.h"
#import "TSMessage.h"

@interface CYGMainViewController () <MKMapViewDelegate>

@property (strong, nonatomic)  NSArray *tags;
@property (strong, nonatomic)  NSMutableArray *annotations;
@property (strong, nonatomic)  CYGMapView *mapView;
@property (strong, nonatomic)  CYGToolbar *toolbar;

@property (strong, nonatomic)  UIView *activeView;


@end

@implementation CYGMainViewController


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

#pragma mark - Actions, Gestures, Notification Handlers

- (void)pointAnnotationDidUpdate:(NSNotification*)aNotification
{
    CYGPoint *updatedPoint = aNotification.object;
    BOOL shouldBeOnMap = YES;
    for (NSString *tag in self.tags) {
        if (![updatedPoint.tags containsObject:tag]) {
            shouldBeOnMap = NO;
            break;
        }
    }
    if (shouldBeOnMap) {
        CYGPointAnnotation *newAnnotation = [[CYGPointAnnotation alloc] initWithPoint:updatedPoint];
        CYGPointAnnotation *oldAnnotation = [self.mapView updateWithAnnotation:newAnnotation];
        [self.annotations addObject:newAnnotation];
        if (oldAnnotation) [self.annotations removeObject:oldAnnotation];

    }
    
}

#pragma mark - Private

- (void)refreshOnMapViewRegion
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
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
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching points." type:TSMessageNotificationTypeError];
		} else {
            if (objects.count == 0) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
            
			// 2. Find currently presented point that didn't return with new results.
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
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.mapView zoomToFitAnnotationsWithUserLocation:YES];
		}
    }];
}


- (void)addPoint
{
//    CYGPointCreationViewController *creationViewController = [[CYGPointCreationViewController alloc] init];
//    creationViewController.tags = [self.tags copy];
//    creationViewController.point.location = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude
//                                                                   longitude:self.mapView.centerCoordinate.longitude];
//    [self.navigationController pushViewController:creationViewController animated:YES];
}

#pragma mark - NSOBject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCYGNotificationPointAnnotationUpdated object:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // View
    
    self.mapView = [[CYGMapView alloc] init];
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;

    self.toolbar = [[CYGToolbar alloc] init];
    [self.view addSubview:self.toolbar];
    [self.toolbar.addButton addTarget:self action:@selector(addPoint) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.refreshButton addTarget:self action:@selector(refreshOnMapViewRegion) forControlEvents:UIControlEventTouchUpInside];
    
    self.activeView = [[CYGPointCreationView alloc] init];
    [self.view addSubview:self.activeView];
    [self.activeView pinEdges:CYGUIViewEdgePinAll toSuperViewWithInset:0];
    
    // Constraints
    
    [self.mapView pinEdges:(CYGUIViewEdgePinTop | CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:0];
    [self.mapView pinEdge:CYGUIViewEdgePinBottom toEdge:CYGUIViewEdgePinTop ofItem:self.toolbar];
    
    [self.toolbar pinEdges:(CYGUIViewEdgePinBottom | CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:0];
    [self.toolbar constrainToHeight:kCYGMapViewControllerTabBarHeight];

    // Actions
    
    [[[[RACObserve([CYGManager sharedManager], currentLocation) ignore:nil] take:1] deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(CLLocation *location) {
         [self.mapView focusOnCoordinate:location.coordinate withBufferDistance:kCYGRegionLargeBufferInMeters];
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
    
    // Welcome animation
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self performBlockOnMainThread:^{
            [self.toolbar animateButtonColors];
        } afterDelay:0.3];
    });
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
        _tags = @[@"test"];
        //TODO: get cached tags in userDefaults self.tags == ??
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pointAnnotationDidUpdate:)
                                                     name:kCYGNotificationPointAnnotationUpdated object:nil];
    }
    return self;
}

@end
