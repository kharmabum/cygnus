//
//  CYGPoint.h
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@class CYGUser;

@interface CYGPoint : PFObject <PFSubclassing>

@property (strong, nonatomic)  NSString *title;
@property (strong, nonatomic)  PFGeoPoint *location;
@property (strong, nonatomic)  NSArray *tags;
@property (strong, nonatomic)  CYGUser *author;

+ (NSString *)parseClassName;

@end
