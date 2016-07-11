//
//  addViewController.m
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/7.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import "addViewController.h"
#import "remindTableViewController.h"
#import "audioView.h"
#import "AudioPlayerView.h"
#import "DrawBoardVC.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface addViewController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    int c;  // 定时器计时
    
    // 音频相关状态
    int stateCom1;
    int stateCom2;
}
@property (nonatomic, strong) NSMutableArray *noteArr;

@property (nonatomic, strong) NSArray *arr;
@property (nonatomic, copy) NSString *textStr;
@property (nonatomic, copy) NSString *dateStr;
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, assign) BOOL isRemind;
@property (nonatomic, strong) NSDate *dateRemind;
@property (nonatomic, copy) NSString *repeatStr;
@property (nonatomic, strong) NSMutableDictionary *audioDict;

// image 相关
@property (nonatomic, assign, getter=isExit) BOOL exit;
@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) UIImage *imgInsert;

// audio 相关
@property (nonatomic, strong) audioView *audioView;
@property (nonatomic, strong) AudioPlayerView *reportView;
@property (nonatomic, assign) BOOL isAudio;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation addViewController

#pragma mark - 懒加载 进行初始化
-(UIImagePickerController *)imgPicker {
    if (_imgPicker == nil)
        _imgPicker = [[UIImagePickerController alloc]init];
    return _imgPicker;
}
-(UIView *)audioView {
    if (_audioView == nil)
        _audioView = [[audioView alloc]init];
    return _audioView;
}
-(NSMutableDictionary *)audioDict {
    if (_audioDict == nil) {
        _audioDict = [NSMutableDictionary dictionary];
        _audioDict[@"state"] = @0;
        _audioDict[@"path"]  = @"nil";
        _audioDict[@"time"]  = @0;
        _audioDict[@"name"]  = @"nil";
    }
    return _audioDict;
}

#pragma mark - view operation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.noteArr = [[NSMutableArray alloc]init];
    self.arr = [NSArray new];
    self.imgData = [NSData new];
    self.dateRemind = [NSDate new];
    self.repeatStr = @"0 never";
    
    // 收到通知后
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAudio:) name:@"audio" object:nil];
    
    // 添加 录音view 到主界面
    [self.view addSubview:self.audioView];
    
    UIColor *lightYellow = [UIColor colorWithRed:247/255.0 green:251/255.0 blue:227/255.0 alpha:1];
    self.navigationController.view.backgroundColor = lightYellow;
    
    // 导航栏 设置
    UIBarButtonItem *completeBtn=[[UIBarButtonItem alloc] initWithTitle:@"complete" style:UIBarButtonItemStylePlain target:self action:@selector(CompleteClick)];
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem=completeBtn;
    
    // 传给 remind 值
    [[NSUserDefaults standardUserDefaults]setValue:@"0" forKey:@"remind"];
    [[NSUserDefaults standardUserDefaults]setValue:@"0 never" forKey:@"repeat"];
    
    // 手势识别器 --- 轻扫
    UISwipeGestureRecognizer *mySwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doSwipe:)];
    mySwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:mySwipe];
}

// 处理 轻扫手势 的回调函数 －－－－ 下滑 关闭键盘
-(void)doSwipe:(UISwipeGestureRecognizer *)swipe {
    [self.view endEditing:YES];
}

// 获得当前日期及时间
- (NSString *)getTodayDate {
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY_MM_dd HH:mm:ss";
    NSString *nowStr = [dateFormatter stringFromDate:now];
    return nowStr;
}

