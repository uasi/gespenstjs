//
//  AppDelegate.h
//  GespenstJS
//
//  Created by uasi on 11/03/11.
//  Copyright 2011 isdead.info. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Gespenst.h"


@interface AppDelegate : NSObject {
    Gespenst *gespenst_;
}

@property(retain) Gespenst *gespenst;

- (NSInteger)returnValue;

@end
