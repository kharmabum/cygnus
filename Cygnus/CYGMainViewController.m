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

@property (strong, nonatomic)  NSMutableArray *annotations;
@property (strong, nonatomic)  CYGPointAnnotation *pointCreationAnnotation;
@property (strong, nonatomic)  CYGMapView *mapView;
@property (strong, nonatomic)  CYGToolbar *toolbar;
@property (assign, nonatomic)  BOOL keyboardIsVisible;

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
    }
    annotationView.canShowCallout = (self.activeViewController != self.pointCreationViewController);
    annotationView.draggable = (self.activeViewController == self.pointCreationViewController);
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

- (void)handleLongPressGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        if (!self.activeViewController) {
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[gestureRecognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
            [self switchToPointCreationViewWithCompletion:NULL andCoordinate:coordinate];
        }
        else if (self.activeViewController == self.pointCreationViewController && [self mapIsOpenForEditing]) {
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[gestureRecognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
            [self.mapView removeAnnotation:self.pointCreationAnnotation];
            self.pointCreationAnnotation.coordinate = coordinate;
            [self.mapView addAnnotation:self.pointCreationAnnotation];
            
        }
    }
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.keyboardIsVisible) {
        [self.view endEditing:YES];
    }
    else if (self.activeViewController && [self.mapView pointInside:[gestureRecognizer locationInView:self.mapView] withEvent:nil]) {
        if (self.activeViewController != self.pointCreationViewController) {
            [self switchToMapView];
        }
        else {
            [self openMapWhileEditing];
        }
        
    }
}

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

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.keyboardIsVisible = YES;
    if ([self mapIsOpenForEditing]) {
        [self closeMapWhileEditing];
    }
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
    self.keyboardIsVisible = NO;
}

- (void)listButtonPressed
{
    if (self.activeViewController) {
        [self switchToMapView];
    } else {
        [self switchToListView];
    }
}

- (void)tagButtonPressed
{
    if (self.activeViewController != self.tagsViewController) {
        [self switchToTagView];
    }
}

- (void)addButtonPressed
{
    if (self.activeViewController != self.pointCreationViewController) {
        [self switchToPointCreationView];
    }
    else if ([self mapIsOpenForEditing]) {
        [self closeMapWhileEditing];
    }
}

#pragma mark - Private

- (BOOL)mapIsOpenForEditing
{
    return (self.activeViewController == self.pointCreationViewController && self.mapView.userLocationButton.alpha);
}

- (void)openMapWhileEditing
{
    [self.partialMapConstraints makeObjectsPerformSelector:NSSelectorFromString(@"remove")];
    self.partialMapConstraints = @[[self.mapView pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:((CYGPointCreationView *)self.pointCreationViewController.view).saveButton]];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.mapView.userLocationButton.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [self.mapView setZoomEnabled:YES];
                         [self.mapView setScrollEnabled:YES];
                         [self.mapView setPitchEnabled:YES];
                         [self.mapView setRotateEnabled:YES];
                     }];
}

- (void)closeMapWhileEditing
{
    [self.partialMapConstraints makeObjectsPerformSelector:NSSelectorFromString(@"remove")];
    self.partialMapConstraints = @[
                                   [self.mapView pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:self.activeViewController.view],
                                   [self.mapView constrainToHeight:150]
                                   ];
    
    [self.mapView setZoomEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    [self.mapView setPitchEnabled:NO];
    [self.mapView setRotateEnabled:NO];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.view layoutIfNeeded];
                         self.mapView.userLocationButton.alpha = 0;
                     } completion:^(BOOL finished) {
                         CLLocationCoordinate2D coordinate = self.pointCreationAnnotation.coordinate;
                         [self.mapView focusOnCoordinate:coordinate withBufferDistance:kCYGRegionSmallBufferInMeters animated:YES];
                     }];
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
    
    PFQuery *query = [CYGPoint query];
    [query setLimit:kCYGMaxQueryLimit];
    [query whereKey:kCYGPointLocationKey
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude
                                           longitude:self.mapView.centerCoordinate.longitude]
   withinKilometers:kCYGMaxFilterDistanceInKilometers];
    [query whereKey:kCYGPointTagsKey containsAllObjectsInArray:self.tags];

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
                [self.mapView removeAnnotations:self.annotations];
                [self.annotations removeAllObjects];
                return;
            }
            
			// 1. Find genuinely new points:
			NSMutableArray *pointCreationAnnotations = [[NSMutableArray alloc] initWithCapacity:kCYGMaxQueryLimit/10];
			for (CYGPoint *newPoint in objects) {
				BOOL found = NO;
				for (CYGPointAnnotation *currentAnnotation in self.annotations) {
					if ([newPoint isEqual:currentAnnotation.point]) {
						found = YES;
                        break;
					}
				}
				if (!found) {
					[pointCreationAnnotations addObject:[[CYGPointAnnotation alloc] initWithPoint:newPoint]];
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
			[self.mapView addAnnotations:pointCreationAnnotations];
			[self.annotations addObjectsFromArray:pointCreationAnnotations];
			[self.annotations removeObjectsInArray:annotationsToRemove];
            [self animateNetworkActivity:NO];
            [self.mapView zoomToFitAnnotationsWithUserLocation:YES];
		}
    }];
}