// 页面消失时调用
-(void)viewWillDisappear:(BOOL)animated {
    [self stopAudio];
    NSString *state1 = [[NSUserDefaults standardUserDefaults]valueForKey:@"statePlay"];
    NSString *state2 = [[NSUserDefaults standardUserDefaults]valueForKey:@"stateStop"];
    NSString *fileName = [[NSUserDefaults standardUserDefaults]valueForKey:@"audioPath"];
    // 删除音频
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    if (stateCom1 == 1 && stateCom2 == 0) {
        NSString *filePath = [documents stringByAppendingPathComponent:[self.audioDict valueForKey:@"path"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
    if ([state1 intValue] == 1 && [state2 intValue] == 0 &&
        (stateCom1 == 0 || stateCom2 == 0)) {
        NSString *filePath = [documents stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(insertDrawImage:) name:@"drawImage" object:nil];
}

-(void)insertDrawImage:(NSNotification *)notif {
    self.imgInsert = [[notif userInfo]valueForKey:@"image"];
    [self insertImage:self.imgInsert];
}

#pragma mark - textView delegate - 文本内容有改动
-(void)textViewDidChange:(UITextView *)textView {
    self.noteText.font = [UIFont fontWithName:@"Arial" size:18.0];
    
    NSMutableArray *arrM=[NSMutableArray array];
    NSDictionary *attributeDict;
    NSRange effectiveRange = { 0, 0 };
    if (textView.attributedText.length==0)
        return;
    
    do {
        NSRange range;
        range = NSMakeRange (NSMaxRange(effectiveRange),[textView.attributedText length] - NSMaxRange(effectiveRange));
        //        NSLog(@"range : %@",NSStringFromRange(range));
        //        NSLog(@" location : %lu",range.location);
        //        NSLog(@"ecrange : %@",NSStringFromRange(effectiveRange));
        attributeDict = [textView.attributedText attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
        //        NSLog (@"Range: %@  Attributes: %@",NSStringFromRange(effectiveRange), attributeDict);
        [arrM addObject:attributeDict];
        
    } while (NSMaxRange(effectiveRange)<[textView.attributedText length]);
    
    //    NSLog(@"count : %lu",(unsigned long)arrM.count);
    if (arrM.count == 1)
        self.exit = NO;
    
    //    NSLog(@" exit : %d",self.exit);
    //    NSLog(@"string : %@",textView.attributedText);
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    self.textToBotton.constant += 240;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    self.textToBotton.constant -= 240;
}

#pragma mark - 点击 complete 按钮，内容保存入沙盒，plist
-(void)CompleteClick {
    stateCom2 = 1;
    [[NSUserDefaults standardUserDefaults]setValue:@"1"forKey:@"count"];
    
    if(self.noteText.text.length > 0){
        // 写入 plist
        [self fileHandleOperate];
        
        NSString *remindStr = [NSString stringWithFormat:@"%d",_isRemind];
        
        if (self.textStr!=nil && self.dateStr!=nil) {
            NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *str = [documents stringByAppendingPathComponent:@"note.plist"];
            if (self.isExit == NO) {
                self.arr = @[self.textStr,self.dateStr,@"lmy",remindStr,self.dateRemind,self.repeatStr,self.audioDict];
            } else {
                self.arr = @[self.textStr,self.dateStr,self.imgData,remindStr,self.dateRemind,self.repeatStr,self.audioDict];
            }

            [self.noteArr addObject:self.arr];
            [self.noteArr writeToFile:str atomically:YES];
        }
        // 返回 note 界面
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Continue?" message:@"You didn't insert any message!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            // 返回 note 界面
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
// 文件操作
-(void)fileHandleOperate {
    //  沙盒  －－－   Documents 目录
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str = [documents stringByAppendingPathComponent:@"note.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager contentsOfDirectoryAtPath:documents error:nil];
    
    // 获取数据： 日期 和 文本内容
    self.dateStr = [[self getTodayDate] substringToIndex:16];
    self.textStr = self.noteText.text;
    
    // 若沙盒目录中已有 plist文件，即已有信息，则先读取信息
    for (NSObject *tmp in paths) {
        NSString *fileName = [NSString stringWithFormat:@"%@",tmp];
        if ([fileName containsString:@"note.plist"]) {
            self.noteArr = [NSMutableArray arrayWithContentsOfFile:str];   
            int i = 0;
            for (i = 0; i < self.noteArr.count; ++i) {
                NSArray *arr = self.noteArr[i];
                if ([self.textStr isEqualToString:arr[0]]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"The note exited!" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    self.textStr = nil;
                    self.dateStr = nil;
                    break;
                }
            }
            if (i == self.noteArr.count) {
                self.textStr = self.noteText.text;
                self.dateStr =[[self getTodayDate] substringToIndex:16];
                return ;
            }
        }
    }
    // 键盘成为第一响应
//    [self.noteText becomeFirstResponder];
    // 关闭键盘
//    [self.noteText resignFirstResponder];
//    [self.view endEditing:YES];
}

#pragma mark - 插入图片
- (IBAction)insertImg:(id)sender {
    if (self.exit) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reminding" message:@"Sure to change image?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self insertNewImage];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [self insertNewImage];
    }
}
-(void)insertNewImage {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Insert image" message:@"choose way" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"visit album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self visitAlbum];
    }];
    UIAlertAction *photo = [UIAlertAction actionWithTitle:@"take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [sheet addAction:album];
    [sheet addAction:photo];
    [sheet addAction:cancel];
    [self presentViewController:sheet animated:YES completion:nil];
}
-(void)insertImage:(UIImage *)image {
    self.exit = YES;
    NSString *str = [self.noteText.text stringByAppendingString:@"\n"];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    
    // 设置 attributedText 字体
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18.0] range:NSMakeRange(0, str.length)];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:@"image"];
//    NSLog(@"%f %f",img.size.width,img.size.height);
    // 若图片过大，则同比例缩小
    self.imgInsert = [self scaleFromImage:image newWidth:WIDTH - 50];
    textAttachment.image = self.imgInsert;
    
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
    
    // index 不能超过 文字的个数
    [string insertAttributedString:textAttachmentString atIndex:str.length];
    
    self.noteText.attributedText = string;
    self.imgData = UIImagePNGRepresentation(self.imgInsert);
}
// 同比例缩小图片
-(UIImage *)scaleFromImage:(UIImage *)image newWidth:(CGFloat)newWidth {
    CGSize imageSize = image.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width <= newWidth)
        return image;
    if (width == 0 || height == 0)
        return image;
    // 获得比例
    CGFloat widthFactor = newWidth / width;
    CGFloat scaleFactor =  widthFactor;
    // 同比例缩小
    CGFloat scaledWidth = newWidth;
    CGFloat scaledHeight = height * scaleFactor;
    CGSize newSize = CGSizeMake(scaledWidth,scaledHeight);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark     get image method
// 访问相册
-(void)visitAlbum {
    // 获取数据源
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 设置代理
    self.imgPicker.delegate = self;
    // 显示
    [self presentViewController:self.imgPicker animated:YES completion:nil];
}
// 访问摄像头
-(void)takePhoto {
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imgPicker.delegate = self;
    self.imgPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    [self presentViewController:self.imgPicker animated:YES completion:nil];
}

#pragma mark       Navigation/UIImagePicker delegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 获取图片
    self.imgInsert = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // 若访问的是摄像头，则进行保存
    if (self.imgPicker.sourceType == UIImagePickerControllerSourceTypeCamera)
        UIImageWriteToSavedPhotosAlbum(self.imgInsert, self, nil, NULL);
    
    // 返回
    [self.imgPicker dismissViewControllerAnimated:YES completion:nil];
    
    // 插入图片
    [self insertImage:self.imgInsert];
}

