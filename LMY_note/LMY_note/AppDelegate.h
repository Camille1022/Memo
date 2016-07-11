//
//  AppDelegate.h
//  LMY_note
//
//  Created by sq-ios81 on 16/4/13.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSlideViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) DeckViewController *leftSlider;

@property (nonatomic, strong) NSMutableArray *remindArr;

-(void)getNewRemindArr;

-(DeckViewController *)sharedLeftSlider;

@end

