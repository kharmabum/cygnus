//
//  CYGTokenInputField.m
//  Cygnus
//
//  Created by IO on 2/27/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "CYGTokenInputField.h"
#import "TURecipientsBar.h"
#import "TURecipientsDisplayController.h"


@interface CYGTokenInputField () <TURecipientsBarDelegate, TURecipientsDisplayDelegate>

@property (strong, nonatomic)  TURecipientsBar *recipientsBar;
@property (strong, nonatomic)  TURecipientsDisplayController *displayController;
@property (strong, nonatomic, readwrite) NSMutableArray *tokens; /* List of NSStrings */

@end

@implementation CYGTokenInputField

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
            [self addTokenWithText:tag];
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
    [[self mutableArrayValueForKey:@"tokens"] addObject:recipient.recipientTitle];    
}

//always called
- (void)recipientsDisplayController:(TURecipientsDisplayController *)controller didRemoveRecipient:(id<TURecipient>)recipient
{
    NSUInteger index = [self.tokens indexOfObject:recipient.recipientTitle];
    [[self mutableArrayValueForKey:@"tokens"] removeObjectAtIndex:index];
}

#pragma mark - Private

- (void)setDynamicText
{
    NSDictionary *labelAttributes = @{
                                      NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                      NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                      };
    [[TURecipientsBar appearance] setLabelTextAttributes:labelAttributes];
    
    NSDictionary *summaryAttributes = @{
                                      NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody],
                                      NSForegroundColorAttributeName: [UIColor lightGrayColor]
                                      };
    [[TURecipientsBar appearance] setSummaryTextAttributes:summaryAttributes];
    

    _recipientsBar.textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _recipientsBar.textField.textColor = [UIColor lightGrayColor];
}

- (void)preferredContentSizeChanged
{
    [self setDynamicText];
    [self setNeedsUpdateConstraints];
    [self setNeedsLayout];
}

- (void)addTokenWithText:(NSString *)tokenText
{
    [_recipientsBar addRecipient:[TURecipient recipientWithTitle:tokenText address:nil]];
    [[self mutableArrayValueForKey:@"tokens"] addObject:tokenText];
}

- (void)removeTokenWithText:(NSString *)tokenText
{
    TURecipient *r;
    for (TURecipient *recipient in self.recipientsBar.recipients) {
        if ([recipient.recipientTitle isEqualToString:tokenText]) {
            r = recipient;
            break;
        }
    }
    if (r) [_recipientsBar removeRecipient:r];
}

- (void)removeAllTokens
{
    for (TURecipient *recipient in self.recipientsBar.recipients) {
        [_recipientsBar removeRecipient:recipient];
    }
}

- (RACSignal *)rac_didEndEditingSignal
{
    if (!_rac_didEndEditingSignal) {
        _rac_didEndEditingSignal = [[self rac_signalForSelector:@selector(recipientsBarTextDidEndEditing:)
                                                   fromProtocol:@protocol(TURecipientsBarDelegate)] mapReplace:@YES];
    }
    return _rac_didEndEditingSignal;
}


- (RACSignal *)rac_returnButtonClickedSignal
{
    if (!_rac_returnButtonClickedSignal) {
        _rac_returnButtonClickedSignal = [[self rac_signalForSelector:@selector(recipientsBarReturnButtonClicked:)
                                                   fromProtocol:@protocol(TURecipientsBarDelegate)] mapReplace:@YES];
    }
    return _rac_returnButtonClickedSignal;
}

#pragma mark - UIView

- (BOOL)becomeFirstResponder
{
    return [self.recipientsBar.textField becomeFirstResponder];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _tokens = [NSArray array];
        
        _recipientsBar = [TURecipientsBar autoLayoutView];
        [self addSubview:_recipientsBar];
        _recipientsBar.recipientsBarDelegate = self;
        _recipientsBar.showsAddButton = NO;
        _recipientsBar.label = @"# ";
        _recipientsBar.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _recipientsBar.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField = _recipientsBar.textField;
        
        
        _displayController = [[TURecipientsDisplayController alloc] init];
        _displayController.recipientsBar = _recipientsBar;
        _displayController.delegate = self;
        
        [self setDynamicText];

        //    UIImage *backgroundImage = [[UIImage imageNamed:@"token"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:0.0];
        //    [[TURecipientsBar appearance] setRecipientBackgroundImage:backgroundImage forState:UIControlStateNormal];
        
        // Constraints
        
        [_recipientsBar pinEdges:FTUIViewEdgePinAll toSuperViewWithInset:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(preferredContentSizeChanged)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
    }
    return self;
}

@end
