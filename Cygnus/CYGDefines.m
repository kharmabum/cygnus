//
//  CYGDefines.m
//  Cygnus
//
//  Created by IO on 2/4/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGDefines.h"

#pragma mark - API

NSString *const kCYGParseApplicationId = @"qWQtxgyHLsAumytuNzFoaEzGEupor2Sn9StnH50z";
NSString *const kCYGParseClientKey = @"BznsBv7RH7J4Ecq3X9uPcEsRlXyWaRTbdYbQaK06";

NSString *const kCYGTwitterKey = @"jZDLmx7kUKB5eeymQUAP0Q";
NSString *const kCYGTwitterSecret = @"OMYzeu1vf70xklOiLuFokvo2huXnT8ckZXqSv1dcdB0";

#pragma mark - Notifications

NSString *const kCYGNotificationPointAnnotationUpdated = @"CYGPointAnnotationUpdated";
NSString *const kCYGNotificationCLAuthorizationStatusAuthorized = @"CLAuthorizationStatusAuthorized";


#pragma mark - Parse Keys

NSString *const kCYGPointClassName = @"CYGPoint";
NSString *const kCYGPointLocationKey = @"location";
NSString *const kCYGPointAuthorKey = @"author";
NSString *const kCYGPointTagsKey = @"tags";

#pragma mark - Metrics

double const kCYGFeetToMeters = 0.3048;
double const kCYGMetersToFeet = 3.2808399;
double const kCYGMetersToMiles = 0.000621371192;
double const kCYGFeetToMiles = 5280.0;
double const kCYGKilometerToMeters = 1000.0;
double const kCYGMetersCutoff = 1000;
double const kCYGFeetCutoff = 3281;
double const kCYGRegionLargeBufferInMeters = 2000;
double const kCYGRegionSmallBufferInMeters = 500;
double const kCYGMaxFilterDistanceInKilometers = 100;
double const kCYGMinFilterDistanceInKilometers = 5;
double const kCYGMaxQueryLimit = 1000;

#pragma mark - UI

double const kCYGPointCreationViewParalaxScale = 1.8;
NSInteger const kCYGPointCreationSaveButtonHeight = 66;
NSInteger const kCYGMapViewControllerTabBarHeight  = 56;
NSInteger const kCYGPointCreationMapViewOffset = 100;


#pragma mark - Misc

NSString *const kCYGPointAnnotationIdentifier = @"CYGPointAnnotationId";
