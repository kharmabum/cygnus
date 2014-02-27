//
//  CYGTag.h
//  Cygnus
//
//  Created by IO on 2/27/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <Parse/Parse.h>

@interface CYGTag : PFObject <PFSubclassing>

@property (strong, nonatomic)  NSString *title;
@property (strong, nonatomic)  PFRelation *points;
@property (assign, nonatomic)  NSUInteger totalUsageCount;

+ (NSString *)parseClassName;

@end