#pragma mark - 插入音频 相关操作
- (IBAction)audioClicked:(id)sender {
    if ([[self.audioDict valueForKey:@"state"]integerValue] == 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Remind" message:@"Audio exited!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // 动画跳出 audioView －－ 弹性动画
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            CGFloat audioW = WIDTH*3/4;
            self.audioView.frame = CGRectMake(0, 0, audioW, audioW);
            self.audioView.center = CGPointMake(WIDTH/2, HEIGHT*2/5);
        } completion:^(BOOL finished) {
        }];
    }
    self.isAudio = YES;
}
#pragma mark  收到完成录音通知后的相关操作
// 点击 audoView 的 complete 后
-(void)getAudio:(NSNotification *)noti {
    stateCom1 = 1;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Remind" message:@"add name or sample discribution" preferredStyle:UIAlertControllerStyleAlert];
    // 创建文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 读取文本框的值
        UITextField *input = alertController.textFields.firstObject;
        
        // 获取 audio 信息
        self.audioDict = [NSMutableDictionary dictionaryWithDictionary:noti.userInfo];
        [self.audioDict setValue:input.text forKey:@"name"];
        
        // 添加 播放器view
        [self addAudioView];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
// 在 textView 中 添加 播放view
-(void)addAudioView {
    // view height
    CGFloat audioH = HEIGHT/9.0;
    self.topCons.constant += audioH;
    
    // audio View
    self.reportView = [[AudioPlayerView alloc]init];
    [self.view addSubview:self.reportView];
    
    // 开始／暂停 Btn
    [self.reportView.playBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    
    // 停止 Btn
    [self.reportView.stopBtn addTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
    
    // 删除 Btn
    [self.reportView.deleteBtn addTarget:self action:@selector(deleteAudio) forControlEvents:UIControlEventTouchUpInside];
    
    // 总时长
    int t = [[self.audioDict valueForKey:@"time"] intValue];
    self.reportView.totalTimeL.text = [NSString stringWithFormat:@"%02d:%02d",t/60,t%60];
    
    // 描述 label
    self.reportView.discributionL.text = [self.audioDict valueForKey:@"name"];
}
#pragma mark     button 相关操作
// 播放录音的 开始／暂停
-(void)playOrPause {
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    
    self.isAudio = !self.isAudio;
    NSString *imgName = self.isAudio?@"play":@"pause";
    
    [self.reportView.playBtn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [self.reportView.playBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documents stringByAppendingPathComponent:[self.audioDict valueForKey:@"path"]];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    if (self.isAudio) {
        [self.player pause];
        [self.timer invalidate];
        [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    } else {
        // 开启红外感应
        [[UIDevice currentDevice]setProximityMonitoringEnabled:YES];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStart) userInfo:nil repeats:YES];
        [self.player play];
    }
}
// 播放录音的 停止
-(void)stopAudio {
    c = 0;                              // 定时器计数清零
    [self.timer invalidate];            // 定时器关闭
    [self.player stop];                 // 关闭播放器
    
    [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    
    // play 按钮状态改变
    self.isAudio = NO;
    [self playOrPause];
    
    self.reportView.timeL.text = @"00:00";
    self.reportView.progress.progress = 0.0;
}
// 播放录音的 删除
-(void)deleteAudio {
    [self stopAudio];
    
    // textView 界面变化
    [self.reportView removeFromSuperview];
    CGFloat audioH = HEIGHT/9.0;
    self.topCons.constant -= audioH;
    
    // 删除音频
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documents stringByAppendingPathComponent:[self.audioDict valueForKey:@"path"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    
    self.audioDict[@"state"] = @0;
    self.audioDict[@"path"]  = @"nil";
    self.audioDict[@"time"]  = @0;
    self.audioDict[@"name"]  = @"nil";
}
#pragma mark  听筒、扬声器的监测
-(void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES)
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    else
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

#pragma mark   定时器
-(void)timerStart {
    if (c == [[self.audioDict valueForKey:@"time"] intValue]) {
        [self stopAudio];
    } else {
        ++c;
        self.reportView.timeL.text = [NSString stringWithFormat:@"%02d:%02d",c/60,c%60];
        self.reportView.progress.progress += 1.0/[[self.audioDict valueForKey:@"time"] intValue];
    }
}

#pragma mark - block 传值  获取 提醒的状态和时间
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"remind"]) {
        remindTableViewController *remind = segue.destinationViewController;
        remind.block = ^ (BOOL isRemind,NSDate *remindDate,NSString *repeat){
            self.isRemind = isRemind;
            self.dateRemind = remindDate;
            self.repeatStr = repeat;
        };
    } else if ([segue.identifier isEqualToString:@"draw"]) {
        if (self.exit) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reminding" message:@"Sure to change image?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                DrawBoardVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"draw"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}

@end
