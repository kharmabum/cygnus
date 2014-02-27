//
//  CYGTag.m
//  Cygnus
//
//  Created by IO on 2/27/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTag.h"
#import <Parse/PFObject+Subclass.h>

@implementation CYGTag

@dynamic title, points, totalUsageCount;

- (BOOL)isEqual:(id) object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CYGTag class]]) {
        return NO;
    }
    
    return ([self.title isEqualToString:[(CYGTag *)object title]]);
}

- (NSUInteger)hash
{
    return (NSUInteger)self;
}

+ (NSString *)parseClassName
{
    return kCYGTagClassName;
}

@end
