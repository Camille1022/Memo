//
//  privateNoteEdit.m
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/8.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import "privateNoteEdit.h"
#import "remindTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "audioView.h"
#import "AudioPlayerView.h"
#import "DrawBoardVC.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface privateNoteEdit ()<CJReMindTableVCDelegate>
{
    UITextView *noteTextView;
    UIBarButtonItem *completeBtn;
    UIToolbar *toolBar;
    
    UIBarButtonItem *image;
    UIBarButtonItem *audio;
    UIBarButtonItem *write;
    UIBarButtonItem *remind;
    UIBarButtonItem *delete;
    
    int c;
    int stateCom1;
    int stateCom2;
    int isAudioExist;
}
@property (nonatomic, strong) NSMutableArray *noteArr;

// image 相关
@property (nonatomic,assign,getter=isExit)BOOL exit;
@property (nonatomic, strong) UIImagePickerController *imgPicker;
@property (nonatomic, strong) UIImage *imgInsert;

// audio 相关
@property (nonatomic, strong) audioView *audioView;
@property (nonatomic, strong) AudioPlayerView *reportView;
@property (nonatomic, assign) BOOL isAudio;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSTimer *timer;
@end

@implementation privateNoteEdit

#pragma mark - 懒加载 进行初始化
-(instancetype)initWithText:(NSString *)text {
    if (self = [super init])
        self.cText = text;
    return self;
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
    
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:231/255.0 blue:251/255.0 alpha:1];
    
    // 从 plist 中读取已存在的内容
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str = [documents stringByAppendingPathComponent:@"private.plist"];
    self.noteArr = [NSMutableArray arrayWithContentsOfFile:str];
    
    // 收到通知后
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAudio:) name:@"audio" object:nil];
    
    // 设置文本 textView
    [self setNoteTextView];
    // 显示文本对应的 cell 的内容
    [self showNote];
    
    // 导航栏设置
    completeBtn=[[UIBarButtonItem alloc] initWithTitle:@"complete" style:UIBarButtonItemStylePlain target:self action:@selector(CompleteClick)];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
    // items 初始化
    image = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img"] style:UIBarButtonItemStylePlain target:self action:@selector(imageItem)];
    image.tintColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
    audio = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"au"] style:UIBarButtonItemStylePlain target:self action:@selector(audioItem)];
    audio.tintColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
    write = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"draw"] style:UIBarButtonItemStylePlain target:self action:@selector(writeItem)];
    write.tintColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
    remind = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"rem"] style:UIBarButtonItemStylePlain target:self action:@selector(remindItem)];
    remind.tintColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
    delete = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"de"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteItem)];
    delete.tintColor = [UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // toolBar 底部工具栏设置
    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, HEIGHT-44, WIDTH, 44)];
    toolBar.items = [NSArray arrayWithObjects:fixed,image,fixed,audio,fixed,write,fixed,remind,fixed,delete,fixed, nil];
    toolBar.barStyle = UIBarStyleDefault;
    [self.view addSubview:toolBar];
    
    // 轻扫 手势识别器
    UISwipeGestureRecognizer *mySwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doSwipe:)];
    mySwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:mySwipe];
}

// 处理 轻扫手势 的回调函数 ------ 下滑 关闭键盘
-(void)doSwipe:(UISwipeGestureRecognizer *)swipe {
    [self.view endEditing:YES];
}

// 获得当前时间
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
        (stateCom1 == 0 || stateCom2 == 0) && isAudioExist == 0) {
        NSString *filePath = [documents stringByAppendingPathComponent:fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:filePath error:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    noteTextView.font = [UIFont fontWithName:@"Arial" size:18.0];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(insertDrawImage:) name:@"drawImage" object:nil];
}

-(void)insertDrawImage:(NSNotification *)notif {
    self.imgInsert = [[notif userInfo]valueForKey:@"image"];
    [self insertImage:self.imgInsert];
}

#pragma mark - textView delegate - 文本内容有改动
-(void)textViewDidChange:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = completeBtn;
    noteTextView.font = [UIFont fontWithName:@"Arial" size:18.0];
    // 检测图片存在问题
    NSMutableArray *arrM=[NSMutableArray array];
    NSDictionary *attributeDict;
    NSRange effectiveRange = { 0, 0 };
    if (textView.attributedText.length==0)
        return;
    
    do {
        NSRange range;
        range = NSMakeRange (NSMaxRange(effectiveRange),[textView.attributedText length] - NSMaxRange(effectiveRange));
        
        attributeDict = [textView.attributedText attributesAtIndex:range.location longestEffectiveRange:&effectiveRange inRange:range];
        
        [arrM addObject:attributeDict];
        
    } while (NSMaxRange(effectiveRange)<[textView.attributedText length]);
    
    if (arrM.count == 1)
        self.exit = NO;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    noteTextView.frame = CGRectMake(20, 6, WIDTH-40, HEIGHT-44-240);
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    noteTextView.frame = CGRectMake(20, 6, WIDTH-40, HEIGHT-44);
}

