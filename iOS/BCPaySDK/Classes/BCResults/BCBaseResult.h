//
//  BCBaseResult.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCPayConstant.h"

#pragma mark BCBaseResult

/**
 *  订单查询结果的基类
 */
@interface BCBaseResult : NSObject

@property (nonatomic, assign) BCObjsType type;
@property (nonatomic, retain) NSString  *bill_no;
@property (nonatomic, assign) NSInteger  total_fee;//NSInteger
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, assign) long long  created_time;//long long
@property (nonatomic, retain) NSString  *channel;

@end
