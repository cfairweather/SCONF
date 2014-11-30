//
//  SSHHostObject.m
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 10/19/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import "SSHHostObject.h"

@interface SSHHostObject ()
@property BOOL hasInit;
@property NSString *originalString;
@end


@implementation SSHHostObject
@synthesize hostLabel;
@synthesize hostName;
@synthesize hostUsername;
@synthesize altPort;
@synthesize altPortEnabled;
@synthesize sshKeyBackupKey;
@synthesize sshKeyPath;
@synthesize sshKeyBackupEnabled;
@synthesize sshKeyEnabled;
@synthesize portMapTo;
@synthesize portMapFrom;
@synthesize portMapReversed;
@synthesize portMapEnabled;
@synthesize manualOptions;
@synthesize logLevelChanged;
@synthesize logLevel;


-(id)initWithHostString:(NSMutableString *)hostStringReference{
    self = [super init];
    
    if(self){
        self.originalString = [hostStringReference copy];
        self.hostString = hostStringReference;
        [self parseString];
    }
    self.hasInit = YES;
    return self;
}

-(void)parseString{
    self.manualOptions=[NSMutableDictionary new];
    
    NSArray*lines = [self.hostString componentsSeparatedByString:@"\n"];
    for (int h=0; h<lines.count; h++) {
        NSString*line=[lines[h] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray*comps = [line componentsSeparatedByString:@" "];
        
        if([comps[0] isEqualToString:@"Host"]){
            if(comps.count>=2){
                self.hostLabel = comps[1];
            }else{
                self.hostLabel = @"Unknown-Host.local";
            }
        }else if ([comps[0] isEqualToString:@"HostName"]){
            if(comps.count >= 2){
                self.hostName = comps[1];
            }else{
                self.hostName = @"hostname.local";
            }
            
        }else if ([comps[0] isEqualToString:@"User"]){
            if(comps.count >= 2){
                self.hostUsername = comps[1];
            }
            
        }else if ([comps[0] isEqualToString:@"Port"]){
            if(comps.count >= 2 && ![comps[1] isEqualToString:@"22"]){
                self.altPortEnabled = YES;
                self.altPort = [comps[1] intValue];
            }
            
        }else if ([comps[0] isEqualToString:@"IdentityFile"]){
            if(comps.count >= 2){
                //                  Convert ~
                // Keep the ~ and only translate when checking for file existence
                self.sshKeyPath = comps[1];
                self.sshKeyEnabled = YES;
            }
            
        }else if ([comps[0] isEqualToString:@"#SSHKeyBackup"]){
            if(comps.count >= 2){
                self.sshKeyBackupEnabled = YES;
                self.sshKeyBackupKey = comps[1];
            }
            
        }else if ([comps[0] isEqualToString:@"LocalForward"]){
            if(comps.count >= 3){
                self.portMapEnabled = YES;
                self.portMapFrom = comps[1];
                self.portMapTo = comps[2];
            }else{
                //                    Error or something? This is invalid.
            }
        }else if ([comps[0] isEqualToString:@"LogLevel"]){
            if(comps.count >= 2){
                self.logLevelChanged=YES;
                self.logLevel=comps[1];
            }
        }else if ([comps[0] isEqualToString:@"DynamicFoward"]){
            if(comps.count >= 2){
#warning Still need to implement
                //                    self.hostName = comps[1];
            }
        }else if ([comps[0] isEqualToString:@"RemoteForward"]){
            if(comps.count >= 3){
                self.portMapEnabled = YES;
                self.portMapFrom = comps[1];
                self.portMapTo = comps[2];
                self.portMapReversed = YES;
            }else{
                //                    Error or something? This is invalid.
            }
        }else {
            
            NSArray * newArr = [comps subarrayWithRange:NSMakeRange(1, comps.count-1)];
            [self.manualOptions setObject:[newArr componentsJoinedByString:@" "] forKey:comps[0]];
            
        }
        
    }

}

-(void)revertValues{
    [self.hostString setString:self.originalString];
    
    self.hasInit = NO;
    [self parseString];
    [self updateHostString];
}

-(void)commitValues{
    self.originalString = [self.hostString copy];
}


-(void)updateHostString{
    if(!self.hasInit){
        return;
    }
    NSMutableString *hostStringNew = [NSMutableString stringWithFormat:@"Host %@\n  HostName %@\n", self.hostLabel, self.hostName];
    
    if (self.hostUsername && ![self.hostUsername isEqualToString:@""]) {
        [hostStringNew appendFormat:@"  User %@\n", self.hostUsername];
    }
    
    if(self.altPortEnabled && self.altPort != 0 && self.altPort != 22){
        [hostStringNew appendFormat:@"  Port %d\n", self.altPort];
    }
    
    if(self.sshKeyEnabled && self.sshKeyPath && ![self.sshKeyPath isEqualToString:@""]){
        NSString *path = self.sshKeyPath;
        NSRange search = [path rangeOfString:@"~"];
        
        if(search.location==0){
            path = [path stringByReplacingCharactersInRange:search withString:NSHomeDirectory()];
        }
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [hostStringNew appendFormat:@"  IdentityFile %@\n", self.sshKeyPath];
        }else{
//            Give some kind of file not found error
//            User will have to clear box, update from backup, or commit hari kari.
        }
    }
    
    if(self.sshKeyBackupEnabled){
//        Generate Key if !exists
        if(!self.sshKeyBackupKey || [self.sshKeyBackupKey isEqualToString:@""]){
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            
            self.sshKeyBackupKey = [NSString stringWithFormat:@"SSHKey%@", uuidStr];
        }
        
        [hostStringNew appendFormat:@"  #SSHKeyBackup %@\n", self.sshKeyBackupKey];
    }
    
    if(self.portMapEnabled && self.portMapFrom && ![self.portMapFrom isEqualToString:@""] && self.portMapTo && ![self.portMapTo isEqualToString:@""]){
        
        NSString *type = @"LocalForward";
        
        if(self.portMapReversed){
            type=@"RemoteForward";
        }
        
        
        [hostStringNew appendFormat:@"  %@ %@ %@\n", type, self.portMapFrom, self.portMapTo];
    }
    
    if(self.logLevelChanged){
        [hostStringNew appendFormat:@"  %@ %@\n", @"LogLevel", self.logLevel];
    }
    
    if(self.manualOptions){
        for(int a=0; a<self.manualOptions.count; a++){
            NSString *key = [self.manualOptions allKeys][a];
            [hostStringNew appendFormat:@"  %@ %@\n", key, [self.manualOptions objectForKey:key]];
        }
    }
    
    [self.hostString setString:hostStringNew];
}



