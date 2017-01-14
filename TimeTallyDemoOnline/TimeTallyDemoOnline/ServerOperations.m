//
//  ServerOperations.m
//  TimeTallyDemoOnline
//
//  Created by gongwenkai on 2017/1/14.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "ServerOperations.h"

@implementation ServerOperations
static ServerOperations *instance = nil;

+ (instancetype)sharedInstance
{
    return [[ServerOperations alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)init
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
    });
    return instance;
}



//发送服务器请求加载数据
- (void)loadDataFormServer{
    
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"showusertally.php"]]];
    [quest setHTTPMethod:@"POST"];
    //POST 用户名
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:userName,@"username", nil];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [quest setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //json解码
        NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"server下载结果-----%@",dataStr);
        if ([dataStr isEqualToString:@"0"]) {
            return ;
        }
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if (jsonArray.count != 0) {
            [[CoreDataOperations sharedInstance] loadFromServerWithDataArray:jsonArray];
        }
    }];
    
    [task resume];

}


//上传账单至服务器
- (void)uploadTallyToServer{
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"uploadtally.php"]]];
    [quest setHTTPMethod:@"POST"];
    //POST 信息
    NSArray *postArray = [[CoreDataOperations sharedInstance] getAllTallyWithArray];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:postArray options:NSJSONWritingPrettyPrinted error:nil];
    [quest setHTTPBody:postData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        int flag = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
        NSLog(@"server上传结果 %d",flag);
        if (flag==1 || flag == 9) {
            //写入成功
            for (NSDictionary *dict in postArray) {
                [[CoreDataOperations sharedInstance] uploadServerSucceedWithIdentity:dict[@"identity"]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didUploadTallySuccessed)]) {
                    [self.delegate didUploadTallySuccessed];
                }
            });
           
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didUploadTallyFaild)]) {
                    [self.delegate didUploadTallyFaild];
                }
            });

        }
        
    }];
    
    [task resume];

}

//登录到服务器
- (void)loginWithUser:(NSString*)username andPsw:(NSString*)psw {
    //创建URL请求
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"login.php"]]];
    //post请求
    [quest setHTTPMethod:@"POST"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",psw,@"userpsw", nil];
    //字典转json
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [quest setHTTPBody:postData];
    
    //建立连接
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        int result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
        NSLog(@"server登录结果 %d ",result);

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didLoginBackWithTag:)]) {
                [self.delegate didLoginBackWithTag:result];
            }
            
        });
        
    }];
    
    [task resume];

}

//注册到服务器
- (void)registerWithUser:(NSString*)username andPsw:(NSString*)psw{
    //创建URL请求
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"register.php"]]];
    //post请求
    [quest setHTTPMethod:@"POST"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:username,@"username",psw,@"userpsw", nil];
    //字典转json
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [quest setHTTPBody:postData];
    
    //建立连接
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        int result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
        NSLog(@"server注册结果 %d ",result);
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didRegisterBackWithTag:)]) {
                [self.delegate didRegisterBackWithTag:result];
            }
        });
    }];
    
    [task resume];
}

//从服务器删除账单
- (void)deleteTallyInServerWithIdentity:(NSString*)identity{
    //创建URL请求
    NSMutableURLRequest *quest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kServerUrl stringByAppendingString:@"deletetally.php"]]];
    //post请求
    [quest setHTTPMethod:@"POST"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:identity,@"identity", nil];
    //字典转json
    NSData *postData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    [quest setHTTPBody:postData];
    //建立连接
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:quest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        int result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] intValue];
        if (result == 0) {
            NSLog(@"%d server链接数据库失败",result);
        }else if (result == 1){
            NSLog(@"%d server删除账单成功",result);
        }else if (result == 2){
            NSLog(@"%d server删除账单失败",result);
        }
    }];
    
    [task resume];
}
@end
