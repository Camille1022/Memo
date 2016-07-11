//
//  audioView.h
//  LMY_note
//
//  Created by sq-ios81 on 16/4/22.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface audioView : UIView

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) int t;

@property (nonatomic, strong) UILabel *audioTime;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL isMakeAudio;
@property (nonatomic, strong) UIButton *makeBtn;

// 音频录音机
@property (nonatomic, strong) AVAudioRecorder *audio;
@property (nonatomic, strong) UIButton *completeBtn;

@end
