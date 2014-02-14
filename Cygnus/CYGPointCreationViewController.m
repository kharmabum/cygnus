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

@interface CYGPointCreationViewController () <MKMapViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic)  CYGPointAnnotation *annotation;
@property (strong, nonatomic)  CYGPointCreationView *pointCreationView;
@property (weak, nonatomic)  UITextField *activeField;
@property (assign, nonatomic)  BOOL keyboardIsVisible;



@end

static CGSize _kbSize;

@implementation CYGPointCreationViewController

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    [self scrollToActiveField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.pointCreationView.tagsTextField){
        [self.pointCreationView.titleTextField becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
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
        annotationView.canShowCallout = YES;
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



#pragma mark - Private

- (void)scrollToActiveField
{
    if (!_kbSize.height) return;
    [self.pointCreationView.scrollView setContentOffset:CGPointMake(0.0, - self.pointCreationView.scrollView.height + self.pointCreationView.scrollViewContentView.yOrigin + self.activeField.yOrigin + self.activeField.height + _kbSize.height + 3) animated:YES];
}

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

- (void)toggleEdit
{
    if (self.keyboardIsVisible) {
        [self.view endEditing:YES];
    }
    else {
        if (self.pointCreationView.tagsTextField.text.length) {
            [self.pointCreationView.titleTextField becomeFirstResponder];
        }
        else {
            [self.pointCreationView.tagsTextField becomeFirstResponder];
        }
    }
}

- (void)save
{
    // TODO: Validation on points. must have tags, etc
    
     [self.point saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.navigationController popViewControllerAnimated:YES];
    
            [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationPointAnnotationUpdated object:self.point];
        }
    }];
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    self.title = @"Add Point";
    
    self.pointCreationView = [[CYGPointCreationView alloc] init];
    [self.view addSubview:self.pointCreationView];
    [self.pointCreationView pinToSuperviewEdgesWithInset:UIEdgeInsetsZero];
    self.pointCreationView.mapView.delegate = self;
    self.pointCreationView.titleTextField.delegate = self;
    self.pointCreationView.tagsTextField.delegate = self;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.point.location.latitude, self.point.location.longitude),
                                                                   kCYGRegionSmallBufferInMeters,
                                                                   kCYGRegionSmallBufferInMeters);
    [self.pointCreationView.mapView setRegion:region animated:NO];
    self.annotation = [[CYGPointAnnotation alloc] initWithPoint:self.point];
    self.annotation.isNewlyCreatedPoint = YES;
    [self.pointCreationView.mapView addAnnotation:self.annotation];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleEdit)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.pointCreationView addGestureRecognizer:tapGestureRecognizer];
    
//    UIButton *÷
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
        _point.author = [CYGUser currentUser];
        
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
