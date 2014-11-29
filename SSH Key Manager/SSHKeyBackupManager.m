//
//  ServerPasswordManager.m
//  Timestream Connect Patriot
//
//  Created by Cris Fairweather on 12/4/13.
//  Copyright (c) 2013 Ntrepid Corp. All rights reserved.
//

#import "SSHKeyBackupManager.h"

#include <CoreFoundation/CoreFoundation.h>
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

#define ServiceName "SSHKeyBackupManager"

@interface SSHKeyBackupManager ()

@end
//
//static BOOL hasUnlockedKeychainYet;
//
//@implementation ServerPasswordManager
//+(OSStatus)saveOrUpdateServerPassword:(NSString *)password forServer:(ServerInstance *)serverInstance{
//    
//    if(![[self getPasswordForServer:serverInstance] isEqualToString:@""]){
//        return [ServerPasswordManager updatePassword:password forServer:serverInstance];
//    }
//    
//    OSStatus status;
//    
//    const char *serverURL = [serverInstance.url cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
//    UInt32 serverURLLen = (UInt32)strlen(serverURL);
//    
//    const char *passwordData = [password cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
//    UInt32 passwordLength = (UInt32)strlen(passwordData);
//    
//    status = SecKeychainAddGenericPassword (
//                                            NULL,            // default keychain
//                                            10,              // length of service name
//                                            ServiceName,    // service name
//                                            serverURLLen,              // length of account name
//                                            serverURL,    // account name
//                                            passwordLength,  // length of password
//                                            passwordData,        // pointer to password data
//                                            NULL             // the item reference
//                                            );
//    return (status);
//}
//
//
//
//+(NSString *)getPasswordForServer:(ServerInstance *)serverInstance{
//    SecKeychainItemRef item = nil;
//    
//    const char *serverURL = [serverInstance.url cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
//    UInt32 serverURLLen = (UInt32)strlen(serverURL);
//    
//    void *passwordData = nil;
//    UInt32 passwordLength = nil;
//    
//    OSStatus osStat = SecKeychainFindGenericPassword (
//                                    NULL,           // default keychain
//                                    10,              // length of service name
//                                    ServiceName,    // service name
//                                    serverURLLen,              // length of account name
//                                    serverURL,
//                                    &passwordLength,  // length of password
//                                    &passwordData,   // pointer to password data
//                                    NULL         // the item reference
//                                    );
//    if(osStat != errSecItemNotFound && passwordData != NULL){
//        NSString *stringPassword = [NSString stringWithCString:passwordData encoding:NSStringEncodingConversionAllowLossy];
//        SecKeychainItemFreeContent (NULL,           //No attribute data to release
//                                    passwordData    //Release data buffer allocated by
//                                    );
//        return stringPassword;
//    }
//    return @"";
//}
//
//+(OSStatus)updatePassword:(NSString*)password forServer:(ServerInstance *)serverInstance{
//    SecKeychainItemRef itemRef = [ServerPasswordManager getKeychainItemRefForServer:serverInstance];
//    
//    const char *passwordData = [password cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
//    UInt32 passwordLength = (UInt32)strlen(passwordData);
//
//    OSStatus status;
//    
//    status = SecKeychainItemModifyAttributesAndData (itemRef,         // the item reference
//                                                     NULL,            // no change to attributes
//                                                     passwordLength,  // length of password
//                                                     passwordData         // pointer to password data
//                                                     );
//    return (status);
//}
//
//+(SecKeychainItemRef)getKeychainItemRefForServer:(ServerInstance*)serverInstance{
//    SecKeychainItemRef item = nil;
//    
//    const char *serverURL = [serverInstance.url cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
//    UInt32 serverURLLen = (UInt32)strlen(serverURL);
//    
//    void *passwordData = nil;
//    UInt32 *passwordLength = nil;
//    
//    OSStatus osStat = SecKeychainFindGenericPassword (
//                                                      NULL,           // default keychain
//                                                      10,              // length of service name
//                                                      ServiceName,    // service name
//                                                      serverURLLen,              // length of account name
//                                                      serverURL,
//                                                      passwordLength,  // length of password
//                                                      passwordData,   // pointer to password data
//                                                      &item         // the item reference
//                                                      );
//    SecKeychainItemFreeContent (NULL,           //No attribute data to release
//                                passwordData    //Release data buffer allocated by
//                                );
//
//    
//    return item;
//}
//
//+(BOOL)unlockKeychain{
//    if (!hasUnlockedKeychainYet) {
//        
//    }
//    return NO;
//}
//
//    
//+(OSStatus)deletePasswordForServer:(ServerInstance *)serverInstance{
//    
//    OSStatus returnStatus = SecKeychainItemDelete([self getKeychainItemRefForServer:serverInstance]);
//    if (returnStatus != noErr)
//    {
//        NSString *errorText = [NSString stringWithFormat: @"Error (%@) - %s", NSStringFromSelector(_cmd), GetMacOSStatusErrorString(returnStatus)];
//        NSLog(@"%@", errorText);
//        return -1;
//    } else {
//        return returnStatus;
//    }
//    
//    return returnStatus;
//}
//@end