#pragma mark - textView 的设置和显示
// 设置文本 textView
-(void)setNoteTextView {
    noteTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 6, WIDTH-40, HEIGHT-50)];
    noteTextView.backgroundColor = [UIColor colorWithRed:255/255.0 green:231/255.0 blue:251/255.0 alpha:1];
    noteTextView.font = [UIFont fontWithName:@"Arial" size:18.0];
    noteTextView.delegate = self;
    [self.view addSubview:noteTextView];
    
    [noteTextView addSubview:self.audioView];
}
// 显示文本对应内容
-(void)showNote {
    for (int i = 0; i < self.noteArr.count; ++i) {
        NSArray *arr = self.noteArr[i];
        if ([self.cText isEqualToString:arr[0]]) {
            self.cImgData = arr[2];
            self.remindStr = arr[3];
            self.dateRemind = arr[4];
            self.repeatStr = arr[5];
            self.audioDict = arr[6];
            // image 相关处理
            Class class = NSClassFromString(@"NSString");
            if ([arr[2] isKindOfClass:class])
                noteTextView.text = self.cText;
            else if (arr[2] != nil) {
                self.exit = YES;
                NSString *str = [self.cText stringByAppendingString:@"\n"];
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:str];
                
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil] ;
                UIImage *img = [[UIImage alloc]initWithData:arr[2] scale:1.0];
                textAttachment.image = img;
                
                NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
                
                [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18.0] range:NSMakeRange(0, str.length)];
                
                // index 不能超过 文字的个数
                [string insertAttributedString:textAttachmentString atIndex:str.length];
                
                noteTextView.attributedText = string;
            } else
                noteTextView.text = self.cText;
            
            // audio 相关处理
            if ([[self.audioDict valueForKey:@"state"]integerValue] == 1) {
                [self addAudioView];
                isAudioExist = 1;
            }
        }
    }
}

#pragma mark - 点击 complete 按钮，内容保存入沙盒，plist
-(void)CompleteClick {
    stateCom2 = 1;
    if(noteTextView.text.length > 0){
        // 若文本内容改变 --- 重命名文本，并将文本新内容写入文件
        [self fileOperate];
        
        // 返回 note 界面
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Continue?" message:@"You didn't insert any message!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
-(void)fileOperate {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str = [documents stringByAppendingPathComponent:@"private.plist"];
    
    // 1.删除原内容
    for (int i = 0; i < self.noteArr.count; ++i) {
        NSArray *arr = self.noteArr[i];
        if ([arr[0] isEqualToString:self.cText])
            [self.noteArr removeObjectAtIndex:i];
    }
    
    // 2.添加新内容
    self.cText = noteTextView.text;
    self.cDate = [[self getTodayDate] substringToIndex:16];
    
    NSArray *arr = [NSArray array];
    if (self.isExit==NO)
        arr = @[self.cText,self.cDate,@"lmy",self.remindStr,self.dateRemind,self.repeatStr,self.audioDict];
    else
        arr = @[self.cText,self.cDate,self.cImgData,self.remindStr,self.dateRemind,self.repeatStr,self.audioDict];
    
    [self.noteArr addObject:arr];
    [self.noteArr writeToFile:str atomically:YES];
}

#pragma mark - toolBar Items 点击后相关操作
-(void)imageItem {
    self.navigationItem.rightBarButtonItem = completeBtn;
    self.imgPicker = [[UIImagePickerController alloc]init];
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
-(void)audioItem {
    if ([[self.audioDict valueForKey:@"state"]integerValue] == 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Remind" message:@"Audio exited!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        self.navigationItem.rightBarButtonItem = completeBtn;
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
-(void)writeItem {
    if (self.exit) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reminding" message:@"Sure to change image?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.navigationItem.rightBarButtonItem = completeBtn;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            DrawBoardVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"draw"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        self.navigationItem.rightBarButtonItem = completeBtn;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        remindTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"draw"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)remindItem {
    [[NSUserDefaults standardUserDefaults]setValue:self.remindStr forKey:@"remind"];
    [[NSUserDefaults standardUserDefaults]setValue:self.repeatStr forKey:@"repeat"];
    
    self.navigationItem.rightBarButtonItem = completeBtn;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    remindTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"remind"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)deleteItem {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str = [documents stringByAppendingPathComponent:@"private.plist"];
    // 是否确认删除
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reminding" message:@"Sure to delete?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 原文件删除
        for (int i = 0; i < self.noteArr.count; ++i) {
            NSArray *arr = self.noteArr[i];
            if ([self.cText isEqualToString:arr[0]]) {
                [self.noteArr removeObjectAtIndex:i];
                [self.noteArr writeToFile:str atomically:YES];
            }
        }
        // 返回 note 界面
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 图片相关操作
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
-(void)insertImage:(UIImage *)img {
    self.navigationItem.rightBarButtonItem = completeBtn;
    self.exit=YES;
    NSString *str = [noteTextView.text stringByAppendingString:@"\n"];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:str];
    
    // 设置 attributedText 字体
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18.0] range:NSMakeRange(0, str.length)];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:@"image"];
    // 若图片过大，则同比例缩小
    self.imgInsert = [self scaleFromImage:img newWidth:WIDTH - 50];
    textAttachment.image = self.imgInsert;
    
    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment] ;
    
    // index 不能超过 文字的个数
    [string insertAttributedString:textAttachmentString atIndex:str.length];
    noteTextView.attributedText = string;
    self.cImgData = UIImagePNGRepresentation(self.imgInsert);
}
// 同比缩小图片
-(UIImage *)scaleFromImage:(UIImage *)img newWidth:(CGFloat)newWidth {
    CGSize imageSize = img.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    if (width <= newWidth)
        return img;
    if (width == 0 || height == 0)
        return img;
    // 获得比例
    CGFloat widthFactor = newWidth / width;
    CGFloat scaleFactor =  widthFactor;
    // 同比例缩小
    CGFloat scaledWidth = newWidth;
    CGFloat scaledHeight = height * scaleFactor;
    CGSize newSize = CGSizeMake(scaledWidth,scaledHeight);
    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0,0,scaledWidth,scaledHeight)];
    UIImage* newImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark      get image method
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
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
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

