//
//  BCPayCache.h
//  BeeCloud SDK
//
//  Created by Junxian Huang on 2/27/14.
//  Copyright (c) 2014 BeeCloud Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

/*!
 This header file is *NOT* included in the public release.
 */

/**
 *  BCCache stores system settings and content caches.
 */
@interface BCPayCache : NSObject

/**
 *  App key obtained when registering this app in BeeCloud website. Change this value via [BeeCloud setAppKey:];
 */
@property (nonatomic, strong) NSString *appId;

/**
 *  YES 表示当前是沙箱环境，不产生真实的交易
 *  NO  表示当前是生产环境，产生真实的交易
 *  默认是生产环境
 */
@property (nonatomic, assign) BOOL sandbox;

/**
 *  Default network timeout in seconds for all network requests. Change this value via [BeeCloud setNetworkTimeout:];
 */
@property (nonatomic) NSTimeInterval networkTimeout;

/**
 *  Mark whether print log message.
 */
@property (nonatomic, assign) BOOL willPrintLogMsg;

/**
 *  Get the sharedInstance of BCCache.
 *
 *  @return BCCache shared instance.
 */
+ (instancetype)sharedInstance;

/**
 *  获取当前环境模式
 *
 *  @return YES代表沙箱测试环境；NO代表生产环境。
 */
+ (BOOL)currentMode;

@end
