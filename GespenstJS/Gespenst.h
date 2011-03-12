//
//  Gespenst.h
//  GespenstJS
//
//  Created by uasi on 11/03/11.
//  Copyright 2011 isdead.info. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface Gespenst : NSObject {
}

@property(retain) NSWindow *window;
@property(retain) WebView *webView;
@property(retain) NSArray *args;
@property(assign) NSUInteger returnValue;
@property(retain) NSString *loadStatus;
@property(retain) NSString *script;
@property(retain) NSString *state;
@property(assign, readonly) NSString *version;
@property(assign) NSString *content;
@property(assign) NSString *userAgent;

- (void)execute:(NSString *)script;

@end
