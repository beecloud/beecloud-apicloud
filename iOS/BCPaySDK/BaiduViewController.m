//
//  BaiduViewController.m
//  UZApp
//
//  Created by Ewenlong03 on 15/10/31.
//  Copyright © 2015年 APICloud. All rights reserved.
//

#import "BaiduViewController.h"
#import "NSString+IsValid.h"
#import "NSDictionaryUtils.h"

@interface BaiduViewController ()<UIWebViewDelegate, UIAlertViewDelegate> {
    NSInteger resultCode;
    NSString *resultMsg;
    
    UIWebView *bdWebView;
    UIView *titleView;
    UIButton *backBtn;
}

@end

@implementation BaiduViewController
@synthesize url;

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)viewDidLoad {
    
    bdWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    bdWebView.delegate = self;
    [self.view addSubview:bdWebView];
    
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 66)];
    titleView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:70.0/255.0 blue:67.0/255.0 alpha:1];
    backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 23, 40, 40)];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn setTitle:@"+" forState:UIControlStateNormal];
    backBtn.titleLabel.font= [UIFont systemFontOfSize:40];
    backBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    CGAffineTransform at = CGAffineTransformMakeRotation(M_PI/4);
    [backBtn setTransform:at];
    [titleView addSubview:backBtn];
    [self.view addSubview:titleView];
    
    [bdWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
   
    resultCode = BCErrCodeUserCancel;
    resultMsg = @"支付取消";
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)goBack {
    if (bdWebView.canGoBack) {
        [bdWebView goBack];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"是否要放弃本次交易" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.canGoBack) {
        titleView.alpha = 1;
        if (![self.view.subviews containsObject:titleView]) {
            [self.view addSubview:titleView];
        }
    } else {
        if ([self.view.subviews containsObject:titleView]) {
            [UIView animateWithDuration:0.3 animations:^{
                titleView.alpha = 0;
            } completion:^(BOOL finished) {
                [titleView removeFromSuperview];
            }];
        }
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *localUrl = request.URL;
    if ([localUrl.scheme isEqualToString:@"beecloud"] && [localUrl.host isEqualToString:@"pay_result"]) {
        NSString *paramString = localUrl.query;
        if (paramString.isValid) {
            NSArray *params = [paramString componentsSeparatedByString:@"&"];
            for (NSString *kv in params) {
                NSArray *tempParams = [kv componentsSeparatedByString:@"="];
                if (tempParams.count == 2) {
                    if ([tempParams[0] isEqualToString:@"result"]) {
                        if ([tempParams[1] intValue] == 1) {
                            resultCode = BCSuccess;
                            resultMsg = @"支付成功";
                        } else if ([tempParams[1] intValue] == 2) {
                            resultCode = BCErrCodeFail;
                            resultMsg = @"支付失败";
                        }
                    }
                }
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    
    if (_delegate && [_delegate respondsToSelector:@selector(showBaiduPayResult:)]) {
        [_delegate showBaiduPayResult:@{kKeyResponseResultCode:@(resultCode),
                                        kKeyResponseResultMsg:resultMsg,
                                        kKeyResponseErrDetail:resultMsg}];
    }
}


@end
