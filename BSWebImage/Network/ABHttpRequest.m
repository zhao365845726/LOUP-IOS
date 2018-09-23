//
//  ABHttpRequest.m
//  AiBanClient
//
//  Created by feirong on 2018/9/7.
//  Copyright © 2018年 aiban. All rights reserved.
//

#import "ABHttpRequest.h"
#import "AFNetworking.h"
#import "YSLoginViewController.h"
#import "YSTipLabelHUD.h"
#import "YSLoadingHUD.h"

@implementation ABHttpRequest

+ (void)ASyncGET:(NSString *)url andParameters:(NSMutableDictionary *)parameters  andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success,int code, NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure
{
    [self AFHTTPRequest:url andParameters:parameters andHttpRequestType:RequestTypeGET andTimeOut:seconds loading:(BOOL)loading success:success failure:failure];
}

+ (void)ASyncPOST:(NSString *)url andParameters:(NSMutableDictionary *)parameters andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success, int code,NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure;
{
    [self AFHTTPRequest:url andParameters:parameters andHttpRequestType:RequestTypePOST andTimeOut:seconds loading:(BOOL)loading success:success failure:failure];
}

+ (void)ASyncPUT:(NSString *)url andParameters:(NSMutableDictionary *)parameters  andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success, int code,NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure
{
    [self AFHTTPRequest:url andParameters:parameters andHttpRequestType:RequestTypePUT andTimeOut:seconds loading:(BOOL)loading success:success failure:failure];
}

+ (void)ASyncDELETE:(NSString *)url andParameters:(NSMutableDictionary *)parameters andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success,int code, NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure
{
    [self AFHTTPRequest:url andParameters:parameters andHttpRequestType:RequestTypeDELETE andTimeOut:seconds loading:(BOOL)loading success:success failure:failure];
}

+ (void)AFHTTPRequest:(NSString *)url andParameters:(NSMutableDictionary *)params andHttpRequestType:(NSInteger)reqType andTimeOut:(int)seconds loading:(BOOL)loading success:(void (^)(BOOL success, int code, NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure {
    
    [[YSLoadingHUD shareLoadingHUD] show];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    //解决后台数据库默认的NULL导致Crash问题，去除NULL值
    AFJSONResponseSerializer* response = [AFJSONResponseSerializer serializer];
    response.removesKeysWithNullValues = YES;
    manager.responseSerializer = response;
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript", @"text/html", nil];

    //设置超时时间，需要序列化后调用
    manager.requestSerializer.timeoutInterval = seconds;
    
    NSString* urlString = [NSString stringWithFormat:@"%@%@", KAppBaseUrl, url];

    //请求头存放信息
    NSString* token = [[NSUserDefaults standardUserDefaults]objectForKey:@"token"];
    if(token.length>0){
        [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
    [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"mobileType"];
    
    if(reqType == RequestTypeGET){
        NSMutableString* url = [NSMutableString stringWithFormat:@"%@",urlString];
        
        NSArray* allkeys = [params allKeys];
        for(int i=0; i<allkeys.count; i++){
            NSString* string;
            if(i==0){
                string = [NSString stringWithFormat:@"?%@=%@",allkeys[i],params[allkeys[i]]];
            }else{
                string = [NSString stringWithFormat:@"&%@=%@",allkeys[i],params[allkeys[i]]];
            }
            [url appendString:string];
        }
        NSLog(@"GET请求接口：URL = %@\n token = %@\n",url,[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
        [manager GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self successBlock:responseObject andUrl:urlString success:success failure:failure];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self failureBlockWithUrl:urlString failure:failure Error:error];
        }];
        
    }else if(reqType == RequestTypePOST){
        NSLog(@"请求接口：%@:\n 参数：%@\n token = %@\n",urlString,params,[[NSUserDefaults standardUserDefaults] objectForKey:@"token"]);
        [manager POST:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self successBlock:responseObject andUrl:urlString success:success failure:failure];

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self failureBlockWithUrl:urlString failure:failure Error:error];

        }];
    }
}

+ (void)successBlock:(id)responseObject andUrl:(NSString*)urlString success:(void (^)(BOOL success, int code, NSString *msg,id responseObject))success failure:(void (^)(NSString *msg))failure
{
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    id jsStr = responseObject;
    NSLog(@"返回接口：%@:\n 返回数据：%@",urlString,jsStr);
    if (jsStr!= [NSNull null] && jsStr != nil &&  [jsStr isKindOfClass:[NSDictionary class]] && ![jsStr isKindOfClass:[NSNull class]]) {
        NSString *status = [NSString stringWithFormat:@"%@", jsStr[@"status_code"]];
        NSString *info = [NSString stringWithFormat:@"%@", jsStr[@"status_message"]];
        id result = jsStr[@"data"];
        if([result isEqual:[NSNull null]]){
            result = nil;
        }
        if([self chekStatus:status]) {
            success(YES, [status intValue],info, result);
        } else {
            success(NO, [status intValue],info, result);
            
            [[YSTipLabelHUD shareTipLabelHUD]showTipWithText:info];
        }
    } else {
        NSString *msg = @"数据异常";
        failure(msg);
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

+ (void)failureBlockWithUrl:(NSString*)urlString failure:(void (^)(NSString *msg))failure Error:(NSError * _Nonnull)error
{
    [[YSLoadingHUD shareLoadingHUD] dismiss];
    
    //可以根据具体的code值区分是什么原因导致失败
    NSLog(@"返回接口：%@:\n 返回数据：%@",urlString,error.description);
    NSString *msg = @"服务器无响应";
    if(error.code == -1009){
        msg = @"没有网络连接，请检查网络";
    }
    if(error.code == 3840){
        msg = @"数据解析异常";
    }
    failure(msg);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [[YSTipLabelHUD shareTipLabelHUD]showTipWithText:msg];
    
}

+ (BOOL)chekStatus:(NSString *)status {
    int code = [status intValue];
    switch (code) {
        case 200:
            return YES;
            break;
        //其他的Code统一在这里处理
        case 401:
          
            return NO;
            break;
        default:
            return NO;
            break;
    }
}

+ (UIViewController *)getCurrentVC {
    
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    if (!window) {
        return nil;
    }
    UIView *tempView;
    for (UIView *subview in window.subviews) {
        if ([[subview.classForCoder description] isEqualToString:@"UILayoutContainerView"]) {
            tempView = subview;
            break;
        }
    }
    if (!tempView) {
        tempView = [window.subviews lastObject];
    }
    
    id nextResponder = [tempView nextResponder];
    while (![nextResponder isKindOfClass:[UIViewController class]] || [nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UITabBarController class]]) {
        tempView =  [tempView.subviews firstObject];
        
        if (!tempView) {
            return nil;
        }
        nextResponder = [tempView nextResponder];
    }
    return  (UIViewController *)nextResponder;
}

- (void)dealloc
{
    NSLog(@"ABHttpRequest dealloc");
}

@end
