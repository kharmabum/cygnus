//
//  CYGTagsView.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTagsView.h"

@interface CYGTagsView ()

@property (strong, nonatomic)  UILabel *dummyLabel;


@end

@implementation CYGTagsView

#pragma mark - Private

- (void)setDynamicText
{
    self.dummyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
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
        
        _dummyLabel = [UILabel autoLayoutView];
        [self addSubview:_dummyLabel];
        _dummyLabel.text = @"Tags view text";
        _dummyLabel.textColor = [UIColor darkGrayColor];
        
        [self setDynamicText];
        
        // Constraints
        
        [_dummyLabel pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinTop) toSuperViewWithInset:11];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}


@end
