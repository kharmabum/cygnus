//
//  CYGDefines.h
//  Cygnus
//
//  Created by IO on 2/4/14.
//  Copyright (c) 2014 Fototropik. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DEBUG
#undef NSLog
#define NSLog(args, ...)
#endif

#pragma mark - API

extern NSString *const kCYGParseApplicationId;
extern NSString *const kCYGParseClientKey;

extern NSString *const kCYGTwitterKey;
extern NSString *const kCYGTwitterSecret;


#pragma mark - Fonts

extern NSString *const kCYGRegularFontName;
extern NSString *const kCYGBoldFontName;
extern NSString *const kCYGBoldItalicFontName;
extern NSString *const kCYGItalicFontName;

#pragma mark - Notifications

extern NSString *const kCYGGenericNotification;

#pragma mark - Analytics

extern NSString *const kCYGGenericEvent;
extern NSString *const kCYGGenericEventParam;

#pragma mark - Class Names

extern NSString *const kCYGPointClassName;

