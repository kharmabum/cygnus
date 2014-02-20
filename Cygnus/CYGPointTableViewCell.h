//
//  CYGPointTableViewCell.h
//  Cygnus
//
//  Created by IO on 2/19/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYGPoint;

@interface CYGPointTableViewCell : UITableViewCell


@property (nonatomic, strong)  CYGPoint *point;
@property (nonatomic, strong)  UILabel *titleLabel;
@property (nonatomic, strong)  UILabel *tagsLabel;
@property (nonatomic, strong)  UILabel *distanceLabel;
@property (nonatomic, strong)  UILabel *coordinateLabel;
@property (nonatomic, strong)  UILabel *authorLabel;
@property (nonatomic, strong)  UILabel *dateCreatedLabel;

@end
