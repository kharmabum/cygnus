//
//  CYGTagsInputView.h
//  Cygnus
//
//  Created by IO on 2/27/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYGTagsInputView : UIView

@property (strong, nonatomic)  NSString *activeText;
@property (strong, nonatomic, readonly) NSMutableArray *tokens; /* List of NSStrings */

- (void)addTokenWithText:(NSString *)tokenText;
- (void)removeTokenWithText:(NSString *)tokenText;

@end
