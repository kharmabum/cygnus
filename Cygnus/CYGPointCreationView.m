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

@property (strong, nonatomic)  UIView *contentView;
@property (strong, nonatomic)  NSArray *animatingConstraintsOpenState;
@property (strong, nonatomic)  NSArray *animatingConstraintsClosedState;

@end

@implementation CYGPointCreationView

#pragma mark - Private

- (void)setDynamicText
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.tagsLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
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
        
        _tagsLabel = [UILabel autoLayoutView];
        [_contentView addSubview:_tagsLabel];
        _tagsLabel.text = @"Tags";
        _tagsLabel.textColor = [UIColor darkGrayColor];
        
        _tagsTextField = [UITextField autoLayoutView];
        [_contentView addSubview:_tagsTextField];
        _tagsTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _tagsTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _tagsTextField.placeholder = @"(comma separated)";
        _tagsTextField.returnKeyType = UIReturnKeyNext;
        _tagsTextField.textColor = [UIColor lightGrayColor];
        
        SSLineView *lineView = [[SSLineView alloc] init];
        lineView.translatesAutoresizingMaskIntoConstraints = NO;
        lineView.lineColor = [UIColor lightGrayColor];
        [_contentView addSubview:lineView];
        
        _titleLabel = [UILabel autoLayoutView];
        [_contentView addSubview:_titleLabel];
        _titleLabel.text = @"Name";
        _titleLabel.textColor = [UIColor darkGrayColor];
        
        _titleTextField = [UITextField autoLayoutView];
        [_contentView addSubview:_titleTextField];
        _titleTextField.placeholder = @"(optional)";
        _titleTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _titleTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        _titleTextField.returnKeyType = UIReturnKeyDone;
        _titleTextField.textColor = [UIColor lightGrayColor];
        
        _saveButton = [UIButton autoLayoutView];
        [self addSubview:_saveButton];
        [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
        _saveButton.backgroundColor = [UIColor cyg_orangeColor];
        
        [self setDynamicText];
        
        // Constraints
        
        [_contentView pinEdges:(FTUIViewEdgePinTop | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];
        [_contentView pinEdge:FTUIViewEdgePinBottom toEdge:FTUIViewEdgePinTop ofItem:_saveButton];
        [_contentView constrainToWidthOfView:self];

        [_tagsLabel pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinTop) toSuperViewWithInset:11];
        
        [_tagsTextField pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tagsLabel inset:3];
        [_tagsTextField pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:11];

        [lineView pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tagsTextField inset:4];
        [lineView pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:11];
        [lineView constrainToHeight:1];
        
        [_titleLabel pinEdges:FTUIViewEdgePinLeft toSuperViewWithInset:11];
        [_titleLabel pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tagsTextField inset:10];

        [_titleTextField pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:11];
        [_titleTextField pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_titleLabel inset:3];

        [_saveButton pinEdges:(FTUIViewEdgePinBottom | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:11];
//        [_saveButton constrainToWidthOfView:self];
        [_saveButton constrainToMinimumSize:CGSizeMake(0, kCYGPointCreationSaveButtonHeight)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}


@end
