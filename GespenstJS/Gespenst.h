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
    NSWindow *window_;
    WebView *webView_;
    NSArray *args_;
    NSUInteger returnValue_;
    NSString *loadStatus_;
    NSString *script_;
    NSString *state_;
    
    // Unused but should exist for a certain reason...
    NSString *version_;
    NSString *content_;
    NSString *userAgent_;
}

@property(retain) NSWindow *window;
@property(retain) WebView *webView;
@property(retain) NSArray *args;
@property(assign) NSUInteger returnValue;
@property(retain) NSString *loadStatus;
@property(retain) NSString *script;
@property(retain) NSString *state;
@property(assign) NSString *content;
@property(assign) NSString *userAgent;

- (void)execute:(NSString *)script;

@end
