//
//  WXRViewController.m
//  提醒事件
//
//  Created by 王晓睿 on 15/7/23.
//  Copyright (c) 2015年 王晓睿. All rights reserved.
//

#import "WXRViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"

@interface WXRViewController ()
@property(nonatomic,weak)UIDatePicker *datePicker;//日期选择
@property(nonatomic,strong) NSDate *myDate;
@end

@implementation WXRViewController
-(UITextField *)textField
{
    if (_textField == nil) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(100,100, 200, 40)];
        _textField.backgroundColor = [UIColor whiteColor];
    }
    return _textField;
}
-(UITextField *)timeField
{
    if (_timeField == nil) {
        _timeField = [[UITextField alloc]initWithFrame:CGRectMake(100,160, 200, 40)];
        _timeField.backgroundColor = [UIColor whiteColor];
    }
    return _timeField;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:self.textField];
    [self.view addSubview:self.timeField];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 80, 40)];
    label1.text = @"添加事件";
    [self.view addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, 160, 80, 40)];
    label2.text = @"设定时间";
    [self.view addSubview:label2];
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    self.datePicker = datePicker;
    self.timeField.inputView = self.datePicker;
    
    //代码创建UIToolbar
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.bounds = CGRectMake(0, 0, 320, 44);
    toolbar.backgroundColor = [UIColor grayColor];
    
    //创建上一个按钮
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    
    
    //弹簧
    UIBarButtonItem *tanhuangBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //创建完成按钮
    UIBarButtonItem *finish = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishSelectedDate)];
    
    

    toolbar.items = @[cancel,tanhuangBtn,finish];
    
    //设置inputAccessoryView在，就能在键盘上面添加辅助的view
    self.timeField.inputAccessoryView = toolbar;

    // 确定按钮
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100) / 2, 240, 100, 40)];
    [btn setBackgroundColor:[UIColor blueColor]];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(okBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}
-(void)cancel
{
    [self.timeField resignFirstResponder];
}
-(void)finishSelectedDate
{
    NSDate *date = self.datePicker.date;
    self.myDate = self.datePicker.date;
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    //设置日期格式
    formater.dateFormat = @"yyyy-MM-dd-aa-hh-mm";
    self.timeField.text = [formater stringFromDate:date];
    
    //隐藏键盘
    [self.timeField resignFirstResponder];

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textField resignFirstResponder];
    [self.timeField resignFirstResponder];
}
-(void)okBtn
{

    //chuagjian一个本地推送
    
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    
    if (noti) {
        
        //设置推送时间
        
        noti.fireDate = self.myDate;
        
        //设置时区
        
        noti.timeZone = [NSTimeZone defaultTimeZone];
        
        
        //推送声音
        
        noti.soundName = UILocalNotificationDefaultSoundName;
        
        //内容
        
        noti.alertBody = self.textField.text;
        
        //显示在icon上的红色圈中的数子
        
        noti.applicationIconBadgeNumber = 1;
        
        //设置userinfo 方便在之后需要撤销的时候使用
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
        
        noti.userInfo = infoDic;
        
        //添加推送到uiapplication
        
        UIApplication *app = [UIApplication sharedApplication];
        
        [app scheduleLocalNotification:noti];
        
        // 1.获得网络监控的管理者
        AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
        
        // 2.设置网络状态改变后的处理
        [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            // 当网络状态改变了, 就会调用这个block
            switch (status) {
                case AFNetworkReachabilityStatusUnknown: // 未知网络
//                    NSLog(@"未知网络");
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
//                    NSLog(@"没有网络(断网)");
                    [MBProgressHUD showError:@"没有网络，已将数据存入"];
                    
                    [self.textField.text writeToFile:@"message" atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [NSKeyedArchiver archiveRootObject:self.myDate toFile:@"mydate"];
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
//                    NSLog(@"手机自带网络");
                     [MBProgressHUD showSuccess:@"手机自带网络"];
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                 {
//                     NSLog(@"WIFI");
                    
                    NSString *myText = [NSString stringWithContentsOfFile:@"message" encoding:NSUTF8StringEncoding error:nil];
                    NSDate *myDate = [NSKeyedUnarchiver unarchiveObjectWithFile:@"mydate"];
                    // 再用post方法向服务器发送消息
                    
                    [MBProgressHUD showSuccess:@"wifi环境 消息已发送" toView:self.view.window];
            }
                    break;
            }
        }];
        
        // 3.开始监控
        [mgr startMonitoring];

        
    }

}
@end
