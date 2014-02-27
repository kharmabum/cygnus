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
#import "CYGTag.h"
#import "CYGManager.h"


@implementation CYGPoint

@dynamic title, location, tags, tagObjects, author;

//TODO: isSimilar? For collapsing large datasets

- (CLLocationDistance)distanceFromUserLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.location.latitude longitude:self.location.longitude];
    return [location distanceFromLocation:[[CYGManager sharedManager] currentLocation]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"CYGPoint - ObjId: %@, Title: %@, AuthorId: %@, Tags: %@, Lat: %f, Long: %f,", self.objectId, self.title, self.author.objectId, self.tags, self.location.latitude, self.location.longitude];
}

- (BOOL)isEqual:(id) object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[CYGPoint class]]) {
        return NO;
    }
    
    return (
            ([self.objectId isEqualToString:[(CYGPoint *)object objectId]]) &&
            ([self.author.objectId isEqualToString:[(CYGPoint *)object author].objectId] || (!self.author && ![(CYGPoint*)object author])) &&
            ([self.title isEqualToString:[(CYGPoint *)object title]] || (!self.title && ![(CYGPoint*)object title])) &&
            [self.tags isEqualToArray:[(CYGPoint *)object tags]] &&
            (fequal(self.location.latitude, [(CYGPoint *)object location].latitude) && fequal(self.location.longitude, [(CYGPoint *)object location].longitude))
            );
}

- (NSUInteger)hash
{
    return (NSUInteger)self;
}

+ (NSString *)parseClassName
{
    return kCYGPointClassName;
}

@end
