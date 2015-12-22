//
//  PaySandboxViewController.h
//  BCPay
//
//  Created by Ewenlong03 on 15/11/30.
//  Copyright © 2015年 BeeCloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCPayReq.h"

@interface PaySandboxViewController : UIViewController

@property (nonatomic, strong) NSString *bcId;

@property (nonatomic, strong) BCPayReq *req;

@end
