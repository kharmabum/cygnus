//
//  CYGPointCreationView.m
//  Cygnus
//
//  Created by IO on 2/13/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import MapKit;
@import CoreLocation;
@import Foundation;
@import UIKit;
@import CoreGraphics;

#import "CYGPointCreationView.h"
#import <SSToolkit/SSLineView.h>
#import "CYGPointAnnotation.h"

@interface CYGPointCreationView () <UIScrollViewDelegate>

@property (strong, nonatomic) NSArray *animatingConstraintsOpenState;
@property (strong, nonatomic) NSArray *animatingConstraintsClosedState;

@end

@implementation CYGPointCreationView

#pragma mark - UIScrollViewDelegate

#pragma mark - Private

- (void)openMapView
{
    self.mapViewIsOpen = YES;
    [self.animatingConstraintsClosedState makeObjectsPerformSelector:NSSelectorFromString(@"remove")];
    if (!_animatingConstraintsOpenState) {
        NSLayoutConstraint *contentTopConstraint = [_scrollViewContentView pinEdge:CYGUIViewEdgePinTop toEdge:CYGUIViewEdgePinBottom ofItem:self];
        [contentTopConstraint setConstant:-kCYGPointCreationSaveButtonHeight];
        _animatingConstraintsOpenState = @[contentTopConstraint];;
    }
    else {
        [self.animatingConstraintsOpenState makeObjectsPerformSelector:NSSelectorFromString(@"install")];
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.scrollView.alpha = 0;
                         [UIView animateWithDuration:0.5f animations:^{
                             self.userLocationButton.alpha = 0.8;
                         }];
                     }];
}

- (void)closeMapView
{
    self.mapViewIsOpen = NO;
    for (NSObject<MKAnnotation> *annotation in [self.mapView selectedAnnotations])
        [self.mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
    
    [self.animatingConstraintsOpenState makeObjectsPerformSelector:NSSelectorFromString(@"remove")];
    [self.animatingConstraintsClosedState makeObjectsPerformSelector:NSSelectorFromString(@"install")];

    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.userLocationButton.alpha = 0;
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished){
                         self.scrollView.alpha = 1;
                         CLLocationCoordinate2D coordinate;
                         for (id <MKAnnotation>annotation in self.mapView.annotations) {
                             if (![annotation isMemberOfClass:[MKUserLocation class]]) {
                                 coordinate = [annotation coordinate];
                                 break;
                             }
                         }
                         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude),
                                                                                        kCYGRegionSmallBufferInMeters,
                                                                                        kCYGRegionSmallBufferInMeters);
                         [self.mapView setRegion:region animated:NO];
                     }];

    
}

- (void)centerMapUserLocation
{
    CLLocation *location = self.mapView.userLocation.location;
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

- (void)setDynamicText
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.tagsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    self.titleTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.tagsTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)preferredContentSizeChanged
{
    [self setDynamicText];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - UIView

- (void)updateConstraints
{
    [super updateConstraints];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _mapViewIsOpen = NO;

        _mapView = [MKMapView autoLayoutView];
        [self addSubview:_mapView];
        [_mapView pinEdges:(CYGUIViewEdgePinTop | CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:0];
        _mapView.opaque = YES;
        _mapView.showsUserLocation = YES;
        _mapView.tintColor = [UIColor cyg_greenColor];
        
        _userLocationButton = [UIButton autoLayoutView];
        [_mapView addSubview:_userLocationButton];
        [_userLocationButton pinEdges:CYGUIViewEdgePinTop toSuperViewWithInset:75];
        [_userLocationButton pinEdges:CYGUIViewEdgePinLeft toSuperViewWithInset:10];
        [_userLocationButton setBackgroundImage:[UIImage imageNamed:@"user-location-icon"] forState:UIControlStateNormal];
        [_userLocationButton setAlpha:0];
        [_userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];

        _scrollView = [UIScrollView autoLayoutView];
        [self addSubview:_scrollView];
        [_scrollView pinEdges:CYGUIViewEdgePinAll toSuperViewWithInset:0];
        [_scrollView constrainToHeightOfView:self];
        [_scrollView constrainToWidthOfView:self];
        _scrollView.scrollEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
        
        _scrollViewContentView = [UIView autoLayoutView];
        [_scrollView addSubview:_scrollViewContentView];
        NSLayoutConstraint *contentTopConstraint = [[_scrollViewContentView pinEdges:CYGUIViewEdgePinTop toSuperViewWithInset:180] firstObject];
        [_scrollViewContentView pinEdges:(CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:0];
        [_scrollViewContentView constrainToWidthOfView:self];
        [_scrollViewContentView constrainToHeightOfView:self];
        [_mapView pinEdge:CYGUIViewEdgePinBottom toEdge:CYGUIViewEdgePinTop ofItem:_scrollViewContentView];
        _scrollViewContentView.backgroundColor = [UIColor whiteColor];
        _scrollViewContentView.opaque = YES;
        
        _tagsLabel = [UILabel autoLayoutView];
        [_scrollViewContentView addSubview:_tagsLabel];
        [_tagsLabel pinEdges:(CYGUIViewEdgePinLeft | CYGUIViewEdgePinTop) toSuperViewWithInset:11];
        _tagsLabel.text = @"Tags";
        _tagsLabel.textColor = [UIColor darkGrayColor];
        
        _tagsTextField = [UITextField autoLayoutView];
        [_scrollViewContentView addSubview:_tagsTextField];
        [_tagsTextField pinEdge:CYGUIViewEdgePinTop toEdge:CYGUIViewEdgePinBottom ofItem:_tagsLabel inset:3];
        [_tagsTextField pinEdges:(CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:11];
        _tagsTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _tagsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _tagsTextField.placeholder = @"(comma separated)";
        _tagsTextField.returnKeyType = UIReturnKeyNext;
        _tagsTextField.textColor = [UIColor lightGrayColor];
        
        SSLineView *lineView = [[SSLineView alloc] init];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        lineView.lineColor = [UIColor lightGrayColor];
        [_scrollViewContentView addSubview:lineView];
        [lineView pinEdge:CYGUIViewEdgePinTop toEdge:CYGUIViewEdgePinBottom ofItem:_tagsTextField inset:4];
        [lineView pinEdges:(CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:11];
        [lineView constrainToHeight:1];
        
        _titleLabel = [UILabel autoLayoutView];
        [_scrollViewContentView addSubview:_titleLabel];
        [_titleLabel pinEdges:CYGUIViewEdgePinLeft toSuperViewWithInset:11];
        [_titleLabel pinEdge:CYGUIViewEdgePinTop toEdge:CYGUIViewEdgePinBottom ofItem:_tagsTextField inset:10];
        _titleLabel.text = @"Name";
        _titleLabel.textColor = [UIColor darkGrayColor];
        
        _titleTextField = [UITextField autoLayoutView];
        [_scrollViewContentView addSubview:_titleTextField];
        [_titleTextField pinEdges:(CYGUIViewEdgePinLeft | CYGUIViewEdgePinRight) toSuperViewWithInset:11];
        [_titleTextField pinEdge:CYGUIViewEdgePinTop toEdge:CYGUIViewEdgePinBottom ofItem:_titleLabel inset:3];
        _titleTextField.placeholder = @"(optional)";
        _titleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.textColor = [UIColor lightGrayColor];
        
        // Open and Closed Map Constraints
        _animatingConstraintsClosedState = @[contentTopConstraint];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
        


    }
    return self;
}


@end
