//
//  CYGMapViewController.h
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import Foundation;
@import UIKit;

@class CYGListViewController, CYGTagsViewController, CYGPointCreationViewController;

@interface CYGMainViewController : UIViewController

@property (strong, nonatomic, readonly) CYGListViewController *listViewController;
@property (strong, nonatomic, readonly) CYGTagsViewController *tagsViewController;
@property (strong, nonatomic, readonly) CYGPointCreationViewController *pointCreationViewController;
@property (strong, nonatomic) NSMutableArray *tags;

- (void)refreshOnMapViewRegion;

- (void)switchToMapView;
- (void)switchToListView;
- (void)switchToTagView;
- (void)switchToPointCreationView;

- (void)switchToMapViewWithCompletion:(void (^)(void))completion;
- (void)switchToListViewWithCompletion:(void (^)(void))completion;
- (void)switchToTagViewWithCompletion:(void (^)(void))completion;
- (void)switchToPointCreationViewWithCompletion:(void (^)(void))completion andCoordinate:(CLLocationCoordinate2D)aCoordinate;

@end
