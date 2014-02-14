//
//  NSString+CYGAdditions.m
//  Cygnus
//
//  Created by IO on 2/13/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import "NSString+CYGAdditions.h"

@implementation NSString (CYGAdditions)

- (BOOL) cyg_isAlphaNumeric
{
    NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return ([self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

@end
