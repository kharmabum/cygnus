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
#import "CYGListViewController.h"
#import "CYGTagsViewController.h"
#import "CYGPointCreationViewController.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGUser.h"
#import "CYGMapView.h"
#import "CYGToolbar.h"
#import "CYGPointAnnotation.h"
#import "CYGPointCreationView.h"
#import "MRProgress.h"
#import "TSMessage.h"

@interface CYGMainViewController () <MKMapViewDelegate, UITextFieldDelegate, PFLogInViewControllerDelegate>

@property (strong, nonatomic, readwrite) CYGListViewController *listViewController;
@property (strong, nonatomic, readwrite) CYGTagsViewController *tagsViewController;
@property (strong, nonatomic, readwrite) CYGPointCreationViewController *pointCreationViewController;
@property (strong, nonatomic) UIViewController *activeViewController;

@property (strong, nonatomic)  NSArray *tags;
@property (strong, nonatomic)  NSMutableArray *annotations;
@property (strong, nonatomic)  CYGPointAnnotation *focusedPointAnnotation;
@property (strong, nonatomic)  CYGMapView *mapView;
@property (strong, nonatomic)  CYGToolbar *toolbar;
@property (assign, nonatomic)  BOOL keyboardIsVisible;
@property (strong, nonatomic)  UITapGestureRecognizer *tapGestureRecognizer;

@property (strong, nonatomic)  NSArray *fullMapConstraints;
@property (strong, nonatomic)  NSArray *partialMapConstraints;

@end

@implementation CYGMainViewController

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (user.isNew) {
        debug(@"User signed up and logged in with Twitter!");
    }
    else {
        debug(@"User logged in with Twitter!");
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error { NSLog(@"didFailToLogin"); }
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController { NSLog(@"didCancelLogin"); }

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kCYGPointAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kCYGPointAnnotationIdentifier];
        annotationView.pinColor = MKPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *aV;
    for (aV in views) {
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        CGRect endFrame = aV.frame;
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        [UIView animateWithDuration:0.5 delay:0.04 * [views indexOfObject:aV] options:UIViewAnimationOptionCurveLinear animations:^{
            aV.frame = endFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
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


- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    // End any editting.
    if (self.keyboardIsVisible) {
        [self.view endEditing:YES];
    }
    // Otherwise if map-tap, open map.
    else if ([self.mapView pointInside:[gestureRecognizer locationInView:self.mapView] withEvent:nil]) {
        [self openMapView];
    }
}


#pragma mark - Private

- (void)clearMap
{
    [self.mapView removeAnnotations:self.annotations];
    [self.annotations removeAllObjects];
}

- (void)openMapView
{
    
}

- (void)closeMapView
{
    
}

- (void)addTapGestureRecognizer
{
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    }
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)animateNetworkActivity:(BOOL)shouldAnimate
{
    if (shouldAnimate) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.toolbar startSpinningRefreshButton];
    } else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.toolbar stopSpinningRefreshButton];
    }
}

- (void)refreshOnMapViewRegion
{
    [self animateNetworkActivity:YES];
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
            [self animateNetworkActivity:NO];
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching points." type:TSMessageNotificationTypeError];
		}
        else {
            
            if (objects.count == 0) {
                [self animateNetworkActivity:NO];
                [TSMessage showNotificationWithTitle:@"No results." subtitle:@"Sorry! :(" type:TSMessageNotificationTypeError];
                [self clearMap];
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
            [self animateNetworkActivity:NO];
            [self.mapView zoomToFitAnnotationsWithUserLocation:YES];
		}
    }];
}

#pragma mark - NSOBject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCYGNotificationPointAnnotationUpdated object:nil];
}

#pragma mark - CYGMainViewController

- (void)switchToMapView
{
    [self switchToMapViewWithCompletion:NULL];
}

- (void)switchToMapViewWithCompletion:(void (^)(void))completion
{
    if (self.activeViewController) {
        [self.activeViewController willMoveToParentViewController:nil];
        [self.partialMapConstraints makeObjectsPerformSelector:NSSelectorFromString(@"remove")];
        [self.fullMapConstraints makeObjectsPerformSelector:NSSelectorFromString(@"install")];
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self.view layoutIfNeeded];
                             self.mapView.userLocationButton.alpha = 1.0;
                             self.toolbar.listButton.transform = CGAffineTransformRotate(self.toolbar.listButton.transform, M_PI/2.0f);
                         } completion:^(BOOL finished) {
                             [self.activeViewController.view removeFromSuperview];
                             [self.activeViewController removeFromParentViewController];
                             self.activeViewController = nil;
                             if (completion) completion();
                         }];
    }
    else {
        if (completion) completion();
    }
}

