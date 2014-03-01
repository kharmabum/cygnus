//
//  CYGTagsView.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTagsView.h"
#import "CYGTokenInputField.h"

@interface CYGTagsView ()



@end

@implementation CYGTagsView

#pragma mark - Private

- (void)setDynamicText
{
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
        
        _tokenInputField = [[CYGTokenInputField alloc] init];
        [self addSubview:_tokenInputField];
    
        _tableView = [UITableView autoLayoutView];
        [self addSubview:_tableView];
        
        [self setDynamicText];
        
        // Constraints
        
        [_tokenInputField pinEdges:(FTUIViewEdgePinTop | FTUIViewEdgePinLeft | FTUIViewEdgePinRight) toSuperViewWithInset:0];
        [_tableView pinEdges:(FTUIViewEdgePinLeft | FTUIViewEdgePinRight | FTUIViewEdgePinBottom) toSuperViewWithInset:0];
        [_tableView pinEdge:FTUIViewEdgePinTop toEdge:FTUIViewEdgePinBottom ofItem:_tokenInputField];
        [_tableView constrainToWidthOfView:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}


@end
