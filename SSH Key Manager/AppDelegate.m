//
//  AppDelegate.m
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 9/10/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    Let's read in the .ssh/config file
    NSString *fileSSHConfig = [NSHomeDirectory() stringByAppendingString: @"/.ssh/config"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileSSHConfig]) {
        BOOL success = [[NSFileManager defaultManager] createFileAtPath:fileSSHConfig contents:nil attributes:nil];
        if (!success){
            NSLog(@"Unable to create %@ file!!! Should display notice and quit, now.", fileSSHConfig);
        }else{
            [@"# Automagically generated by SSH Key Manager, created by Cristoffer Fairweather\n" writeToFile:fileSSHConfig atomically:YES encoding:NSASCIIStringEncoding error:nil];
        }
    }
    [self parseSSHConfigFile:fileSSHConfig];
    
    
//    Okay, then!
//    Let's configure the main window
    [_window applicationReady];
}

-(void) parseSSHConfigFile:(NSString*) fileSSHConfig{
    NSError *error;
    
    NSString* stringSSHFile =[NSString stringWithContentsOfFile:fileSSHConfig encoding:NSASCIIStringEncoding error:&error];
    if(error){
        //There's something wrong!
        //Quit!
        NSLog(@"There was a problem opening the ssh config file for parsing at %@ because of %@", fileSSHConfig, error.description);
        return;
    }
    
    
    NSArray*lines = [stringSSHFile componentsSeparatedByString:@"\n"];
    
    NSMutableArray *configItems = [NSMutableArray new];
    
    NSString *bufferHost = @"";
    for (int a=0; a<lines.count; a++){
        
//      Check for comment
        if([(NSString*)lines[a] hasPrefix:@"#"]){
//          Write out bufferHost
            if(bufferHost.length!=0){
                [configItems addObject:[NSMutableString stringWithString:bufferHost]];
                bufferHost=@"";
            }
            
//          Add comment
            [configItems addObject:[NSMutableString stringWithString:lines[a]]];
            continue;
        }
        
//      Start of Host
        if([(NSString*)lines[a] hasPrefix:@"Host "]){
            
            if(bufferHost.length!=0){
                [configItems addObject:[NSMutableString stringWithString:bufferHost]];
            }
            
            bufferHost = [(NSString*)lines[a] copy];
            
        }else if([(NSString*)lines[a] hasPrefix:@" "] && bufferHost.length > 0){
            bufferHost=[bufferHost stringByAppendingFormat:@"\n%@", lines[a]];
        }
    }
    
//  Write out bufferHost
    if(bufferHost.length!=0){
        [configItems addObject:[NSMutableString stringWithString:bufferHost]];
    }
    
    self.arraySSHConfigItems = configItems;
}

-(void)writeToSSHFile{
    NSMutableString *stringToFile = [NSMutableString new];
    
    for(int b=0; b<self.arraySSHConfigItems.count; b++){
        [stringToFile appendFormat:@"%@\n\n", self.arraySSHConfigItems[b]];
    }

    NSString *fileSSHConfig = [NSHomeDirectory() stringByAppendingString: @"/.ssh/config"];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileSSHConfig];
    [fileHandle truncateFileAtOffset:0]; //Allows us to overwrite all of the file!
    [fileHandle writeData:[stringToFile dataUsingEncoding:NSStringEncodingConversionAllowLossy]];
    [fileHandle closeFile];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES;
}

@end
