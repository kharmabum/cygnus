//
//  CYGListView.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGListView.h"

@interface CYGListView ()

@end

@implementation CYGListView

#pragma mark - Private

- (void)setDynamicText
{
//    self.dummyLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
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
        
        _tableView = [UITableView autoLayoutView];
        [self addSubview:_tableView];
        [_tableView pinEdges:FTUIViewEdgePinAll toSuperViewWithInset:0];
        [_tableView constrainToHeightOfView:self];
        [_tableView constrainToWidthOfView:self];
        
        [self setDynamicText];
        
        // Constraints
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}


@end
