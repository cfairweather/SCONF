//
//  ServerPasswordManager.h
//  Timestream Connect Patriot
//
//  Created by Cris Fairweather on 12/4/13.
//  Copyright (c) 2013 Ntrepid Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSHKeyBackupManager : NSObject

+(NSString*)sshKeyFetchBackup:(NSString*)withUID;

+(BOOL)sshKeySetBackup:(NSString*)withUID andKey:(NSString*)key;

@end
