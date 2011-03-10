//
//  main.m
//  GespenstJS
//
//  Created by uasi on 11/03/11.
//  Copyright 2011 isdead.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "Gespenst.h"

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    [NSApplication sharedApplication];
    
    AppDelegate *appDelegate = [[[AppDelegate alloc] init] autorelease];
    
    if (argc < 2) {
        printf("Usage: gespenstjs script\n");
    }
    else {
        [NSApp setDelegate:appDelegate];
        [NSApp run];
    }
    
    [pool drain];

    return (int)[appDelegate returnValue];
}

