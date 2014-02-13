//
//  CYGPoint.m
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <Parse/PFObject+Subclass.h>
#import "CYGUser.h"
#import "CYGPoint.h"


@implementation CYGPoint

@dynamic title, location, tags, author;

+ (NSString *)parseClassName
{
    return kCYGPointClassName;
}

- (BOOL)isEqual:(id) object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CYGPoint class]]) {
        return NO;
    }
    
    return ([self.author.objectId isEqualToString:[(CYGPoint *)object author].objectId] &&
            [self.title isEqualToString:[(CYGPoint *)object title]] &&
            [self.tags isEqualToArray:[(CYGPoint *)object tags]] &&
            (self.location.latitude == [(CYGPoint *)object location].latitude && self.location.longitude == [(CYGPoint *)object location].longitude));
}

- (NSUInteger)hash
{
    return (NSUInteger)self;
}

@end
