//
//  CYGToolBar.h
//  Cygnus
//
//  Created by IO on 2/15/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import UIKit;

@interface CYGToolbar : UIView

@property (strong, nonatomic)  UIButton *listButton;
@property (strong, nonatomic)  UIButton *tagButton;
@property (strong, nonatomic)  UIButton *addButton;
@property (strong, nonatomic)  UIButton *refreshButton;


- (void)animateButtonColors;

- (void)startSpinningRefreshButton;
- (void)stopSpinningRefreshButton;


@end
