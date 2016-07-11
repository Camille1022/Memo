//
//  audioView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/4/22.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "audioView.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define IMAGE_COUNT 15
@interface audioView()
{
    CALayer *_layer;
    int _index;
    NSMutableArray *_images;
}
@property(nonatomic,strong)CADisplayLink *displayLink;

@end

@implementation audioView

#pragma mark - 录音 与 播放相关
-(AVAudioRecorder *)audio {
    if (_audio == nil) {
        // 获得录音保存路径
        NSURL *url = [self getAudioURL];
        // 获得录音相关配置
        NSDictionary *setting = [self getAudioSetting];
        
        // 创建录音音频对象
        _audio = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:nil];
        
        [_audio prepareToRecord];
    }
    return _audio;
}
// 获得录音保存路径
-(NSURL *)getAudioURL {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.fileName = [[self getCurrentDate] stringByAppendingString:@".caf"];
    
    [[NSUserDefaults standardUserDefaults]setValue:self.fileName forKey:@"audioPath"];
    
    NSString *filePath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",self.fileName]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    return url;
}
// 获得录音相关配置
-(NSDictionary *)getAudioSetting {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    // 设置录音格式
    [dict setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    // 设置录音采样率
    [dict setObject:@(8000) forKey:AVSampleRateKey];
    // 设置通道，这里采用单声道
    [dict setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 每个采样点位数,分别为8,16,24,32
    [dict setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    // 是否使用浮点数采样
    [dict setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    return dict;
}

#pragma mark - 设置为播放和录音状态
-(void)setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 设置为播放和录音状态，以便可以在录音完成后播放录音
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
}

// 获得当前日期
-(NSString *)getCurrentDate {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY_MM_dd HH:mm:ss";
    NSString *nowStr = [dateFormatter stringFromDate:now];
    return nowStr;
}


#pragma mark - 布局各子控件
-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat audioW = WIDTH*3/4;
        
        self.frame = CGRectMake((WIDTH-audioW)/2, -100-audioW, audioW, audioW);
        self.layer.cornerRadius = audioW/10;
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        // 设置标题
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, audioW/30, audioW, audioW/10)];
        title.text = @"make audio";
        title.font = [UIFont systemFontOfSize:25];
        title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:title];
        
        // 设置分割线
        [self setLine:CGRectGetMaxY(title.frame) + 8];
        
        // 设置录音时长 label
        CGFloat timeF = CGRectGetMaxY(title.frame) + 20;
        self.audioTime = [[UILabel alloc]initWithFrame:CGRectMake(audioW/10, timeF, audioW/3, audioW/20)];
        self.audioTime.text = @"00:00";
        [self addSubview:self.audioTime];
        
        // 设置开始录制时的动画显示
        UIImageView *img = [[UIImageView alloc]initWithFrame: CGRectMake(audioW/6, audioW/3, audioW*2/3, audioW*4/30)];
        img.image = [UIImage imageNamed:@"15"];
        [self addSubview:img];
        
        // 设置 开始/暂停 button
        CGFloat playBtnY = audioW/2 + 16;
        self.makeBtn = [[UIButton alloc]initWithFrame:CGRectMake(audioW*5/12, playBtnY, audioW/6, audioW/6)];
        [self.makeBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.makeBtn addTarget:self action:@selector(makeAudio) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.makeBtn];
        
        // 设置 停止 button
        UIButton *stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.makeBtn.frame.origin.x + audioW/5, self.makeBtn.frame.origin.y+10, audioW/10, audioW/10)];
        [stopBtn setBackgroundImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [stopBtn addTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:stopBtn];
        
        // 设置分割线
        [self setLine:CGRectGetMaxY(self.makeBtn.frame) + 8];
        
        // 设置底部 button
        CGFloat btnW = audioW / 3 + 10;
        CGFloat btnH = audioW / 6;
        CGFloat btnY = CGRectGetMaxY(self.makeBtn.frame) + WIDTH/20;
        CGFloat fixW = (audioW - 2*btnW)/3;
        
        UIButton *cancelBtn = [[UIButton alloc]initWithFrame:CGRectMake(fixW, btnY, btnW, btnH)];
        [cancelBtn setTitle:@"cancel" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        cancelBtn.showsTouchWhenHighlighted = YES;
        cancelBtn.layer.cornerRadius = btnW/10;
        cancelBtn.backgroundColor = [UIColor lightGrayColor];
        [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
        self.completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(btnW + 2*fixW, btnY, btnW, btnH)];
        [self.completeBtn setTitle:@"complete" forState:UIControlStateNormal];
        self.completeBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        self.completeBtn.showsTouchWhenHighlighted = YES;
        self.completeBtn.layer.cornerRadius = btnW/10;
        self.completeBtn.backgroundColor = [UIColor lightGrayColor];
        [self.completeBtn addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.completeBtn];
        // 未录音状态下不可点击
        [self.completeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.completeBtn.enabled = NO;
    }
    return self;
}
// 设置分割线
-(void)setLine:(CGFloat)y {
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, y, WIDTH*3/4, 2)];
    line.backgroundColor = [UIColor whiteColor];
    [self addSubview:line];
}

