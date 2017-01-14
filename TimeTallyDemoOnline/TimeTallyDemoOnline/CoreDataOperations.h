//
//  CoreDataOperations.h
//  TimeTallyDemo
//
//  Created by gongwenkai on 2017/1/9.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TimeTallyDemo+CoreDataModel.h"
#import "AppDelegate.h"
#import "TimeLineModel.h"
#import "TallyListCellModel.h"


@interface CoreDataOperations : NSObject
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//单例
+ (instancetype)sharedInstance;
//从数据库中删除 Tally表中对应identity字段行
- (void)deleteTally:(Tally*)object;

//保存
- (void)saveTally;

//读取对应字段
- (Tally*)getTallyWithIdentity:(NSString *)identity;

//获取对应类型
- (TallyType*)getTallyTypeWithTypeName:(NSString*)typeName;

//读取数据库中的数据  以字典的形式 key：@"日期" object：[账单信息]
- (NSDictionary*)getAllDataWithTimeLineModelDict;

//新增一条账单
- (void)addNewTallyWithTallyType:(NSString*)tallyType andMoney:(double)money;

//修改一条账单
- (void)modifyTallySavedWithIdentity:(NSString *)identity andTallyType:(NSString*)tallyType andMoney:(double)money;

//加载服务器上的数据到本地
- (void)loadFromServerWithDataArray:(NSArray*)array;

//获取账单数组 用于发送到服务器
- (NSArray*)getAllTallyWithArray;

//加载账单类型到数据库
- (void)loadTallyTypeToSqlite;

//标识为identity数据上传成功
- (void)uploadServerSucceedWithIdentity:(NSString*)identity;
@end
