//
//  BCRefundStateReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayConstant.h"

/**
 *  查询一笔退款的订单的状态，目前仅支持“WX”渠道
 */
@interface BCRefundStatusReq : BCBaseReq

@property (nonatomic, retain) NSString *refundno;

@end
