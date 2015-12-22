//
//  BaiduViewController.h
//  UZApp
//
//  Created by Ewenlong03 on 15/10/31.
//  Copyright © 2015年 APICloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UZAppDelegate.h"

@protocol BaiduViewControllerDelegate <NSObject>

- (void)showBaiduPayResult:(NSDictionary *)result;

@end

@interface BaiduViewController : UIViewController

@property (nonatomic, strong) NSString *url;
@property (nonatomic, weak) id<BaiduViewControllerDelegate> delegate;

@end
