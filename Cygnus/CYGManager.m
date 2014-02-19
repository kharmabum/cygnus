//
//  CYGManager.m
//  Cygnus
//
//  Created by IO on 2/12/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGManager.h"
#import <TSMessages/TSMessage.h>


@interface CYGManager ()
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (assign, nonatomic)  NSUInteger failureCount;


@end
@implementation CYGManager

+ (instancetype)sharedManager {
    static id _sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        /*
        [[[[RACObserve(self, currentLocation)
            ignore:nil]
           // Flatten and subscribe to all 3 signals when currentLocation updates
           flattenMap:^(CLLocation *newLocation) {
               // TODO: Do work;
               return [RACSignal return:0];
           }] deliverOn:RACScheduler.mainThreadScheduler]
         subscribeError:^(NSError *error) {
             [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching your location." type:TSMessageNotificationTypeError];
         }];
         */
    }
    return self;
}

- (void)findCurrentLocation {
    if ((![CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cygnus can’t access your current location.\n\nTo view nearby points or create a point at your current location, turn on access for Cygnus to your location in the Settings app under Location Services." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
    }
    else {
        self.isFirstUpdate = YES;
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.failureCount = 0;
    
    if (self.isFirstUpdate) { //ignore cached value
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    if (location.horizontalAccuracy > 0) {
        self.currentLocation = location;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    self.failureCount++;
    if (self.failureCount > 1) {
        [TSMessage showNotificationWithTitle:@"Error" subtitle:@"There was a problem fetching your location." type:TSMessageNotificationTypeError];
    }

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	switch (status) {
		case kCLAuthorizationStatusAuthorized:
			NSLog(@"kCLAuthorizationStatusAuthorized");
			[self.locationManager startUpdatingLocation];
            [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationCLAuthorizationStatusAuthorized object:nil];
			break;
		case kCLAuthorizationStatusDenied:
			NSLog(@"kCLAuthorizationStatusDenied");
        {{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cygnus can’t access your current location.\n\nTo view nearby points or create a point at your current location, turn on access for Cygnus to your location in the Settings app under Location Services." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
        }}
			break;
		case kCLAuthorizationStatusNotDetermined:
			NSLog(@"kCLAuthorizationStatusNotDetermined");
			break;
		case kCLAuthorizationStatusRestricted:
			NSLog(@"kCLAuthorizationStatusRestricted");
			break;
	}
}

@end