#pragma mark - 逐帧动画的设置
-(void)setImageAnimation {
    // 1.创建图像显示图层
    _layer = [[CALayer alloc]init];
    CGFloat audioW = WIDTH*3/4;
    _layer.frame = CGRectMake(audioW/6, audioW/3, audioW*2/3, audioW*4/30);
    [self.layer addSublayer:_layer];
    
    // 2.存放16帧图片
    _images = [NSMutableArray array];
    for (int i = 1; i < 16; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d",i];
        UIImage *image = [UIImage imageNamed:imageName];
        [_images addObject:image];
    }
}
-(void)step {
    // 定义一个变量纪录执行次数
    static int s = 0;
    if (++s%20 == 0) {
        UIImage *image = _images[_index];
        _layer.contents = (id)image.CGImage; // 更新图片
        _index = (_index + 1)%IMAGE_COUNT;
    }
}

#pragma mark - play/pause/stop method
-(void)makeAudio {
    // 设置 录制的状态
    [[NSUserDefaults standardUserDefaults]setValue:@"1" forKey:@"statePlay"];
    
    self.isMakeAudio = !self.isMakeAudio;
    NSString *imgName = self.isMakeAudio?@"pause":@"play";
    
    [self.makeBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [self.makeBtn addTarget:self action:@selector(makeAudio) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isMakeAudio) {
        self.displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(step)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        [self setImageAnimation];
        // 4.添加时钟对象到主运行循环
        
        [self setAudioSession];
        
        [self.audio record];
        [self.completeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.completeBtn.enabled = YES;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startAudio) userInfo:nil repeats:YES];
    } else {
        [self.displayLink invalidate];
        [self.audio pause];
        [self.timer invalidate];
        
        CGFloat audioW = WIDTH*3/4;
        UIImageView *img = [[UIImageView alloc]initWithFrame: CGRectMake(audioW/6, audioW/3, audioW*2/3, audioW*4/30)];
        img.image = [UIImage imageNamed:@"15"];
        [self addSubview:img];
    }
    
}
-(void)startAudio {
    self.t++;
    self.audioTime.text = [NSString stringWithFormat:@"%02d:%02d",self.t/60,self.t%60];
}
-(void)stopAudio {
    [[NSUserDefaults standardUserDefaults]setValue:@"1" forKey:@"stateStop"];
    
    [self.completeBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.completeBtn.enabled = NO;
    
    [self.audio stop];          // 停止录音
    [self.timer invalidate];    // 关闭定时器
    [self deleteAudio];         // 删除原文件
    
    // 时间计数清零
    self.t = 0;
    self.audioTime.text = @"00:00";
    
    // 录制／暂停 状态改变
    self.isMakeAudio = YES;
    [self makeAudio];
}

#pragma mark - cancel/complete method
-(void)cancel {
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat audioW = WIDTH*3/4;
        self.frame = CGRectMake((WIDTH-audioW)/2, -100-audioW, audioW, audioW);
    } completion:^(BOOL finished) {
        [self stopAudio];
    }];
}
-(void)complete {
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat audioW = WIDTH*3/4;
        self.frame = CGRectMake((WIDTH-audioW)/2, HEIGHT+100, audioW, audioW);
    } completion:^(BOOL finished) {
        
        NSDictionary *dict = @{
                               @"state": @1,
                               @"path" : self.fileName,
                               @"time" : @(self.t),
                               @"name" :@"nil"
                               };

        NSNotification *noti = [NSNotification notificationWithName:@"audio" object:nil userInfo:dict];
        [[NSNotificationCenter defaultCenter]postNotification:noti];
        
        [self.audio stop];
        [self.timer invalidate];
    }];
}

#pragma mark - 删除录音文件
-(void)deleteAudio {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documents stringByAppendingPathComponent:self.fileName];
    // 文件管理器 是专门用于文件管理的类
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 删除文件
    [fileManager removeItemAtPath:filePath error:nil];
}

@end
