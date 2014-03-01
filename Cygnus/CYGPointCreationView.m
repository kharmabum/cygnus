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
#import "CYGTokenInputField.h"


@interface CYGPointCreationView () <UIScrollViewDelegate>

@property (strong, nonatomic)  UIView *contentView;
@property (strong, nonatomic)  NSArray *animatingConstraintsOpenState;
@property (strong, nonatomic)  NSArray *animatingConstraintsClosedState;

@end

@implementation CYGPointCreationView

#pragma mark - Private

- (void)setDynamicText
{
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _tagsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _titleLengthLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    _titleTextField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
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

- (id)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.opaque = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        _contentView = [UIView autoLayoutView];
        [self addSubview:_contentView];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.opaque = YES;
        
//        _tagsLabel = [UILabel autoLayoutView];
//        [_contentView addSubview:_tagsLabel];
//        _tagsLabel.text = @"Tags";
//        _tagsLabel.textColor = [UIColor darkGrayColor];
        
        UIView *tagsInputContainerView = [UIView autoLayoutView];
        [_contentView addSubview:tagsInputContainerView];
        
        _tokenInputField = [[CYGTokenInputField alloc] init];
        [tagsInputContainerView addSubview:_tokenInputField];
        tagsInputContainerView.clipsToBounds = YES;
        
//        SSLineView *lineView = [[SSLineView alloc] init];
//        lineView.translatesAutoresizingMaskIntoConstraints = NO;
//        lineView.lineColor = [UIColor lightGrayColor];
//        [_contentView addSubview:lineView];
        
        _titleLabel = [UILabel autoLayoutView];
        [_contentView addSubview:_titleLabel];
        _titleLabel.text = @"Optional";
        _titleLabel.textColor = [UIColor darkGrayColor];
        
        _titleTextField = [UITextField autoLayoutView];
        [_contentView addSubview:_titleTextField];
        _titleTextField.placeholder = @"Name";
        _titleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.textColor = [UIColor lightGrayColor];
        
        _titleLengthLabel = [UILabel autoLayoutView];
        [_contentView addSubview:_titleLengthLabel];
        _titleLengthLabel.text = @"(25)";
        _titleLengthLabel.textColor = [UIColor lightGrayColor];
        
        _saveButton = [UIButton autoLayoutView];
        [self addSubview:_saveButton];
        [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
        _saveButton.backgroundColor = [UIColor cyg_orangeColor];
        
        [self setDynamicText];
        
        // Constraints
        
        [_contentView pinEdges:(FTUIViewEdgePinTop | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];
        [_contentView pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:_saveButton];
        [_contentView constrainToWidthOfView:self];

//        [_tagsLabel pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinTop) toSuperViewWithInset:11];
        
        [tagsInputContainerView pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinTop ofItem:_contentView inset:3];
//        [tagsInputContainerView pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tagsLabel inset:3];
        [tagsInputContainerView pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];

        [_tokenInputField pinEdges:FTUIViewEdgePinAll toSuperViewWithInset:0];

//        [lineView pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tokenInputField inset:3];
//        [lineView pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:11];
//        [lineView constrainToHeight:1];
        
        [_titleLabel pinEdges:FTUIViewEdgePinLeft toSuperViewWithInset:8];
        [_titleLabel pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:tagsInputContainerView inset:11];

        [_titleTextField pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:11];
        [_titleTextField pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_titleLabel inset:8];
        
        [_titleLengthLabel pinEdges:FTUIViewEdgePinRight toSuperViewWithInset:11];
        [_titleLengthLabel pinAttribute:NSLayoutAttributeCenterY toSameAttributeOfItem:_titleTextField];

        [_saveButton pinEdges:(FTUIViewEdgePinBottom | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];
        [_saveButton constrainToMinimumSize:CGSizeMake(0, kCYGPointCreationSaveButtonHeight)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}


@end
