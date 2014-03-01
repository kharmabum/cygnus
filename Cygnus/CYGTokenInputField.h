//
//  CYGTokenInputField.h
//  Cygnus
//
//  Created by IO on 2/27/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYGTokenInputField : UIView

@property (strong, nonatomic, readonly) NSArray *tokens; /* List of NSStrings */
@property (strong, nonatomic)  UITextField *textField;


@property (strong, nonatomic) RACSignal *rac_didEndEditingSignal;
@property (strong, nonatomic) RACSignal *rac_returnButtonClickedSignal;

- (void)addTokenWithText:(NSString *)tokenText;
- (void)removeTokenWithText:(NSString *)tokenText;
- (void)removeAllTokens;

@end
