//
//  AppDelegate.m
//  GespenstJS
//
//  Created by uasi on 11/03/11.
//  Copyright 2011 isdead.info. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

@synthesize gespenst = gespenst_;

- (NSInteger)returnValue
{
    return [[self gespenst] returnValue];
}

@end


@implementation AppDelegate (NSApplicationDelegate)

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self setGespenst:[[[Gespenst alloc] init] autorelease]];
    NSString *scriptFileName = [[[NSProcessInfo processInfo] arguments] objectAtIndex:1];
    [[self gespenst] execute:scriptFileName];
    
}

@end
