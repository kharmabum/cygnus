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

@interface CYGPointCreationView () <UIScrollViewDelegate>

@end

@implementation CYGPointCreationView

#pragma mark - UIScrollViewDelegate


#define THRESHOLD  40
#define SCALE 2

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float offsetY = self.scrollView.contentOffset.y;
    // Resistance is controlled by the division operation.
    if (offsetY < 0) {
        //        float scale = ABS(offsetY/THRESHOLD);
        //        self.authorContainerView.alpha = 1 - scale;
        self.mapView.yOrigin = -THRESHOLD-offsetY/SCALE;
    }
}

#pragma mark - Private

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
        [_mapView pinToSuperviewEdges:(JRTViewPinTopEdge) inset:-40];
        [_mapView pinToSuperviewEdges:(JRTViewPinLeftEdge | JRTViewPinRightEdge) inset:0];
        [_mapView constrainToHeight:340];
        _mapView.opaque = YES;
        _mapView.showsUserLocation = YES;
        _mapView.tintColor = [UIColor colorWithHex:@"0x00FF91"];
        
        _userLocationButton = [UIButton autoLayoutView];
        [_mapView addSubview:_userLocationButton];
        [_userLocationButton pinToSuperviewEdges:JRTViewPinTopEdge inset:75];
        [_userLocationButton pinToSuperviewEdges:JRTViewPinLeftEdge inset:10];
        [_userLocationButton setBackgroundImage:[UIImage imageNamed:@"user-location-icon"] forState:UIControlStateNormal];
        [_userLocationButton setAlpha:0];
        [_userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];

        
        _scrollView = [UIScrollView autoLayoutView];
        [self addSubview:_scrollView];
        [_scrollView pinToSuperviewEdges:JRTViewPinAllEdges inset:0];
        _scrollView.scrollEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.delegate = self;
        
        _scrollViewContentView = [UIView autoLayoutView];
        [_scrollView addSubview:_scrollViewContentView];
        [_scrollViewContentView pinToSuperviewEdges:JRTViewPinTopEdge inset:180];
        [_scrollViewContentView pinToSuperviewEdges:(JRTViewPinLeftEdge | JRTViewPinRightEdge) inset:0];
        [_scrollViewContentView pinAttribute:NSLayoutAttributeWidth toSameAttributeOfItem:self];
        NSLayoutConstraint *heightConstraint =[_scrollViewContentView pinAttribute:NSLayoutAttributeHeight toSameAttributeOfItem:self];
        heightConstraint.constant = -(_mapView.height);
        _scrollViewContentView.backgroundColor = [UIColor whiteColor];
        _scrollViewContentView.opaque = YES;
        
        _tagsLabel = [UILabel autoLayoutView];
        [_scrollViewContentView addSubview:_tagsLabel];
        [_tagsLabel pinToSuperviewEdges:(JRTViewPinTopEdge | JRTViewPinLeftEdge) inset:11];
        _tagsLabel.text = @"Tags";
        _tagsLabel.textColor = [UIColor darkGrayColor];
        
        _tagsTextField = [UITextField autoLayoutView];
        [_scrollViewContentView addSubview:_tagsTextField];
        [_tagsTextField pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:_tagsLabel inset:3];
        [_tagsTextField pinToSuperviewEdges:(JRTViewPinLeftEdge | JRTViewPinRightEdge) inset:11];
        _tagsTextField.placeholder = @"(comma separated)";
        _tagsTextField.returnKeyType = UIReturnKeyNext;
        _tagsTextField.textColor = [UIColor lightGrayColor];
        
        _titleLabel = [UILabel autoLayoutView];
        [_scrollViewContentView addSubview:_titleLabel];
        [_titleLabel pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:11];
        [_titleLabel pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:_tagsTextField inset:8];
        _titleLabel.text = @"Title";
        _titleLabel.textColor = [UIColor darkGrayColor];
        
        _titleTextField = [UITextField autoLayoutView];
        [_scrollViewContentView addSubview:_titleTextField];
        [_titleTextField pinToSuperviewEdges:(JRTViewPinLeftEdge | JRTViewPinRightEdge) inset:11];
        [_titleTextField pinEdge:NSLayoutAttributeTop toEdge:NSLayoutAttributeBottom ofItem:_titleLabel inset:3];
        _titleTextField.placeholder = @"(optional)";
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.textColor = [UIColor lightGrayColor];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];

    }
    return self;
}


@end
