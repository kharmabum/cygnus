//
//  CYGListViewController.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGListViewController.h"
#import "CYGListView.h"
#import "CYGPointTableViewCell.h"
#import "CYGPointAnnotation.h"
#import "CYGPoint.h"

@interface CYGListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic)  CYGListView *view;

@end

@implementation CYGListViewController


#pragma mark - Actions, Gestures, Notification Handlers

// This method is called when the Dynamic Type user setting changes (from the system Settings app)
- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.view.tableView reloadData];
}


#pragma mark - UITableViewDataSource and UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYGPointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCYGPointTableViewCellId];
    cell.point = ((CYGPointAnnotation *)self.annotations[indexPath.row]).point;
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.annotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYGPointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCYGPointTableViewCellId];
    cell.point = ((CYGPointAnnotation *)self.annotations[indexPath.row]).point;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIViewController


- (void)loadView
{
    self.view = [[CYGListView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.tableView.delegate = self;
    self.view.tableView.dataSource = self;
    [self.view.tableView registerClass:[CYGPointTableViewCell class] forCellReuseIdentifier:kCYGPointTableViewCellId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentSizeCategoryChanged:)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

@end
