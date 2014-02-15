//
//  CYGPointCreationViewController.m
//  Cygnus
//
//  Created by IO on 2/13/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import MapKit;
@import CoreLocation;
@import CoreGraphics;
#import "CYGPointCreationViewController.h"
#import "CYGPointCreationView.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGUser.h"
#import "CYGPointAnnotation.h"
#import <TSMessages/TSMessage.h>

@interface CYGPointCreationViewController () <MKMapViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, PFLogInViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic)  CYGPointAnnotation *annotation;
@property (strong, nonatomic)  CYGPointCreationView *pointCreationView;
@property (weak, nonatomic)    UITextField *activeField;
@property (assign, nonatomic)  BOOL keyboardIsVisible;
@property (assign, nonatomic)  BOOL firstAppearance;
@property (strong, nonatomic)  UIAlertView *tagInputAlert;
@property (strong, nonatomic)  UIGestureRecognizer *tapGestureRecognizer;


@end

static CGSize _kbSize;

@implementation CYGPointCreationViewController

#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    if (user.isNew) {
        NSLog(@"User signed up and logged in with Twitter!");
    } else {
        NSLog(@"User logged in with Twitter!");
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    NSLog(@"didFailToLogin");
    
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    NSLog(@"didCancelLogin");
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.tagInputAlert) {
        [self.pointCreationView.tagsTextField becomeFirstResponder];
        self.tagInputAlert = nil;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.pointCreationView.mapViewIsOpen) {
        [self hideMap];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    [self scrollToActiveField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.pointCreationView.tagsTextField){
        [self.pointCreationView.titleTextField becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
        [self save];
    }
    return YES;
}


#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kCYGPointAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kCYGPointAnnotationIdentifier];
        annotationView.pinColor = MKPinAnnotationColorGreen;
        annotationView.canShowCallout = NO;
        annotationView.draggable = YES;
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
        if (!MKMapRectContainsPoint(self.pointCreationView.mapView.visibleMapRect, point)) {
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


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.keyboardIsVisible = YES;
    NSDictionary* info = [aNotification userInfo];
    _kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.pointCreationView.scrollView.scrollEnabled = NO;
    [self scrollToActiveField];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.keyboardIsVisible = NO;
    self.pointCreationView.scrollView.scrollEnabled = YES;
    [self.pointCreationView.scrollView setContentOffset:CGPointMake(0.0, 0) animated:YES];
    
}

- (void)handleTapGesture:(UIGestureRecognizer *)gestureRecognizer
{
    // End any editting occuring
    if (self.keyboardIsVisible) {
        [self.view endEditing:YES];
    }
    // Otherwise open map if applicable
    else if ([self.pointCreationView.mapView
             pointInside:[gestureRecognizer locationInView:self.pointCreationView.mapView]
             withEvent:nil]
             && ![self.pointCreationView.scrollViewContentView
                 pointInside:[gestureRecognizer locationInView:self.pointCreationView.scrollViewContentView]
                 withEvent:nil]) {
                 [self showMap];
    }
    // Otherwise begin editting
    else if (!self.pointCreationView.tagsTextField.text.length) {
        [self.pointCreationView.tagsTextField becomeFirstResponder];
    }
    else {
        [self.pointCreationView.titleTextField becomeFirstResponder];

    }
}

- (void)showMap
{
    [self.pointCreationView openMapView];
    [self.pointCreationView removeGestureRecognizer:self.tapGestureRecognizer];
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(hideMap)];
    [self.navigationItem setRightBarButtonItem:close animated:YES];
}

- (void)hideMap
{
    [self.pointCreationView closeMapView];
    [self.navigationItem setRightBarButtonItem:nil];
    [self addTapGestureRecognizer];
}


#pragma mark - Private

