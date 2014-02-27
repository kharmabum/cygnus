//
//  CYGPointCreationViewController.m
//  Cygnus
//
//  Created by IO on 2/17/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGPointCreationViewController.h"
#import "CYGMainViewController.h"
#import "CYGManager.h"
#import "CYGPoint.h"
#import "CYGTag.h"
#import "CYGUser.h"
#import "CYGPointAnnotation.h"
#import "CYGPointCreationView.h"
#import <TSMessages/TSMessage.h>
#import "MRProgress.h"

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
    if (textField == self.view.titleTextField) {
        NSUInteger remainder = 25 - textField.text.length;
        self.view.titleLengthLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)remainder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    [self scrollToActiveField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.view.titleTextField) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        if ((newLength <= 25)|| returnKey) {
            self.view.titleLengthLabel.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)(25 - newLength)];
            return YES;
        } else {
            return (newLength < textField.text.length);
        }
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.view.tagsTextField){
        [self.view.titleTextField becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
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
        NSArray *tags = [[[tagText componentsSeparatedByString:@" "].rac_sequence
                          map:^id(NSString *tag) {
                              return [tag stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
                          }]
                          array];
        
        // Make unique
        NSOrderedSet *tagsSet = [NSOrderedSet orderedSetWithArray:tags];
        // Check all tags are alphanumeric strings
        BOOL allGood = YES;
        for (NSString *tag in tagsSet) {
            if (![tag cyg_isAlphaNumeric]) {
                allGood = NO;
                break;
            }
        }
        
        if (allGood) {
            self.point.tags = self.tags = [tagsSet array];
        }
        else {
            self.tagInputAlert = [[UIAlertView alloc] initWithTitle:@"Bad input" message:@"Tags must be space-delimitted, alphanumeric strings." delegate:self cancelButtonTitle:@"Lol, OK." otherButtonTitles:nil];
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
        [MRProgressOverlayView showOverlayAddedTo:self.mainViewController.view animated:YES];
        CYGPoint *newPoint = self.point;
        [self.point saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [MRProgressOverlayView dismissOverlayForView:self.mainViewController.view animated:YES];
                [self.mainViewController switchToMapView];
                [[NSNotificationCenter defaultCenter] postNotificationName:kCYGNotificationPointAnnotationUpdated object:newPoint];
                
                for (NSString *tag in newPoint.tags) {
                    PFQuery *query = [CYGTag query];
                    [query whereKey:kCYGTagTitleKey matchesRegex:[NSString stringWithFormat:@"^%@$", tag] modifiers:@"i"]; //case insensitive
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error) {
                            //TODO: handle error or case where objects.count > 1
                        }
                        else {
                            CYGTag *tagObject = [objects firstObject];
                            if (tagObject) {
                                [tagObject.points addObject:newPoint];
                                [tagObject incrementKey:kCYGTagTotalUsageCountKey];
                                [tagObject saveEventually];
                                newPoint.tagObjects = [newPoint.tagObjects arrayByAddingObject:tagObject];
                                [newPoint saveEventually];
                            }
                            else {
                                tagObject = [CYGTag object];
                                tagObject.title = [tag lowercaseString];
                                tagObject.totalUsageCount = 1;
                                [tagObject.points addObject:newPoint];
                                newPoint.tagObjects = [newPoint.tagObjects arrayByAddingObject:tagObject];
                                [newPoint saveEventually]; // saves both newPoint and tagObject
                            }
                        }
                    }];
                }
            }
            else {
                [MRProgressOverlayView dismissOverlayForView:self.mainViewController.view animated:YES];
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

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (parent) {
        self.view.titleTextField.text = @"";
    }
}

- (void)loadView
{
     self.view = [[CYGPointCreationView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.titleTextField.delegate = self;
    self.view.tagsTextField.delegate = self;
    [self.view.saveButton setTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    RAC(self.view.tagsTextField, text) = [[RACObserve(self, tags) deliverOn:RACScheduler.mainThreadScheduler]
                                          map:^id(NSArray *tags) {
                                              return [tags componentsJoinedByString:@" "];
                                          }];

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
