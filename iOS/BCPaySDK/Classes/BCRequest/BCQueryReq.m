//
//  BCQueryReq.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCQueryReq.h"

#pragma mark query request
@implementation BCQueryReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypeQueryReq;
        self.skip = 0;
        self.limit = 10;
        self.starttime = @"";
        self.endtime = @"";
        self.billno = @"";
    }
    return self;
}
@end
