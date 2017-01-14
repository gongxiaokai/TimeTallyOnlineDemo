//
//  ServerOperations.h
//  TimeTallyDemoOnline
//
//  Created by gongwenkai on 2017/1/14.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataOperations.h"


//服务器地址
//static NSString* const kServerUrl = @"http://localhost/timetally/";
static NSString* const kServerUrl = @"http://timetallydemo.duapp.com/";

@protocol ServerOperationsDelegate <NSObject>

@optional

//登录结果回调
- (void)didLoginBackWithTag:(int)tag;
//注册结果回调
- (void)didRegisterBackWithTag:(int)tag;
//成功上传
- (void)didUploadTallySuccessed;
//上传失败
- (void)didUploadTallyFaild;

@end

@interface ServerOperations : NSObject


@property(nonatomic,strong)id<ServerOperationsDelegate> delegate;

+ (instancetype)sharedInstance;
//发送服务器请求加载数据
- (void)loadDataFormServer;
//上传账单至服务器
- (void)uploadTallyToServer;
//服务器删除指定账单
- (void)deleteTallyInServerWithIdentity:(NSString*)identity;

//登录到服务器
- (void)loginWithUser:(NSString*)username andPsw:(NSString*)psw;
//注册到服务器
- (void)registerWithUser:(NSString*)username andPsw:(NSString*)psw;
@end
