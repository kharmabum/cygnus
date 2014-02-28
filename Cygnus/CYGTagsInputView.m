//
//  CYGTagsInputView.m
//  Cygnus
//
//  Created by IO on 2/27/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTagsInputView.h"
#import "TURecipientsBar.h"
#import "TURecipientsDisplayController.h"


@interface CYGTagsInputView () <TURecipientsBarDelegate, TURecipientsDisplayDelegate>

@property (strong, nonatomic)  TURecipientsBar *recipientsBar;
@property (strong, nonatomic)  TURecipientsDisplayController *displayController;



@end

@implementation CYGTagsInputView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _recipientsBar = [[TURecipientsBar alloc] init];
        [self addSubview:_recipientsBar];
        _recipientsBar.recipientsBarDelegate = self;
        _recipientsBar.showsAddButton = NO;
        _recipientsBar.label = @"#:";
        _recipientsBar.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _recipientsBar.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        
        _displayController = [[TURecipientsDisplayController alloc] init];
        _displayController.recipientsBar = _recipientsBar;
        _displayController.delegate = self;

        //    UIImage *backgroundImage = [[UIImage imageNamed:@"token"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];
        //    [[TURecipientsBar appearance] setRecipientBackgroundImage:backgroundImage forState:UIControlStateNormal];
        //    NSDictionary *attributes = @{
        //                                 NSFontAttributeName: [UIFont fontWithName:@"American Typewriter" size:14.0],
        //                                 NSForegroundColorAttributeName: [UIColor yellowColor],
        //                                 };
        //    [[TURecipientsBar appearance] setRecipientTitleTextAttributes:attributes forState:UIControlStateNormal];
        //
        //    NSDictionary *labelAttributes = @{
        //                                      NSFontAttributeName: [UIFont fontWithName:@"Marker Felt" size:14.0],
        //                                      NSForegroundColorAttributeName: [UIColor redColor],
        //                                      };
        //    [[TURecipientsBar appearance] setLabelTextAttributes:labelAttributes];
        
        //searchFieldTextAttributes
        //summaryTextAttributes
        //labelTextAttributes
        
        // Constraints
        
        [_recipientsBar pinEdges:FTUIViewEdgePinAll toSuperViewWithInset:0];
//        [self constrainToHeightOfView:_recipientsBar];
        
    }
    return self;
}

#pragma mark - TURecipientsBarDelegate

- (void)recipientsBarReturnButtonClicked:(TURecipientsBar *)recipientsBar
{
	if (recipientsBar.text.length == 0) {
		[recipientsBar resignFirstResponder];
	}
}

- (void)recipientsBar:(TURecipientsBar *)recipientsBar textDidChange:(NSString *)searchText
{
    if ([searchText containsString:@" "]) {
        NSArray *tags = [[[[searchText componentsSeparatedByString:@" "].rac_sequence
                          map:^id(NSString *tag) {
                              return [tag stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
                          }]
                         filter:^BOOL(NSString *tag) {
                             return tag.length;
                         }]
                         array];
        for (NSString *tag in tags) {
            [recipientsBar addRecipient:[TURecipient recipientWithTitle:tag address:nil]];
        }
        recipientsBar.text = @"";
    }
}

#pragma mark - TURecipientsDisplayDelegate


- (BOOL)recipientsDisplayControllerShouldBeginSearch:(TURecipientsDisplayController *)controller
{
    return NO;
}

//not called on manual/programmatic additions
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didAddRecipient:(id<TURecipient>)recipient
{
    
}

//always called
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didRemoveRecipient:(id<TURecipient>)recipient
{
    
}

@end