#pragma mark - CYGMainViewController

- (void)switchToMapView
{
    if (self.activeViewController == self.pointCreationViewController) {
        [self.mapView removeAnnotation:self.pointCreationAnnotation];
        [self.mapView addAnnotations:self.annotations];
        self.pointCreationAnnotation = nil;
    }
    
    [self switchToMapViewWithCompletion:^{
        [self.mapView zoomToFitAnnotationsWithUserLocation:YES];
    }];
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
                             [self.mapView setZoomEnabled:YES];
                             [self.mapView setScrollEnabled:YES];
                             [self.mapView setPitchEnabled:YES];
                             [self.mapView setRotateEnabled:YES];
                             self.toolbar.refreshButton.enabled = YES;
                             
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
    [self switchToListViewWithCompletion:^{
        [self.mapView zoomToFitAnnotationsWithUserLocation:YES];
    }];
}

- (void)switchToTagView
{
    
    if (self.activeViewController == self.pointCreationViewController) {
        [self.mapView removeAnnotation:self.pointCreationAnnotation];
        [self.mapView addAnnotations:self.annotations];
        self.pointCreationAnnotation = nil;
    }
    
    [self switchToTagViewWithCompletion:^{
        [self.mapView zoomToFitAnnotationsWithUserLocation:YES];
    }];
}

- (void)switchToPointCreationView
{
    [self switchToPointCreationViewWithCompletion:NULL andCoordinate:CLLocationCoordinate2DMake(-MAXFLOAT, -MAXFLOAT)];
}

- (void)switchToListViewWithCompletion:(void (^)(void))completion
{
    [self switchToChildViewController:self.listViewController withCompletion:completion];
}

- (void)switchToTagViewWithCompletion:(void (^)(void))completion
{
    [self switchToChildViewController:self.tagsViewController withCompletion:completion];
}

- (void)switchToPointCreationViewWithCompletion:(void (^)(void))completion andCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    [self switchToChildViewController:self.pointCreationViewController withCompletion:^{

        CLLocationCoordinate2D newCoordinate = (CLLocationCoordinate2DIsValid(aCoordinate)) ? aCoordinate : self.mapView.centerCoordinate;
        CYGPoint *newPoint = [CYGPoint object];
        newPoint.location = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
        CYGPointAnnotation *newAnnotation = [[CYGPointAnnotation alloc] initWithPoint:newPoint];
        newAnnotation.isNewlyCreatedPoint = YES;
        
        self.pointCreationViewController.point = newPoint;
        
        self.toolbar.refreshButton.enabled = NO;
        [self.mapView removeAnnotations:self.annotations];
        [self.mapView addAnnotation:newAnnotation];
        self.pointCreationAnnotation = newAnnotation;
        [self.mapView focusOnCoordinate:newAnnotation.coordinate withBufferDistance:kCYGRegionSmallBufferInMeters animated:YES];
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
                                       [self.mapView constrainToHeight:150]
                                       ];
        
        
        [self.mapView setZoomEnabled:NO];
        [self.mapView setScrollEnabled:NO];
        [self.mapView setPitchEnabled:NO];
        [self.mapView setRotateEnabled:NO];
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
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // View
    
    self.mapView = [[CYGMapView alloc] init];
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;

    self.toolbar = [[CYGToolbar alloc] init];
    [self.view addSubview:self.toolbar];
    [self.toolbar.listButton addTarget:self action:@selector(listButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.tagButton addTarget:self action:@selector(tagButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.addButton addTarget:self action:@selector(addButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.refreshButton addTarget:self action:@selector(refreshOnMapViewRegion) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.mapView addGestureRecognizer:longPressGestureRecognizer];
 
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
         [self.mapView focusOnCoordinate:location.coordinate withBufferDistance:kCYGRegionLargeBufferInMeters animated:NO];
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
        _annotations = [[NSMutableArray alloc] initWithCapacity:kCYGMaxQueryLimit/10];
        
        _tags = ([[[NSUserDefaults standardUserDefaults] arrayForKey:kCYGSettingsTagsKey] mutableCopy]) ?: [@[@"test"] mutableCopy];

        _listViewController = [[CYGListViewController alloc] init];
        _listViewController.mainViewController = self;
        _listViewController.annotations = _annotations;
        
        _tagsViewController = [[CYGTagsViewController alloc] init];
        _tagsViewController.mainViewController = self;
        _tagsViewController.tags = _tags;
        
        _pointCreationViewController = [[CYGPointCreationViewController alloc] init];
        _pointCreationViewController.mainViewController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pointAnnotationDidUpdate:)
                                                     name:kCYGNotificationPointAnnotationUpdated object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasHidden:)
                                                     name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

#pragma mark - NSObject

- (void)dealloc
{
 
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kCYGNotificationPointAnnotationUpdated
                                                  object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self
                                                     name:UIKeyboardDidShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}


@end
