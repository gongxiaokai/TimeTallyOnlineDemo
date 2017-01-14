//
//  CoreDataOperations.m
//  TimeTallyDemo
//
//  Created by gongwenkai on 2017/1/9.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "CoreDataOperations.h"

@interface CoreDataOperations()
@end

@implementation CoreDataOperations

static CoreDataOperations *instance = nil;

+ (instancetype)sharedInstance
{
    return [[CoreDataOperations alloc] init];
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
        if (instance) {
            instance.managedObjectContext = ((AppDelegate*)[UIApplication sharedApplication].delegate).persistentContainer.viewContext;
        }
    });
    return instance;
}

//从数据库中删除 Tally表中某一数据
- (void)deleteTally:(Tally*)object {
    [self.managedObjectContext deleteObject:object];
    [self saveTally];
}

//保存
- (void)saveTally {
    [self.managedObjectContext save:nil];
}

//读取对应字段
- (Tally*)getTallyWithIdentity:(NSString *)identity {
    //从数据库中查找 Tally表中对应identity字段行
    NSFetchRequest *fetchRequest = [Tally fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return [fetchedObjects firstObject];
}

//获取对应类型
- (TallyType*)getTallyTypeWithTypeName:(NSString*)typeName {
    //设置账单类型
    NSFetchRequest *ftype = [TallyType fetchRequest];
    NSPredicate *ptype = [NSPredicate predicateWithFormat:@"typename = %@",typeName];
    ftype.predicate = ptype;
    NSArray<TallyType *> *sstype = [self.managedObjectContext executeFetchRequest:ftype error:nil];
    return [sstype firstObject];
}

//读取数据库中的数据  以字典的形式 key：@"日期" object：[账单信息]
- (NSDictionary*)getAllDataWithTimeLineModelDict{
    //先查询日期 遍历日期表
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TallyDate" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSError *error = nil;
    NSArray<TallyDate*> *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //再查询该日期下的tally表
    for (TallyDate *date in fetchedObjects) {
        NSString *key = date.date;
        NSFetchRequest *fetchRequest2 = [Tally fetchRequest];
        //在tally表中 筛选 为该日期的tally 并逆序排列
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateship.date = %@",key];
        [fetchRequest2 setPredicate:predicate];
        NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
        [fetchRequest2 setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor2, nil]];
        NSError *error = nil;
        NSArray<Tally*> *fetchedObjects2 = [self.managedObjectContext executeFetchRequest:fetchRequest2 error:&error];
        NSMutableArray *array = [NSMutableArray array];
        
        //遍历 tally表 将表中的每个结果保存下来
        NSString *currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        for (Tally *tally in fetchedObjects2) {
            if ([tally.usership.username isEqualToString:currentUser]) {
                TimeLineModel *model = [[TimeLineModel alloc] init];
                model.tallyDate = tally.dateship.date;
                model.tallyIconName = tally.typeship.typeicon;
                model.tallyMoney = tally.income > 0 ? tally.income:tally.expenses;
                model.tallyMoneyType = tally.income > 0 ? TallyMoneyTypeIn:TallyMoneyTypeOut;
                model.tallyType = tally.typeship.typename;
                model.identity = tally.identity;
                model.income = tally.income;
                model.expense = tally.expenses;
                [array addObject:model];
            }
        }
        [dict setObject:array forKey:key];
    }
    return dict;
}

//新增一个账单  账单类型 和 收支
- (void)addNewTallyWithTallyType:(NSString*)tallyType andMoney:(double)money{
    //存数据
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    //查询有无对应的date 有则使用无则创建
    NSFetchRequest *fdate = [TallyDate fetchRequest];
    NSArray<NSSortDescriptor *> *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    fdate.sortDescriptors = sortDescriptors;
    NSPredicate *p = [NSPredicate predicateWithFormat:@"date = %@",dateString];
    fdate.predicate = p;
    NSArray<TallyDate *> *ss = [self.managedObjectContext executeFetchRequest:fdate error:nil];
    TallyDate *date;
    if (ss.count > 0) {
        date = ss[0];
    } else {
        date = [[TallyDate alloc] initWithContext:self.managedObjectContext];
        date.date = dateString;
    }
    
    //查询有无对应的user 有则使用无则创建
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSFetchRequest *fuser = [Users fetchRequest];
    NSPredicate *puser = [NSPredicate predicateWithFormat:@"username = %@",userName];
    fuser.predicate = puser;
    NSArray<Users *> *userArray = [self.managedObjectContext executeFetchRequest:fuser error:nil];
    Users *user;
    if (userArray.count > 0) {
        user = userArray[0];
    } else {
        user = [[Users alloc] initWithContext:self.managedObjectContext];
        user.username = userName;
    }
    
    //记账模型创建
    Tally *model = [[Tally alloc] initWithContext:self.managedObjectContext];
    NSFetchRequest *ftype = [TallyType fetchRequest];
    NSPredicate *ptype = [NSPredicate predicateWithFormat:@"typename = %@",tallyType];
    ftype.predicate = ptype;
    NSArray<TallyType *> *sstype = [self.managedObjectContext executeFetchRequest:ftype error:nil];
    TallyType *type = [sstype firstObject];
    //给关系赋值
    model.typeship = type;
    model.dateship = date;
    model.usership = user;
    model.flag = 0;
    model.identity = [NSString stringWithFormat:@"%@", [model objectID]];
    model.timestamp = [[NSDate date] timeIntervalSince1970];
    if ([tallyType isEqualToString:@"工资"]) {
        model.income = money;
        model.expenses = 0;
    } else {
        model.expenses = money;
        model.income = 0;
    }
    //存
    [self.managedObjectContext save:nil];
}

