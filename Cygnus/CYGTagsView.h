//
//  CYGTagsView.h
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYGTokenInputField;

@interface CYGTagsView : UIView

@property (strong, nonatomic)  UITableView *tableView;
@property (strong, nonatomic)  CYGTokenInputField *tokenInputField;

@end