- (void)switchToListView
{
    [self switchToListViewWithCompletion:NULL];
}

- (void)switchToTagView
{
    [self switchToTagViewWithCompletion:NULL];
}

- (void)switchToPointCreationView
{
    [self switchToPointCreationViewWithCompletion:NULL];
}

- (void)switchToListViewWithCompletion:(void (^)(void))completion
{
    [self switchToChildViewController:self.pointCreationViewController withCompletion:completion];
}

- (void)switchToTagViewWithCompletion:(void (^)(void))completion
{
    [self switchToChildViewController:self.pointCreationViewController withCompletion:completion];
}

- (void)switchToPointCreationViewWithCompletion:(void (^)(void))completion
{
 
    [self switchToChildViewController:self.pointCreationViewController withCompletion:^{
        
        CYGPoint *newPoint = [[CYGPoint alloc] init];
        newPoint.location = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
        CYGPointAnnotation *newAnnotation = [[CYGPointAnnotation alloc] initWithPoint:newPoint];
        newAnnotation.isNewlyCreatedPoint = YES;
        
        self.pointCreationViewController.point = newPoint;
        
        [self clearMap];
        [self.mapView addAnnotation:newAnnotation];
        [self.annotations addObject:newAnnotation];
        [self.mapView focusOnCoordinate:newAnnotation.coordinate withBufferDistance:kCYGRegionSmallBufferInMeters];
        
        if (completion) completion();
    }];
    
    // Require user be logged in (for Parse saveEventually:)
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.fields = PFLogInFieldsTwitter; //| PFLogInFieldsDismissButton;
        logInViewController.logInView.logo = nil;
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }

    
}

- (void)switchToChildViewController:(UIViewController *)childViewController withCompletion:(void (^)(void))completion
{
    [self switchToMapViewWithCompletion:^{
        
        [self addChildViewController:childViewController];
        [self.view insertSubview:childViewController.view belowSubview:self.mapView];
        [childViewController.view constrainToWidthOfView:self.view];
        [childViewController.view pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:self.toolbar];
        [childViewController.view pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];
        [self.view layoutIfNeeded];


        //animations with completion
        [self.fullMapConstraints makeObjectsPerformSelector:NSSelectorFromString(@"remove")];
        self.partialMapConstraints = @[
                                       [self.mapView pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:childViewController.view],
                                       [self.mapView constrainToHeight:140]
                                       ];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [self.view layoutIfNeeded];
                             self.mapView.userLocationButton.alpha = 0;
                             self.toolbar.listButton.transform = CGAffineTransformRotate(self.toolbar.listButton.transform, M_PI/2.0f);
                         } completion:^(BOOL finished) {
                             
                             [childViewController didMoveToParentViewController:self];
                             self.activeViewController = childViewController;
                             if (completion) completion();
                         }];
    }];
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
    [self.toolbar.addButton addTarget:self action:@selector(switchToPointCreationView) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.listButton addTarget:self action:@selector(switchToMapView) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.refreshButton addTarget:self action:@selector(refreshOnMapViewRegion) forControlEvents:UIControlEventTouchUpInside];
    
    // Constraints
    
    [self.mapView pinEdges:(FTUIViewEdgePinTop | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];
    NSLayoutConstraint *mapViewBottomConstraint = [self.mapView pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:self.toolbar];

    [self.toolbar pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight | FTUIViewEdgePinBottom) toSuperViewWithInset:0];
    [self.toolbar constrainToHeight:kCYGMapViewControllerTabBarHeight];

    self.fullMapConstraints = @[mapViewBottomConstraint];

    // Additional setup
    [[CYGManager sharedManager] findCurrentLocation];
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
        _listViewController = [[CYGListViewController alloc] init];
        _tagsViewController = [[CYGTagsViewController alloc] init];
        _pointCreationViewController = [[CYGPointCreationViewController alloc] init];
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
