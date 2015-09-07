//
//  BCRefundStateResp.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResp.h"

/**
 *  查询退款订单状态的响应
 */
@interface BCRefundStatusResp : BCBaseResp

@property (nonatomic, retain) NSString *refundStatus;

@end
