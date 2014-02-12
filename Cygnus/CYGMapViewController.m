//
//  CYGMapViewController.m
//  Cygnus
//
//  Created by IO on 2/9/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

@import MapKit;
@import CoreLocation;
@import CoreGraphics;

#import "CYGMapViewController.h"
#import "CYGManager.h"

@interface CYGMapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) BOOL mapViewIsOpen;



@end

@implementation CYGMapViewController




#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapViewIsOpen = YES;
    self.mapView = [MKMapView autoLayoutView];
    self.mapView.opaque = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.mapView pinToSuperviewEdgesWithInset:UIEdgeInsetsZero];
    
    [[[[RACObserve([CYGManager sharedManager], currentLocation)
          ignore:nil]
        take:1]
        deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(CLLocation *location) {
         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), 2000, 2000);
         [self.mapView setRegion:region animated:NO];
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[CYGManager sharedManager] findCurrentLocation];        
    }
    return self;
}

@end
