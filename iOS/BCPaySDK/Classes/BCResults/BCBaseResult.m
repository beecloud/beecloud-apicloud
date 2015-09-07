//
//  BCBaseResult.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseResult.h"

@implementation BCBaseResult

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeBaseResults;
        self.channel = @"";
        self.bill_no = @"";
        self.title = @"";
        self.created_time = 0;
        self.total_fee = 0;
    }
    return self;
}
@end
