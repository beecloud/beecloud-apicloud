//
//  BCCache.m
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/27/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//

#import "BCPayCache.h"

#import "BCPayConstant.h"

@implementation BCPayCache

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BCPayCache *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BCPayCache alloc] init];
        
        instance.appId = nil;
        instance.sandbox = NO;
        
        instance.networkTimeout = 5.0;
        instance.willPrintLogMsg = NO;
        
    });
    return instance;
}

+ (BOOL)currentMode {
    return [BCPayCache sharedInstance].sandbox;
}

@end