//修改账单
- (void)modifyTallySavedWithIdentity:(NSString *)identity andTallyType:(NSString*)tallyType andMoney:(double)money {
    TallyType *type = [self getTallyTypeWithTypeName:tallyType];
    
    //配置当前账单
    Tally *tally = [self getTallyWithIdentity:identity];
    tally.typeship = type;
    tally.flag = 0;
    if ([tallyType isEqualToString:@"工资"]) {
        tally.income = money;
        tally.expenses = 0;
    } else {
        tally.expenses = money;
        tally.income = 0;
    }
    [self saveTally];
}

//加载服务器上的数据到本地
- (void)loadFromServerWithDataArray:(NSArray*)array{
    if (array.count == 0) {
        return;
    }
    for (NSDictionary *dict in array) {
        //查询有无对应的identity
        NSFetchRequest *fetchRequest = [Tally fetchRequest];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity = %@", dict[@"identity"]];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        //有就返回
        if (fetchedObjects.count > 0) {
            return;
        }
        //没有则将数据写入本地数据库
        //创建日期
        NSFetchRequest *dateFetchRequest = [TallyDate fetchRequest];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date = %@", dict[@"date"]];
        [dateFetchRequest setPredicate:datePredicate];
        NSArray *dateFetchedObjects = [self.managedObjectContext executeFetchRequest:dateFetchRequest error:&error];
        TallyDate *currentDate;
        if (dateFetchedObjects.count == 0) {
            TallyDate *newDate = [[TallyDate alloc] initWithContext:self.managedObjectContext];
            newDate.date = dict[@"date"];
            currentDate = newDate;
        }else{
            currentDate = [dateFetchedObjects firstObject];
        }
        
        //查询有无对应的user 有则使用无则创建
        NSFetchRequest *fuser = [Users fetchRequest];
        NSPredicate *puser = [NSPredicate predicateWithFormat:@"username = %@",dict[@"username"]];
        fuser.predicate = puser;
        NSArray<Users *> *userArray = [self.managedObjectContext executeFetchRequest:fuser error:nil];
        Users *currentUser;
        if (userArray.count == 0) {
            currentUser = [[Users alloc] initWithContext:self.managedObjectContext];
            currentUser.username = dict[@"username"];
        } else {
            currentUser = userArray[0];
        }
        
        NSFetchRequest *ftype = [TallyType fetchRequest];
        NSPredicate *ptype = [NSPredicate predicateWithFormat:@"typename = %@",dict[@"typename"]];
        ftype.predicate = ptype;
        NSArray<TallyType *> *sstype = [self.managedObjectContext executeFetchRequest:ftype error:nil];
        TallyType *currentType = [sstype firstObject];
        
        NSLog(@"%@",currentType.typename);
        
        Tally *currentTally = [[Tally alloc] initWithContext:self.managedObjectContext];
        currentTally.dateship = currentDate;
        currentTally.typeship = currentType;
        currentTally.usership = currentUser;
        currentTally.income = [dict[@"income"] doubleValue];
        currentTally.expenses = [dict[@"expenses"] doubleValue];
        currentTally.timestamp = [dict[@"timestamp"] doubleValue];
        currentTally.identity = dict[@"identity"];
        currentTally.flag = [dict[@"flag"] intValue];
        
        [self saveTally];
        
        

    }
}

//获取账单数组 用于发送到服务器
- (NSArray*)getAllTallyWithArray{
    NSFetchRequest *fetchRequest = [Tally fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"usership.username = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    //筛flag为0的发送
    NSPredicate *flagPre = [NSPredicate predicateWithFormat:@"flag = %d",0];

    fetchedObjects = [fetchedObjects filteredArrayUsingPredicate:flagPre];
    NSMutableArray *resultArray = [NSMutableArray array];
    //每次最多上传10条
    for (int i = 0; i < fetchedObjects.count; i++) {
        if (i == 9) {
            return resultArray;
        }
        Tally *tally = fetchedObjects[i];
        if (tally.flag == 0) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[@"username"] = tally.usership.username;
            dict[@"date"] = tally.dateship.date;
            dict[@"identity"] = tally.identity;
            dict[@"typename"] = tally.typeship.typename;
            dict[@"income"] = [NSNumber numberWithDouble:tally.income];
            dict[@"expenses"] = [NSNumber numberWithDouble:tally.expenses];
            dict[@"timestamp"] = [NSNumber numberWithDouble:tally.timestamp];
            [resultArray addObject:dict];
            
        }
        
        
    }
    NSArray *array = [[NSArray alloc] initWithArray:resultArray];
    return array;
}


//加载账单类型到数据库
- (void)loadTallyTypeToSqlite {
    //读取plist数据
    NSMutableArray *res = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TallyList" ofType:@"plist"];
    NSArray *list = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dict in list) {
        TallyListCellModel *model = [TallyListCellModel tallyListCellModelWithDict:dict];
        [res addObject:model];
    }
    
    //将类型名字和图片信息写入数据库
    for (TallyListCellModel *model in res) {
        //查询有无对应的type 有则使用无则创建
        TallyType *ssr = [self getTallyTypeWithTypeName:model.tallyCellName];
        if (ssr == nil) {
            TallyType *type = [[TallyType alloc] initWithContext:self.managedObjectContext];
            type.typename = model.tallyCellName;
            type.typeicon = model.tallyCellImage;
            [self saveTally];
        }
        
    }
}

//标识为identity数据上传成功
- (void)uploadServerSucceedWithIdentity:(NSString*)identity{
    NSFetchRequest *fetchRequest = [Tally fetchRequest];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identity = %@",identity];
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Tally *tally in fetchedObjects) {
        tally.flag = 1;
        [self saveTally];
    }
}

@end
