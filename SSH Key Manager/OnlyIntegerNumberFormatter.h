//
//  OnlyIntegerNumberFormatter.h
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 10/19/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlyIntegerNumberFormatter : NSNumberFormatter
- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error;
@end
