//
//  YSCalendarViewController.m
//  YSRun
//
//  Created by moshuqi on 15/10/15.
//  Copyright © 2015年 msq. All rights reserved.
//

#import "YSCalendarViewController.h"
#import "YSCalendarRecordView.h"
#import "YSAppMacro.h"
#import "YSContentTable.h"
#import "YSHeartRateRecordViewController.h"
#import "YSRunDataRecordViewController.h"
#import "YSDatabaseManager.h"
#import "YSRunDatabaseModel.h"
#import "YSModelReformer.h"
#import "NSDate+YSDateLogic.h"
#import "YSDataRecordModel.h"
#import "YSDevice.h"

#import "HttpTool.h"

#import "YSSportRecordViewController.h"

@interface YSCalendarViewController () <YSContentTableDelegate, YSCalendarRecordViewDelegate>

@property (nonatomic, weak) IBOutlet YSCalendarRecordView *calendarView;
@property (nonatomic, weak) IBOutlet YSContentTable *contentTable;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *calendarHeightConstraint;

@end

@implementation YSCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSDate *currentDate = [self getCurrentDate];
//    [self.calendarView resetCalendarWithDate:currentDate];
    
    // 初始化时设置一下，否则即使选中有跑步数据的日期也不会显示对应数据。 2015-12-23
//    [self resetContentTableWithDate:currentDate];
    
    self.calendarView.delegate = self;
    self.contentTable.delegate = self;
    
    self.view.backgroundColor = LightgrayBackgroundColor;
    
    if ([YSDevice isPhone6Plus])
    {
        self.calendarHeightConstraint.constant = 380;
    }
    
   
    
}

- (NSString *)dateStringFormatterForDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
 
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
  
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    
    return currentDateString;
}

- (void)runList:(NSDate *)date{
    if(KUserId == nil || [KUserId isEqualToString:@" "]){
        NSMutableArray *dataArray = [NSMutableArray array];//没有数据刷新空数组
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.contentTable resetTableWithRecordDataArray:dataArray];
        });
        
        return;
    }
    NSDictionary *parm = @ {
        @"uid" : KUserId,
        @"PageIndex" : @1,
        @"PageSize" : @12,
        @"RunDate" : [self dateStringFormatterForDate:date]
    };
    NSLog(@"parm = %@",parm);
    NSString *url = @"http://lu.api.ymstudio.xyz/api/running/list";
    [HttpTool post:@"POST" url:url bodyParams:parm params:nil success:^(id responseObj) {
        NSLog(@"responseObj = %@",responseObj);
        if ([responseObj[@"status_code"] integerValue] == 200) {
            NSArray *runDataArray = responseObj[@"data"];
            NSMutableArray *dataArray = [NSMutableArray array];
            for (NSInteger i = 0; i < [runDataArray count]; i ++)
            {
                NSDictionary *runDic = runDataArray[i];
                YSDataRecordModel *dataRecordModel = [YSModelReformer dataRecordModelFromRunDatabaseDic:runDic];
                
                [dataArray addObject:dataRecordModel];
            }
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.contentTable resetTableWithRecordDataArray:dataArray];
            });
        }else{
            NSMutableArray *dataArray = [NSMutableArray array];//没有数据刷新空数组
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.contentTable resetTableWithRecordDataArray:dataArray];
            });
        }
        
        //数据
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error);
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //请求跑步的数据
    [self runList:[NSDate date]];
    // 进入时拿当前时间作为数据设置
//    [self.calendarView resetCalendarWithDate:[NSDate date]];
//    [self resetContentTableWithDate:[NSDate date]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.calendarView resetCalendarFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDate *)getCurrentDate
{
    NSDate *date = [NSDate date];
    return date;
    
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate:date];
//    
//    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
//    return localeDate;
}

//跑完一次数据更新
- (void)resetCalendar
{
    // 用户登录或者退出时，日历界面的跑步数据刷新。
    NSDate *currentDate = [self getCurrentDate];
    [self.calendarView resetCalendarWithDate:currentDate];
//    [self resetContentTableWithDate:currentDate];
    [self runList:currentDate];
}

- (void)resetContentTableWithDate:(NSDate *)date
{
    // 根据日期date来显示对应日期的跑步数据
    
    // 数据库操作换成队列执行之后，这些操作可以放到子线程里执行。    2015.12.31
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
//        double startTime = CFAbsoluteTimeGetCurrent();
        
        YSDatabaseManager *databaseManager = [YSDatabaseManager new];
        NSArray *runDataArray = [databaseManager getRunDataArrayWithDate:date];  // YSRunDatabaseModel数组
        
        NSMutableArray *dataArray = [NSMutableArray array];
        for (NSInteger i = 0; i < [runDataArray count]; i ++)
        {
            YSRunDatabaseModel *runDataBaseModel = runDataArray[i];
            YSDataRecordModel *dataRecordModel = [YSModelReformer dataRecordModelFromRunDatabaseModel:runDataBaseModel];
            
            [dataArray addObject:dataRecordModel];
        }
        
//        double endTime = CFAbsoluteTimeGetCurrent();
//        double useTime = endTime - startTime;
//        NSLog(@"操作耗时：%f", useTime);
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.contentTable resetTableWithRecordDataArray:dataArray];
        });
    });
    
//    YSDatabaseManager *databaseManager = [YSDatabaseManager new];
//    NSArray *runDataArray = [databaseManager getRunDataArrayWithDate:date];  // YSRunDatabaseModel数组
//    
//    NSMutableArray *dataArray = [NSMutableArray array];
//    for (NSInteger i = 0; i < [runDataArray count]; i ++)
//    {
//        YSRunDatabaseModel *runDataBaseModel = runDataArray[i];
//        YSDataRecordModel *dataRecordModel = [YSModelReformer dataRecordModelFromRunDatabaseModel:runDataBaseModel];
//        
//        [dataArray addObject:dataRecordModel];
//    }
//    [self.contentTable resetTableWithRecordDataArray:dataArray];
}

#pragma mark - YSContentTableDelegate

- (void)showHeartRateRecordWithDataModel:(YSDataRecordModel *)dataModel
{
    UIViewController *recordViewController = nil;
    if ([dataModel.heartRateArray count] > 0)
    {
        recordViewController = [[YSHeartRateRecordViewController alloc] initWithDataRecordModel:dataModel];
    }
    else
    {
        recordViewController = [[YSRunDataRecordViewController alloc] initWithDataRecordModel:dataModel];
    }
    
    recordViewController = [[YSSportRecordViewController alloc] initWithDataRecordModel:dataModel];
    
    [self presentViewController:recordViewController animated:YES completion:nil];
}

#pragma mark - YSCalendarRecordViewDelegate

- (void)calendarRecordDidSelectedDate:(NSDate *)date
{
    [self runList:date];
//    [self resetContentTableWithDate:date];
}

@end
