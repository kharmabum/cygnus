//
//  CYGPointCreationView.h
//  Cygnus
//
//  Created by IO on 2/13/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//


@class MKMapView;

@interface CYGPointCreationView : UIView

@property (strong, nonatomic)  MKMapView *mapView;
@property (strong, nonatomic)  UIButton *userLocationButton;
@property (assign, nonatomic)  BOOL mapViewIsOpen;
@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  UIView *scrollViewContentView;

@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UILabel *tagsLabel;
@property (strong, nonatomic)  UITextField *titleTextField;
@property (strong, nonatomic)  UITextField  *tagsTextField;

- (void)openMapView;
- (void)closeMapView;

@end
