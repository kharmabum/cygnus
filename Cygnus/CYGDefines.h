//
//  CYGDefines.h
//  Cygnus
//
//  Created by IO on 2/4/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - API

extern NSString *const kCYGParseApplicationId;
extern NSString *const kCYGParseClientKey;

extern NSString *const kCYGTwitterKey;
extern NSString *const kCYGTwitterSecret;

#pragma mark - Notifications

extern NSString *const kCYGNotificationPointAnnotationUpdated;
extern NSString *const kCYGNotificationCLAuthorizationStatusAuthorized;

#pragma mark - Analytics

extern NSString *const kCYGGenericEvent;
extern NSString *const kCYGGenericEventParam;

#pragma mark - Settings and Defaults

extern NSString  *const kCYGSettingsTagsKey;

#pragma mark - Parse Class Names, Keys

extern NSString *const kCYGPointClassName;
extern NSString *const kCYGTagClassName;
extern NSString *const kCYGPointLocationKey;
extern NSString *const kCYGPointAuthorKey;
extern NSString *const kCYGPointTagsKey;
extern NSString *const kCYGPointTagObjectsKey;
extern NSString *const kCYGTagTitleKey;
extern NSString *const kCYGTagTotalUsageCountKey;

#pragma mark - Number Constants

extern double const kCYGFeetToMeters;
extern double const kCYGMetersToFeet;
extern double const kCYGMetersToMiles;
extern double const kCYGMilesToFeet;
extern double const kCYGKilometerToMeters;
extern double const kCYGMetersCutoff;
extern double const kCYGFeetCutoff;
extern double const kCYGRegionLargeBufferInMeters;
extern double const kCYGRegionSmallBufferInMeters;
extern double const kCYGMaxFilterDistanceInKilometers;
extern double const kCYGMinFilterDistanceInKilometers;
extern double const kCYGMaxQueryLimit;

#pragma mark - UI

extern NSInteger const kCYGPointCreationSaveButtonHeight;
extern NSInteger const kCYGMapViewControllerTabBarHeight;
extern NSString *const kCYGPointTableViewCellId;



#pragma mark - Misc

extern NSString *const kCYGPointAnnotationIdentifier;