//
//  BCQBillsResult.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryBillResult.h"

@implementation BCQueryBillResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeBillResults;
        self.spay_result = NO;
    }
    return self;
}
@end
