//
//  ServerPasswordManager.h
//  Timestream Connect Patriot
//
//  Created by Cris Fairweather on 12/4/13.
//  Copyright (c) 2013 Ntrepid Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerInstance.h"

@interface ServerPasswordManager : NSObject

+(OSStatus)saveOrUpdateServerPassword:(NSString*)password forServer:(ServerInstance*)serverInstance;
+(NSString*)getPasswordForServer:(ServerInstance*)serverInstance;
+(OSStatus)deletePasswordForServer:(ServerInstance*)serverInstance;

@end
