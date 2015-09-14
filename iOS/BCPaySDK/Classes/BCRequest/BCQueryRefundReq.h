//
//  BCQRefundReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryReq.h"

#pragma mark BCQueryRefundReq
/**
 *  根据条件查询退款记录
 */
@interface BCQueryRefundReq : BCQueryReq //type=103;

@property (nonatomic, retain) NSString *refundno;

@end
