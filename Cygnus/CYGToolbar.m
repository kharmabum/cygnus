//
//  CYGToolBar.m
//  Cygnus
//
//  Created by IO on 2/15/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGToolbar.h"

@interface CYGToolbar ()

@property (strong, nonatomic)  UIView *firstButtonContainerView;
@property (strong, nonatomic)  UIView *secondButtonContainerView;
@property (strong, nonatomic)  UIView *thirdButtonContainerView;
@property (strong, nonatomic)  UIView *fourthButtonContainerView;

@end

@implementation CYGToolbar

- (void)animateButtonColors
{
    __block UIImage *listButtonImage = [_listButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    __block UIImage *tagButtonImage = [_tagButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    __block UIImage *addButtonImage = [_addButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    __block UIImage *refreshButtonImage = [_refreshButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [UIView transitionWithView:self
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_listButton setImage:listButtonImage forState:UIControlStateNormal];
                    } completion:NULL];
    
    [self performBlockOnMainThread:^{
        [UIView transitionWithView:self
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_tagButton setImage:tagButtonImage forState:UIControlStateNormal];
                        } completion:NULL];
    } afterDelay:0.1];
    [self performBlockOnMainThread:^{
        [UIView transitionWithView:self
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_addButton setImage:addButtonImage forState:UIControlStateNormal];
                        } completion:NULL];
    } afterDelay:0.2];
    [self performBlockOnMainThread:^{
        [UIView transitionWithView:self
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [_refreshButton setImage:refreshButtonImage forState:UIControlStateNormal];
                        } completion:NULL];
    } afterDelay:0.3];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.10 alpha:1];
        
        _listButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_listButton setImage:[UIImage imageNamed:@"list-icon"] forState:UIControlStateNormal];
        _listButton.tintColor = [UIColor whiteColor];
        
        _tagButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_tagButton setImage:[UIImage imageNamed:@"tag-icon"] forState:UIControlStateNormal];
        _tagButton.tintColor = [UIColor cyg_blueColor];
        
        
        _addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_addButton setImage:[UIImage imageNamed:@"plus-icon"] forState:UIControlStateNormal];
        _addButton.tintColor = [UIColor cyg_orangeColor];
        
        _refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_refreshButton setImage:[UIImage imageNamed:@"refresh-icon"] forState:UIControlStateNormal];
        _refreshButton.tintColor = [UIColor cyg_greenColor];
        
        _firstButtonContainerView = [UIView autoLayoutView];
        _secondButtonContainerView = [UIView autoLayoutView];
        _thirdButtonContainerView = [UIView autoLayoutView];
        _fourthButtonContainerView = [UIView autoLayoutView];
        
        [_firstButtonContainerView addSubview:_listButton];
        [_secondButtonContainerView addSubview:_tagButton];
        [_thirdButtonContainerView addSubview:_addButton];
        [_fourthButtonContainerView addSubview:_refreshButton];
        
#define BUTTONSIZE 50
    
        [self addSubview:_firstButtonContainerView];
        [self addSubview:_secondButtonContainerView];
        [self addSubview:_thirdButtonContainerView];
        [self addSubview:_fourthButtonContainerView];
        
        [_firstButtonContainerView constrainToMinimumSize:CGSizeMake(BUTTONSIZE, 44)];
        [_secondButtonContainerView constrainToMinimumSize:CGSizeMake(BUTTONSIZE, 44)];
        [_thirdButtonContainerView constrainToMinimumSize:CGSizeMake(BUTTONSIZE, 44)];
        [_fourthButtonContainerView constrainToMinimumSize:CGSizeMake(BUTTONSIZE, 44)];
        
        [_firstButtonContainerView centerInView:self onAxis:NSLayoutAttributeCenterY];
        [_secondButtonContainerView centerInView:self onAxis:NSLayoutAttributeCenterY];
        [_thirdButtonContainerView centerInView:self onAxis:NSLayoutAttributeCenterY];
        [_fourthButtonContainerView centerInView:self onAxis:NSLayoutAttributeCenterY];
        [self spaceViews:@[_firstButtonContainerView, _secondButtonContainerView, _thirdButtonContainerView, _fourthButtonContainerView] onAxis:UILayoutConstraintAxisHorizontal withSpacing:10.0 alignmentOptions:0];
        
        _listButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin   |
                                        UIViewAutoresizingFlexibleRightMargin  |
                                        UIViewAutoresizingFlexibleTopMargin    |
                                        UIViewAutoresizingFlexibleBottomMargin);
        _tagButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin   |
                                        UIViewAutoresizingFlexibleRightMargin  |
                                        UIViewAutoresizingFlexibleTopMargin    |
                                        UIViewAutoresizingFlexibleBottomMargin);
        _addButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin   |
                                        UIViewAutoresizingFlexibleRightMargin  |
                                        UIViewAutoresizingFlexibleTopMargin    |
                                        UIViewAutoresizingFlexibleBottomMargin);
        _refreshButton.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin   |
                                        UIViewAutoresizingFlexibleRightMargin  |
                                        UIViewAutoresizingFlexibleTopMargin    |
                                        UIViewAutoresizingFlexibleBottomMargin);

        
        
        

    }
    return self;
}


@end