//Overrides...
-(void)setHostLabel:(NSString *)hl{
    hostLabel=hl;
    [self updateHostString];
}
-(void)setHostName:(NSString *)hn{
    hostName=hn;
    [self updateHostString];
}
-(void)setHostUsername:(NSString *)hu{
    hostUsername=hu;
    [self updateHostString];
}
-(void)setAltPort:(int)ap{
    altPort=ap;
    [self updateHostString];
}
-(void)setAltPortEnabled:(BOOL)ape{
    altPortEnabled=ape;
    [self updateHostString];
}
-(void)setSshKeyEnabled:(BOOL)ske{
    sshKeyEnabled=ske;
    [self updateHostString];
}
-(void)setSshKeyPath:(NSString *)skp{
    sshKeyPath=skp;
    [self updateHostString];
}
-(void)setSshKeyBackupEnabled:(BOOL)skbe{
    sshKeyBackupEnabled=skbe;
    [self updateHostString];
}
-(void)setSshKeyBackupKey:(NSString *)skbk{
    sshKeyBackupKey=skbk;
    [self updateHostString];
}
-(void)setPortMapEnabled:(BOOL)pme{
    portMapEnabled=pme;
    [self updateHostString];
}
-(void)setPortMapFrom:(NSString *)pmf{
    portMapFrom=pmf;
    [self updateHostString];
}
-(void)setPortMapTo:(NSString *)pmt{
    portMapTo=pmt;
    [self updateHostString];
}
-(void)setPortMapReversed:(BOOL)pmr{
    portMapReversed=pmr;
    [self updateHostString];
}

-(void)setManualOptions:(NSMutableDictionary *)mo{
    manualOptions=mo;
    [self updateHostString];
}

-(void)setLogLevel:(NSString *)ll{
    logLevel = ll;
    [self updateHostString];
}
-(void)setLogLevelChanged:(BOOL)llc{
    logLevelChanged=llc;
    [self updateHostString];
}

@end
