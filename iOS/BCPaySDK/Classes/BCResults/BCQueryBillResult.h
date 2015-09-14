//
//  BCQBillsResult.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResult.h"

#pragma mark BCQueryBillResult

/**
 *  支付订单查询结果
 */
@interface BCQueryBillResult : BCBaseResult

@property (nonatomic, assign) BOOL spay_result;

@end
