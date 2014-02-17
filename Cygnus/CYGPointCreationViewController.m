//
//  CYGPointCreationViewController.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGPointCreationViewController.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGUser.h"
#import "CYGPointAnnotation.h"
#import "CYGPointCreationView.h"
#import <TSMessages/TSMessage.h>

@interface CYGPointCreationViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic)  CYGPointCreationView *view;
@property (weak, nonatomic)    UITextField *activeField;
@property (strong, nonatomic)  UIAlertView *tagInputAlert;
@property (assign, nonatomic)  BOOL keyboardIsVisible;
@property (assign) CGFloat keyboardHeight;

@end

@implementation CYGPointCreationViewController

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    [self scrollToActiveField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.view.tagsTextField){
        [self.view.titleTextField becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
        [self save];
    }
    return YES;
}


#pragma mark - Actions, Gestures, Notification Handlers


- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.keyboardIsVisible = YES;
    NSDictionary* info = [aNotification userInfo];
    self.keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    [self scrollToActiveField];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.keyboardIsVisible = NO;
//    [self.pointCreationView.scrollView setContentOffset:CGPointMake(0.0, 0) animated:YES];
    
}


#pragma mark - Private

- (void)scrollToActiveField
{
    CGFloat kbHeight;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
        kbHeight = (self.keyboardHeight) ?: 216.0;
    else
        kbHeight = (self.keyboardHeight) ?: 162;
    
//    [self.pointCreationView.scrollView setContentOffset:CGPointMake(0.0, - self.pointCreationView.scrollView.height + self.pointCreationView.contentView.yOrigin + self.activeField.yOrigin + self.activeField.height + kbHeight + 4) animated:YES];
}

- (BOOL)fieldsAreValidWithAssignment
{
    // TAGS
    NSString *tagText = self.view.tagsTextField.text;
    
    // Check not empty
    if (FTIsEmpty(tagText)) {
        [self.view.tagsTextField becomeFirstResponder];
        return NO;
    }
    else {
        // Get tags from comma-delimitted list
        NSArray *tags = [[[tagText componentsSeparatedByString:@","].rac_sequence
                          map:^id(NSString *tag) {
                              return [tag stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
                          }] array];
        
        // Check all tags are alphanumeric strings
        BOOL allGood = YES;
        for (NSString *tag in tags) {
            if (![tag cyg_isAlphaNumeric]) {
                allGood = NO;
                break;
            }
        }
        
        if (allGood) {
            self.point.tags = tags;
        }
        else {
            self.tagInputAlert = [[UIAlertView alloc] initWithTitle:@"Bad input" message:@"Tags must be comma-delimitted, alphanumeric strings." delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles:nil];
            [self.tagInputAlert show];
            return NO;
        }
    }
    
    // TITLE
    NSString *titleText = self.view.titleTextField.text;
    if (!FTIsEmpty(titleText)) {
        self.point.title = [titleText stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
    }
    
    // AUTHOR
    self.point.author = [CYGUser currentUser];
    
    return YES;
}

- (void)save
{
    if ([self fieldsAreValidWithAssignment]) {
        [self.navigationController popViewControllerAnimated:YES];
        __block CYGPoint *newPoint = self.point;
        [self.point saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [TSMessage showNotificationWithTitle:@"Success" subtitle:@"Point saved." type:TSMessageNotificationTypeSuccess];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationPointAnnotationUpdated object:newPoint];
            }
            else {
                [TSMessage showNotificationWithTitle:@"Error" subtitle:@"Failed to save pin." type:TSMessageNotificationTypeError];
            }
        }];
    }
}


#pragma mark - NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - UIViewController

- (void)loadView
{
     self.view = [[CYGPointCreationView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.titleTextField.delegate = self;
    self.view.tagsTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
                                                 selector:@selector(keyboardWasShown:)
                                                     name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


@end
