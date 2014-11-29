//
//  AppDelegate.h
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 9/10/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSWindow_SKM.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    int sliderValue;
}

@property (readwrite, assign) int sliderValue;
@property (assign) IBOutlet NSWindow_SKM *window;
@property (strong) NSMutableArray *arraySSHConfigItems;

-(void)writeToSSHFile;

@end
