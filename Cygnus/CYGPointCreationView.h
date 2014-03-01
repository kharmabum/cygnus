//
//  CYGPointCreationView.h
//  Cygnus
//
//  Created by IO on 2/13/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//


@class MKMapView;

@class CYGPointAnnotation, CYGTokenInputField;

@interface CYGPointCreationView : UIView

@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UILabel *tagsLabel;
@property (strong, nonatomic)  UILabel *titleLengthLabel;
@property (strong, nonatomic)  UITextField *titleTextField;
@property (strong, nonatomic)  CYGTokenInputField  *tokenInputField;
@property (strong, nonatomic)  UIButton *saveButton;


@end
