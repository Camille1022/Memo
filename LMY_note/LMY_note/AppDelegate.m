//
//  AppDelegate.m
//  LMY_note
//
//  Created by sq-ios81 on 16/4/13.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstIn"]) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstIn"];
        
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *str = [documents stringByAppendingPathComponent:@"note.plist"];
        NSString *testStr = @"Private Password : 0000";
        NSString *dateStr = @"2016-5-10 00:00:00";
        NSString *imagStr = @"lmy";
        NSString *remindStr = @"0";
        NSDate *dateRemind = [NSDate date];
        NSString *repeatStr = @"0 never";
        NSDictionary *dict = [NSDictionary dictionary];
        NSArray *arr = [NSArray array];
        arr = @[testStr,dateStr,imagStr,remindStr,dateRemind,repeatStr,dict];
        NSMutableArray *noteArr = [NSMutableArray array];
        [noteArr addObject:arr];
        [noteArr writeToFile:str atomically:YES];
    }
    
    
    // 关闭红外感应
    [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    
    // preference 偏好设置 -- 初始密码
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"passwd"]==nil) {
        [[NSUserDefaults standardUserDefaults]setObject:@"0000" forKey:@"passwd"];
    }
    
    // 设置侧滑控制器
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    // 设置侧滑控制器的左控制器和主控制器（主视图和左滑视图）
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainVC = [storyboard instantiateViewControllerWithIdentifier:@"navigation"];
    UIViewController *leftVC = [storyboard instantiateViewControllerWithIdentifier:@"setting"];
    self.leftSlider = [[DeckViewController alloc]initWithLeftView:leftVC andMainView:mainVC];
    
    // 设置主窗口的根视图为侧滑控制器
    self.window.rootViewController = self.leftSlider;
    
    // 获取提醒事件
    [self getNewRemindArr];
    
    return YES;
}

-(DeckViewController *)sharedLeftSlider {
    return self.leftSlider;
}

#pragma mark - 获取提醒事件存入数组
-(void)getNewRemindArr {
    self.remindArr = nil;
    self.remindArr = [NSMutableArray array];
    
    // 从 plist 中得到已有的数组
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str1 = [documents stringByAppendingString:@"/note.plist"];
    NSString *str2 = [documents stringByAppendingString:@"/private.plist"];
    NSMutableArray *arr1= [NSMutableArray arrayWithContentsOfFile:str1];
    NSMutableArray *arr2= [NSMutableArray arrayWithContentsOfFile:str2];
    
    // 过期的日期删除
    arr1 = [self getRemind:arr1 filePath:str1];
    arr2 = [self getRemind:arr2 filePath:str2];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:arr1];
    [arr addObjectsFromArray:arr2];
    
    for (NSArray *arrIn in arr)
        if ([arrIn[3] isEqualToString:@"1"]) {
            NSArray *arr = @[arrIn[4],arrIn[0]];
            [self.remindArr addObject:arr];
        }
    
    // 按提醒时间排序
    [self sortByTime];
    
//    NSLog(@"arr : %@",self.remindArr);
    
    [[NSUserDefaults standardUserDefaults]setObject:self.remindArr forKey:@"notif"];
    
    // 本地通知
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
        // 创建本地通知
        [self addLocalNotification];
    } else {
        // 发送请求授权
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:
                             UIUserNotificationTypeAlert|
                             UIUserNotificationTypeBadge|
                             UIUserNotificationTypeSound categories:nil]];
    }
}

#pragma mark - 将提醒按时间顺序排序
-(void)sortByTime {
    for (int i = 1; i < self.remindArr.count; ++i)
        for (int j = 0; j < self.remindArr.count-1; ++j) {
            NSArray *arr1 = self.remindArr[j];
            NSArray *arr2 = self.remindArr[j+1];
            if ([arr1[0] compare:arr2[0]] == NSOrderedDescending) {
                NSArray *tmpArr = self.remindArr[j];
                self.remindArr[j] = self.remindArr[j+1];
                self.remindArr[j+1] = tmpArr;
            }
        }
}

