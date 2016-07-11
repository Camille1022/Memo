//
//  AudioPlayerView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/3.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "AudioPlayerView.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation AudioPlayerView

#pragma mark - 懒加载
-(UIButton *)playBtn {
    if (_playBtn == nil)
        _playBtn = [[UIButton alloc]init];
    return _playBtn;
}
-(UIButton *)stopBtn {
    if (_stopBtn == nil)
        _stopBtn = [[UIButton alloc]init];
    return _stopBtn;
}
-(UIButton *)deleteBtn {
    if (_deleteBtn == nil)
        _deleteBtn = [[UIButton alloc]init];
    return _deleteBtn;
}
-(UILabel *)discributionL {
    if (_discributionL == nil)
        _discributionL = [[UILabel alloc]init];
    return _discributionL;
}
-(UILabel *)timeL {
    if (_timeL == nil)
        _timeL = [[UILabel alloc]init];
    return _timeL;
}
-(UILabel *)totalTimeL {
    if (_totalTimeL == nil)
        _totalTimeL = [[UILabel alloc]init];
    return _totalTimeL;
}
-(UIProgressView *)progress {
    if (_progress == nil)
        _progress = [[UIProgressView alloc]init];
    return _progress;
}

#pragma mark - 初始化，界面布局
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat audioH = HEIGHT/9.0;
        self.backgroundColor = [UIColor lightGrayColor];
        self.frame = CGRectMake(0, 64, WIDTH, audioH);
        
        // play Button
        CGFloat playBtnW = audioH*5/8;
        self.playBtn.frame = CGRectMake(0, 0, playBtnW, playBtnW);
        self.playBtn.center = CGPointMake(WIDTH/9, audioH/2);
        [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self addSubview:self.playBtn];
        
        // stop Button
        CGFloat stopBtnW = audioH*3/8;
        self.stopBtn.frame = CGRectMake(WIDTH/5, audioH/2-10, stopBtnW, stopBtnW);
        [self.stopBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self addSubview:self.stopBtn];
        
        // changed time Label
        CGFloat timeY = CGRectGetMaxY(self.stopBtn.frame) - 8;
        CGFloat timeX = CGRectGetMaxX(self.stopBtn.frame) + 8;
        self.timeL.frame = CGRectMake(timeX, timeY, 60, 20);
        self.timeL.text = @"00:00";
        [self addSubview:self.timeL];
        
        // totaltime Label
        self.totalTimeL.frame = CGRectMake(WIDTH*6/7 - 8, timeY, 60, 20);
        [self addSubview:self.totalTimeL];
        
        // progress
        CGFloat progressX = CGRectGetMaxX(self.timeL.frame);
        CGFloat progressXM = CGRectGetMinX(self.totalTimeL.frame) - 5;
        CGFloat progressW = progressXM - progressX;
        self.progress.frame = CGRectMake(progressX - 5, timeY + 10, progressW, 3);
        [self addSubview:self.progress];
        
        // delete Button
        CGFloat deleteBtnY = CGRectGetMinY(self.playBtn.frame) - 3;
        CGFloat deleteBtnW = audioH*2/5;
        self.deleteBtn.frame = CGRectMake(WIDTH*7/8, deleteBtnY, deleteBtnW, deleteBtnW);
        [self.deleteBtn setBackgroundImage:[UIImage imageNamed:@"del"] forState:UIControlStateNormal];
        [self addSubview:self.deleteBtn];
        
        // discribution Label
        CGFloat disW = WIDTH*7/8 - timeX - 8;
        CGFloat disH = timeY - deleteBtnY - 5;
        self.discributionL.frame = CGRectMake(timeX, deleteBtnY, disW, disH);
        [self addSubview:self.discributionL];
    }
    return self;
}

@end
