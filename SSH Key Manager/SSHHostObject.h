//
//  SSHHostObject.h
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 10/19/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface SSHHostObject : NSObject

@property (strong, atomic) NSMutableString* hostString;

@property (strong, nonatomic) NSString *hostLabel;
@property (strong, nonatomic) NSString *hostName;
@property (strong, nonatomic) NSString *hostUsername;

@property (nonatomic) BOOL altPortEnabled;
@property (nonatomic)  int altPort;

@property (nonatomic) BOOL logLevelChanged;
@property (nonatomic) NSString* logLevel;

@property (nonatomic)  BOOL sshKeyEnabled;
@property (strong, nonatomic) NSString* sshKeyPath;
@property (nonatomic)  BOOL sshKeyBackupEnabled;
@property (strong, nonatomic) NSString* sshKeyBackupKey;

@property (nonatomic)  BOOL portMapEnabled;
@property (strong, nonatomic) NSString *portMapFrom;
@property (strong, nonatomic) NSString *portMapTo;
@property (nonatomic)  BOOL portMapReversed;

@property (strong, nonatomic) NSMutableDictionary *manualOptions;


+(NSDictionary*)kSSHCONFIG_INFO;
+(NSArray*)kSSHCONFIG_KEYWORDS;


-(id)initWithHostString:(NSMutableString*)hostStringReference;

-(void)updateHostString;

-(void)revertValues;
-(void)commitValues;
@end
