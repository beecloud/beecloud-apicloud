//
//  BCPayResp.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//
#import "BCBaseResp.h"

#pragma mark BCPayResp
/**
 *  支付请求的响应
 */
@interface BCPayResp : BCBaseResp  //type=201;

@property (nonatomic, retain) NSDictionary *paySource;

@end