#pragma mark - 收到完成录音通知后的相关操作
// 点击 audoView 的 complete 后
-(void)getAudio:(NSNotification *)noti {
    stateCom1 = 1;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Remind" message:@"add name or sample discribution" preferredStyle:UIAlertControllerStyleAlert];
    // 创建文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 读取文本框的值显示出来
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
    CGFloat audioH = HEIGHT/9.0;
    noteTextView.frame = CGRectMake(20, audioH, WIDTH-40, HEIGHT-44);
    
    // audio View
    self.reportView = [[AudioPlayerView alloc]init];
    [self.view addSubview:self.reportView];
    
    // 开始／暂停 Btn
    [self.reportView.playBtn addTarget:self action:@selector(playOrPause) forControlEvents:UIControlEventTouchUpInside];
    
    // 停止 Btn
    [self.reportView.stopBtn addTarget:self action:@selector(stopAudio) forControlEvents:UIControlEventTouchUpInside];
    
    // 删除 Btn
    [self.reportView.deleteBtn addTarget:self action:@selector(deleteAudio) forControlEvents:UIControlEventTouchUpInside];
    
    // 描述 label
    self.reportView.discributionL.text = [self.audioDict valueForKey:@"name"];
    
    // 总时长
    int t = [[self.audioDict valueForKey:@"time"] intValue];
    self.reportView.totalTimeL.text = [NSString stringWithFormat:@"%02d:%02d",t/60,t%60];
}
#pragma mark     button 相关操作
// 播放录音的 开始／暂停
-(void)playOrPause {
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    
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
    
    if (self.isAudio) {
        [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
        [self.player pause];
        [self.timer invalidate];
    } else {
        [[UIDevice currentDevice]setProximityMonitoringEnabled:YES];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerStart) userInfo:nil repeats:YES];
        [self.player play];
    }
    
    self.isAudio = !self.isAudio;
}
// 播放录音的 停止
-(void)stopAudio {
    c = 0;
    [self.timer invalidate];
    [self.player stop];
    
    [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    
    // play 按钮状态改变
    self.isAudio = YES;
    [self playOrPause];
    
    self.reportView.timeL.text = @"00:00";
    self.reportView.progress.progress = 0.0;
}
// 播放录音的 删除
-(void)deleteAudio {
    [self stopAudio];
    self.navigationItem.rightBarButtonItem = completeBtn;
    
    // textView 界面变化
    [self.reportView removeFromSuperview];
    noteTextView.frame = CGRectMake(0, 0, WIDTH, HEIGHT-44);
    
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
#pragma mark 听筒、扬声器的监测
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

#pragma mark - remind 代理传值
-(void)remindDate:(NSDate *)date remind:(BOOL)isRemind repeat:(NSString *)repeat {
    self.remindStr = [NSString stringWithFormat:@"%d",isRemind];
    self.dateRemind = date;
}

@end
