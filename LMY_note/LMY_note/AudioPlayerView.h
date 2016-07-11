//
//  AudioPlayerView.h
//  LMY_note
//
//  Created by sq-ios81 on 16/5/3.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioPlayerView : UIView

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, strong) UILabel *discributionL;
@property (nonatomic, strong) UILabel *timeL;
@property (nonatomic, strong) UILabel *totalTimeL;

@property (nonatomic, strong) UIProgressView *progress;

@end