// 将已经过期的提醒清除
-(NSMutableArray *)getRemind:(NSMutableArray *)arrRemind filePath:(NSString *)str {
    for (int i = 0; i < arrRemind.count; ++i) {
        NSArray *arr = arrRemind[i];
        NSString *repeatStr = arr[5];
        NSString *isRepeat = [repeatStr substringToIndex:1];
        NSDate *now = [NSDate date];
        NSDate *remindDate = arr[4];
        if ([now compare:remindDate] == NSOrderedDescending &&
            [isRepeat isEqualToString:@"0"]){
            arrRemind[i][3] = @"0";
        } else if ([now compare:remindDate] == NSOrderedDescending && [isRepeat isEqualToString:@"1"]){
            NSString *repeatTime = [repeatStr substringFromIndex:2];
            NSArray *arr = [repeatTime componentsSeparatedByString:@" "];
            NSString *repeatName = arr[0];
            NSString *repeatNum = arr[1];
            if ([repeatName isEqualToString:@"minute"]) {
                arrRemind[i][4] = [[NSDate alloc]initWithTimeInterval:[repeatNum intValue]*60 sinceDate:remindDate];
            } else if ([repeatName isEqualToString:@"hour"]) {
                arrRemind[i][4] = [[NSDate alloc]initWithTimeInterval:[repeatNum intValue]*60*60 sinceDate:remindDate];
            } else {
                arrRemind[i][4] = [[NSDate alloc]initWithTimeInterval:[repeatNum intValue]*60*60*24 sinceDate:remindDate];
            }
            arrRemind[i][5] = @"0 never";
        }
    }
    [arrRemind writeToFile:str atomically:YES];
    
    return arrRemind;
}

#pragma makr - 私有方法 添加本地通知
- (void)addLocalNotification {
    // 2.设置通知对象属性
    for (int i = 0; i < self.remindArr.count; ++i) {
        // 1.创建本地通知对象
        UILocalNotification *notification =[[UILocalNotification alloc] init];
        NSArray *arr = self.remindArr[i];
        // 通知时间
        notification.fireDate = arr[0];
        // 通知内容（主体）
        notification.alertBody = arr[1];
        // 应用图标右上角显示的消息数
        notification.applicationIconBadgeNumber = 1;
        // 待机界面的滑动动作提醒
        notification.alertAction = @"open app";
        // 通过点击通知打开应用时的启动图片，这里使用程序启动图片
        notification.alertLaunchImage = @"Default";
        // 收到通知时播放的声音，默认消息声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 通知声音（需要真机才能听到）
//        notification.soundName = @"msg.caf";
        
        // 调用通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    /*

     // 设置通知出发时间为10秒后
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    // 通知重复次数
    notification.repeatInterval = 2;
    // 设置日历为当前日历，使用前最好设置时区等信息，以便能够自动同步时间
    notification.repeatCalendar = [NSCalendar currentCalendar];
    
    // 通知主体
    notification.alertBody = @"这是一个通知";
    // 应用图标右上角显示的消息数
    notification.applicationIconBadgeNumber = 1;
    // 待机界面的滑动动作提醒
    notification.alertAction = @"open app";
    // 通过点击通知打开应用时的启动图片，这里使用程序启动图片
    notification.alertLaunchImage = @"Default";
    // 收到通知时播放的声音，默认消息声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知声音（需要真机才能听到）
    notification.soundName = @"msg.caf";
    // 设置用户信息
    notification.userInfo = @{@"id":@30, @"user":@"lmy"};
    
    // 调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
     
     */
}
// 移除本地通知
- (void)removeLocalNotification {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSNotification *notif = [NSNotification notificationWithName:@"viewAppear" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notif];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