- (BOOL)fieldsAreValidWithAssignment
{
    // TAGS
    NSString *tagText = self.pointCreationView.tagsTextField.text;
    
    // Check not empty
    if (FTIsEmpty(tagText)) {
        [self.pointCreationView.tagsTextField becomeFirstResponder];
        return NO;
    }
    else {
        // Get tags from comma-delimitted list
        NSArray *tags = [[[tagText componentsSeparatedByString:@","].rac_sequence
                          map:^id(NSString *tag) {
                              return [tag stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
                          }] array];
        
        // Check all tags are alphanumeric strings
        BOOL allGood = YES;
        for (NSString *tag in tags) {
            if (![tag cyg_isAlphaNumeric]) {
                allGood = NO;
                break;
            }
        }
        
        if (allGood) {
            self.point.tags = tags;
        }
        else {
            self.tagInputAlert = [[UIAlertView alloc] initWithTitle:@"Bad input" message:@"Tags must be comma-delimitted, alphanumeric strings." delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
            [self.tagInputAlert show];
            return NO;
        }
    }
    
    // TITLE
    NSString *titleText = self.pointCreationView.titleTextField.text;
    if (!FTIsEmpty(titleText)) {
        self.point.title = [titleText stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
    }
    
    // AUTHOR
    self.point.author = [CYGUser currentUser];

    return YES;
}

- (void)save
{
    if ([self fieldsAreValidWithAssignment]) {
        [self.navigationController popViewControllerAnimated:YES];
        __block CYGPoint *newPoint = self.point;
        [self.point saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [TSMessage showNotificationWithTitle:@"Success" subtitle:@"Point saved." type:TSMessageNotificationTypeSuccess];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationPointAnnotationUpdated object:newPoint];
            }
            else {
                [TSMessage showNotificationWithTitle:@"Error" subtitle:@"Failed to save pin." type:TSMessageNotificationTypeError];
            }
        }];
    }
}


- (void)addTapGestureRecognizer
{
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGestureRecognizer.cancelsTouchesInView = NO;
    }
    [self.pointCreationView addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)scrollToActiveField
{
    CGFloat kbHeight;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        kbHeight = (_kbSize.height) ?: 216.0;
    else
        kbHeight = (_kbSize.width) ?: 162;
    
    [self.pointCreationView.scrollView setContentOffset:CGPointMake(0.0, - self.pointCreationView.scrollView.height + self.pointCreationView.scrollViewContentView.yOrigin + self.activeField.yOrigin + self.activeField.height + kbHeight + 4) animated:YES];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.firstAppearance = YES;
    self.title = @"Add Point";
    
    self.pointCreationView = [[CYGPointCreationView alloc] init];
    [self.view addSubview:self.pointCreationView];
    [self.pointCreationView pinEdges:CYGUIViewEdgePinAll toSuperViewWithInset:0];
    self.pointCreationView.mapView.delegate = self;
    self.pointCreationView.titleTextField.delegate = self;
    self.pointCreationView.tagsTextField.delegate = self;

    UIButton *saveButton = [UIButton autoLayoutView];
    [self.view addSubview:saveButton];
    [saveButton pinEdges:(CYGUIViewEdgePinBottom | CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:0];
    [saveButton constrainToWidthOfView:self.view];
    [saveButton constrainToMinimumSize:CGSizeMake(0, kCYGPointCreationSaveButtonHeight)];
    [saveButton setTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save →" forState:UIControlStateNormal];
    saveButton.backgroundColor = [UIColor cyg_orangeColor];
    
    // Pre-initialize MapRegion to make less jumpy
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.point.location.latitude, self.point.location.longitude),
                                                                   kCYGRegionSmallBufferInMeters,
                                                                   kCYGRegionSmallBufferInMeters);
    [self.pointCreationView.mapView setRegion:region animated:NO];
    self.pointCreationView.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.point.location.latitude, self.point.location.longitude);


    [self addTapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Require user be logged in (for saveEventually:)
    if (![PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        logInViewController.delegate = self;
        logInViewController.fields = PFLogInFieldsTwitter | PFLogInFieldsDismissButton;
        logInViewController.logInView.logo = nil;
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
    
    
    // Initialize MKMapRegion (wtf autolayout)
    if (self.firstAppearance) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.point.location.latitude, self.point.location.longitude),
                                                                       kCYGRegionSmallBufferInMeters,
                                                                       kCYGRegionSmallBufferInMeters);
        [self.pointCreationView.mapView setRegion:region animated:NO];
        self.pointCreationView.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.point.location.latitude, self.point.location.longitude);
        self.annotation = [[CYGPointAnnotation alloc] initWithPoint:self.point];
        self.annotation.isNewlyCreatedPoint = YES;
        [self.pointCreationView.mapView addAnnotation:self.annotation];
        self.firstAppearance = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _point = [CYGPoint object];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.pointCreationView setNeedsUpdateConstraints];
    [self.pointCreationView setNeedsLayout];
}


#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


@end
