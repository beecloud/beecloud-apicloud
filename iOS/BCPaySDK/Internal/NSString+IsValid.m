//
//  NSString+NSString_IsValid.m
//  BCPay
//
//  Created by Ewenlong03 on 15/8/28.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "NSString+IsValid.h"

@implementation NSString (IsValid)

- (BOOL)isValid {
    if (self == nil || (NSNull *)self == [NSNull null] || self.length == 0 ) return NO;
    return YES;
}

- (BOOL)isValidIdentifier {
    if (!self.isValid) return NO;
    // First letter not a letter.
    if (![BCPayUtil isLetter:[self characterAtIndex:0]]) return NO;
    for (NSUInteger i = 1; i < self.length; i++) {
        unichar ch = [self characterAtIndex:i];
        // Invalid character.
        if (![BCPayUtil isLetter:ch] && ![BCPayUtil isDigit:ch] && ch != '_') return NO;
    }
    // Identifier ending with "__" is reserved.
    if ([self hasSuffix:@"__"]) return NO;
    return YES;
}

- (BOOL)isValidTraceNo {
    if (!self.isValid) return NO;
    for (NSUInteger i = 0; i < self.length; i++) {
        unichar ch = [self characterAtIndex:i];
        // Invalid character.
        if (![BCPayUtil isLetter:ch] && ![BCPayUtil isDigit:ch]) return NO;
    }
    return YES;
}

- (BOOL)isPureInt {
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isPureFloat {
    NSScanner *scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}
@end
