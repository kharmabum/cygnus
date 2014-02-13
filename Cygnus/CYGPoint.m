//
//  CYGPoint.m
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGPoint.h"
#import <Parse/PFObject+Subclass.h>


@implementation CYGPoint

@dynamic title, location, tags, author;

+ (NSString *)parseClassName
{
    return kCYGPointClassName;
}

@end
