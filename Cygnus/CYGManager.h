//
//  CYGManager.h
//  Cygnus
//
//  Created by IO on 2/12/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@interface CYGManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong, readonly) CLLocation *currentLocation;

+ (instancetype)sharedManager;

- (void)findCurrentLocation;

@end
