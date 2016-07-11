//
//  ViewController.m
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/7.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import "ViewController.h"
#import "noteEdit.h"
#import "LMYCell.h"
#import "AppDelegate.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UISearchBarDelegate>
{
    UIBarButtonItem *move;
    UIBarButtonItem *delete;
    UIToolbar *toolBar;
    
    int isAudio;
}
@property (nonatomic, assign) BOOL isSearch;
@property (nonatomic, strong) NSMutableArray *searchArr;

@property (nonatomic, strong) NSMutableArray *editArr;
@property (nonatomic, strong) NSMutableArray *noteArr;

@end

@implementation ViewController

#pragma mark - 懒加载 进行初始化
// 懒加载 － get方法 － 需要用到数据的时候才加载数据
// 初始化数组
-(NSMutableArray *)textArr {
    if (_textArr == nil)
        _textArr = [NSMutableArray array];
    return _textArr;
}
-(NSMutableArray *)dateArr {
    if (_dateArr == nil)
        _dateArr = [NSMutableArray array];
    return _dateArr;
}
-(NSMutableArray *)imageArr {
    if (_imageArr == nil)
        _imageArr = [NSMutableArray array];
    return _imageArr;
}
-(NSMutableArray *)remindArr {
    if (_remindArr == nil)
        _remindArr = [NSMutableArray array];
    return _remindArr;
}
-(NSMutableArray *)audioArr {
    if (_audioArr == nil)
        _audioArr = [NSMutableArray array];
    return _audioArr;
}
-(NSMutableArray *)audioPathArr {
    if (_audioPathArr == nil)
        _audioPathArr = [NSMutableArray array];
    return _audioPathArr;
}

#pragma mark - view operation
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewWillAppear:) name:@"viewAppear" object:nil];
    
    // 在没有 cell 的部分，不显示 cell 横线
    self.noteTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    // 导航栏 设置
    UIBarButtonItem *editBtn=[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editBtnClick)];
    self.navigationItem.rightBarButtonItem = editBtn;
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStyleDone target:self action:@selector(openOrCloseLeft)];
    self.navigationItem.leftBarButtonItem = left;
    
    // 设置 cell 高度
    self.noteTableView.rowHeight = 80;
    
    // tableViewCell可进行多选
    self.noteTableView.allowsMultipleSelectionDuringEditing = YES;
    // 编辑状态下 Item 初始化
    move = [[UIBarButtonItem alloc] initWithTitle:@"move" style:UIBarButtonItemStylePlain target:self action:@selector(moveItem)];
    move.tintColor = [UIColor orangeColor];
    
    delete = [[UIBarButtonItem alloc] initWithTitle:@"delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteItem)];
    delete.tintColor = [UIColor orangeColor];
    
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    // toolBar 底部工具栏设置
    toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, HEIGHT-44, WIDTH, 44)];
    toolBar.items = [NSArray arrayWithObjects:fixed,move,fixed,delete,fixed, nil];
    toolBar.barStyle = UIBarStyleDefault;
    toolBar.hidden = YES;
    [self.view addSubview:toolBar];
    
    // 初始化 在编辑状态的存放行号的数组
    self.editArr = [[NSMutableArray alloc]initWithCapacity:0];
    
    isAudio = 0;
}

// 下滑 关闭键盘
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
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

// 在 tableView 上 按照时间降序排序
-(void)sortPlist {
    for (int i = 1; i < self.noteArr.count; i++)
        for (int j = 0; j < self.noteArr.count-1; j++)
            if ([self.noteArr[j][1] compare: self.noteArr[j+1][1]] == NSOrderedDescending ){
                NSString *tmp = self.noteArr[j];
                self.noteArr[j] = self.noteArr[j+1];
                self.noteArr[j+1] = tmp;
            }
}

// 页面出现时调用
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 侧滑效果
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [tempAppDelegate.leftSlider setPanEnabled:YES];
    // 本地通知的提醒事件刷新
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate getNewRemindArr];
    
    // 从 plist 中得到已有的数组
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSLog(@"%@",documents);
    NSString *str=[documents stringByAppendingString:@"/note.plist"];
    self.noteArr = [NSMutableArray arrayWithContentsOfFile:str];
    [self sortPlist];
    
    // 设置导航栏两边 button 字体颜色
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    [self viewChanged];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [tempAppDelegate.leftSlider setPanEnabled:NO];
}

#pragma mark 侧滑
-(void)openOrCloseLeft {
    NSNotification *notifOn = [NSNotification notificationWithName:@"notifOn" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notifOn];
    
    AppDelegate *tmpDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (tmpDelegate.leftSlider.closed)
        [tmpDelegate.leftSlider openLeftView];
    else
        [tmpDelegate.leftSlider closeLeftView];
}

#pragma mark  页面出现／页面有改变
-(void)viewChanged {
    // 把数组赋空，重新加载/初始化数组
    self.textArr = nil;
    self.dateArr = nil;
    self.imageArr = nil;
    self.remindArr = nil;
    self.audioArr = nil;
    self.audioPathArr = nil;
    
    [self directoryOperate];
    // 刷新界面的改变
    NSPredicate *pred=[NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@",self.searchBar.text];
    _searchArr= [[_textArr filteredArrayUsingPredicate:pred]copy];
    
    [self.noteTableView reloadData];    // 刷新 tableView
    [self showEdit];                    // edit Item 的显示
    [self setImageBackground];          // tableView 的显示
}

#pragma mark  没有 note 情况下的界面显示
-(void)setImageBackground {
    if (self.noteArr.count == 0)
        self.noNoteLabel.hidden = NO;
    else
        self.noNoteLabel.hidden = YES;
}

#pragma mark  edit 按钮的显示与隐藏
-(void)showEdit {
    if(self.textArr.count == 0) {
        self.noteTableView.editing = NO;
        self.navigationItem.rightBarButtonItem.enabled=NO;
        self.navigationItem.rightBarButtonItem.title=@"Edit";
        toolBar.hidden = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
}

#pragma mark - 目录操作
-(void)directoryOperate {
    for (NSArray *arr in self.noteArr) {
        // 文本内容存入数组
        [self.textArr addObject:arr[0]];
        
        // 文本日期存入数组
        NSString *timeStr = [arr[1] substringToIndex:10];
        NSString *nStr = [[self getTodayDate] substringToIndex:10];
        if(![timeStr isEqualToString:nStr])
            [self.dateArr addObject:timeStr];// 今天之前 只显示年月日
        else        // 今日编辑 只显示时分
            [self.dateArr addObject:[arr[1] substringFromIndex:11]];
        
        // image 是否存在
        Class imageClass = NSClassFromString(@"NSString");
        if ([arr[2] isKindOfClass:imageClass])
            [self.imageArr addObject:@"0"];
        else
            [self.imageArr addObject:@"1"];
        
        // remind 是否存在
        if ([arr[3] isEqualToString:@"1"])
            [self.remindArr addObject:@"1"];
        else
            [self.remindArr addObject:@"0"];
        
        // audio 是否存在
        NSMutableDictionary *dict = arr[6];
        if ([[dict valueForKey:@"state"]integerValue] == 1) {
            [self.audioArr addObject:@"1"];
            [self.audioPathArr addObject:[dict valueForKey:@"path"]];
        } else {
            [self.audioArr addObject:@"0"];
            [self.audioPathArr addObject:@"lmy"];
        }
    }
}

#pragma mark - tableView dataSource
// 共有多少条便签
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 显示共有多少条便签
    if (self.isSearch) {
        self.noteNum.text = [NSString stringWithFormat:@"%lu",
                             [self.searchArr count]];
        return [self.searchArr count];
    }
    
    self.noteNum.text = [NSString stringWithFormat:@"%lu",
                         [self.textArr count]];
    return [self.textArr count];
}
// 逆序显示每条内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LMYCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (cell == nil)
        cell = [LMYCell LMYCell];
    
    // 编辑状态的 cell 的移动动画
    if (isAudio == 1) {
        if (_noteTableView.editing)
            [UIView animateWithDuration:0.5 animations:^{
                cell.leftCons.constant += 40;
            }];
        else
            [UIView animateWithDuration:0.5 animations:^{
            }];
    }
    
    // cell 背景色
    cell.backgroundColor = [UIColor colorWithRed:248/255.0 green:250/255.0 blue:229/255.0 alpha:1];
    // cell 小图标
    cell.img1.image = [UIImage imageNamed:@"image"];
    cell.img2.image = [UIImage imageNamed:@"audio"];
    cell.img3.image = [UIImage imageNamed:@"remind"];
    
    if (self.isSearch) {
        NSInteger index = [self.searchArr count]-1 -indexPath.row;
        NSMutableArray *messageArr = [self getFileMessage:index];
        
        [cell.textLab setText:_searchArr[index]];
        [cell.detailLab setText:messageArr[0]];
        if ([messageArr[1] isEqualToString:@"1"])
            cell.img1.image = [UIImage imageNamed:@"images"];
        if ([messageArr[2] isEqualToString:@"1"])
            cell.img3.image = [UIImage imageNamed:@"reminds"];
        if ([messageArr[3] isEqualToString:@"1"])
            cell.img2.image = [UIImage imageNamed:@"audios"];
    } else {
        NSInteger index = [self.textArr count]-1 -indexPath.row;
        
        cell.textLab.text = [self.textArr objectAtIndex:index];
        cell.detailLab.text = [self.dateArr objectAtIndex:index];
        if ([self.imageArr[index] isEqualToString:@"1"])
            cell.img1.image = [UIImage imageNamed:@"images"];
        if ([self.audioArr[index] isEqualToString:@"1"])
            cell.img2.image = [UIImage imageNamed:@"audios"];
        if ([self.remindArr[index] isEqualToString:@"1"])
            cell.img3.image = [UIImage imageNamed:@"reminds"];
    }
    return cell;
}
#pragma mark  返回指定的文件内容
-(NSMutableArray *)getFileMessage:(NSInteger)row {
    NSMutableArray *messageArr = [NSMutableArray array];
    
    for (int i = 0; i < self.noteArr.count; i++) {
        NSArray *arr = self.noteArr[i];
        for (int j = 0; j < self.searchArr.count; ++j)
            if ([self.searchArr[j] isEqualToString:arr[0]] && j==row) {
                NSString *timeStr = [arr[1] substringToIndex:10];
                NSString *nStr = [[self getTodayDate] substringToIndex:10];
                if(![timeStr isEqualToString:nStr])
                    [messageArr addObject:timeStr];
                else
                    [messageArr addObject:[arr[1] substringFromIndex:11]];
                
                // image
                Class imageClass = NSClassFromString(@"NSString");
                if ([arr[2] isKindOfClass:imageClass])
                    [messageArr addObject:@"0"];
                else
                    [messageArr addObject:@"1"];
                
                // remind
                [messageArr addObject:arr[3]];
                
                // audio
                NSMutableDictionary *dict = arr[6];
                if ([[dict valueForKey:@"state"]integerValue] == 1)
                    [messageArr addObject:@"1"];
                else
                    [messageArr addObject:@"0"];
            }
    }
    return messageArr;
}

#pragma mark - tableView delegate
// 取消点击 cell
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (self.noteTableView.editing) {
        NSString *row=[NSString stringWithFormat:@"%lu",indexPath.row];
        [_editArr removeObject:row];
        _editArr = [self sortArr];
    }
}

// 点击每次 cell 后的跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 若不在编辑状态
    if (!self.noteTableView.editing) {
        if (_isSearch) {
            for (int i = 0; i < self.searchArr.count; ++i)
                if (i == self.searchArr.count-1 - indexPath.row) {
                    NSString *t = self.searchArr[i];
                    noteEdit *edit = [[noteEdit alloc] initWithText:t];
                    [self.navigationController pushViewController:edit animated:YES];
                }
        } else {
        for (int i = 0; i < self.noteArr.count; ++i)
            if (i == self.noteArr.count-1 - indexPath.row) {
                NSArray *arr = self.noteArr[i];
                noteEdit *edit = [[noteEdit alloc] initWithText:arr[0]];
                [self.navigationController pushViewController:edit animated:YES];
            }
        }
    } else {
        NSString *row=[NSString stringWithFormat:@"%lu",indexPath.row];
        [_editArr addObject:row];
        _editArr = [self sortArr];
    }
}
// 冒泡排序，选中的 cell 按 row 从大到小
-(NSMutableArray *)sortArr {
    NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:_editArr];
    for (int i = 1; i < arr.count; i++)
        for (int j = 0; j < arr.count-i; j++)
            if (arr[j] < arr[j+1]) {
                NSString *tmp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = tmp;
            }
    return arr;
}

#pragma mark - 自定义 左滑按钮  便签的删除和移动
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *moveAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"~.~move" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 移到 private note 中
        [self moveToPrivate:indexPath.row];
        // 在最后希望cell可以自动回到默认状态，所以需要退出编辑模式
//        tableView.editing = NO;
    }];
    
    UITableViewRowAction *deleteAct = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"~.~ delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 删除文件
        [self deleteFile:indexPath.row];
    }];
    
    return @[deleteAct, moveAct];
}
// 删除 便签
-(void)deleteFile:(NSInteger)row {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str=[documents stringByAppendingString:@"/note.plist"];
    
    if (_isSearch) {
        NSString *txt = _searchArr[[_searchArr count]-1 -row];
        for (int i = 0; i < self.noteArr.count; ++i) {
            NSArray *arr = self.noteArr[i];
            if ([txt isEqualToString:arr[0]]) {
                NSMutableDictionary *dict = arr[6];
                if ([[dict valueForKey:@"state"]integerValue] == 1)
                    [self deleteAudio:[dict valueForKey:@"path"]];

                [self.noteArr removeObjectAtIndex:i];
                [self.noteArr writeToFile:str atomically:YES];
            }
        }
    } else {
        if ([self.audioArr[self.noteArr.count-1-row]intValue] == 1 )
            [self deleteAudio:self.audioPathArr[self.noteArr.count-1-row]];
        
        [self.noteArr removeObjectAtIndex:(self.noteArr.count-1-row)];
        [self.noteArr writeToFile:str atomically:YES];
    }
    [self viewChanged];
}
// 删除音频
-(void)deleteAudio:(NSString *)fileName {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documents stringByAppendingPathComponent:fileName];
    // 文件管理器 是专门用于文件管理的类
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 删除文件
    [fileManager removeItemAtPath:filePath error:nil];
}
// 便签移到 private note 中
-(void)moveToPrivate:(NSInteger)row {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str=[documents stringByAppendingString:@"/note.plist"];
    
    NSString *dateStr = [NSString new];
    NSString *textStr = [NSString new];
    NSData *imgData = [NSData new];
    NSString *remindStr = [NSString new];
    NSDate *remindDate = [NSDate new];
    NSString *repeatStr = [NSString new];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (_isSearch) {
        // 从 note 中删除
        NSString *txt = _searchArr[[_searchArr count]-1 -row];
        for (int i = 0; i < self.noteArr.count; ++i) {
            NSArray *arr = self.noteArr[i];
            if ([txt isEqualToString:arr[0]]) {
                textStr = arr[0];
                dateStr = arr[1];
                imgData = arr[2];
                remindStr = arr[3];
                remindDate = arr[4];
                repeatStr = arr[5];
                dict = arr[6];
                
                [self.noteArr removeObjectAtIndex:i];
                [self.noteArr writeToFile:str atomically:YES];
                break;
            }
        }
    } else {
        for (int i = 0; i < self.noteArr.count; ++i)
            if (i == self.noteArr.count-1-row) {
                NSArray *arr = self.noteArr[i];
                textStr = arr[0];
                dateStr = arr[1];
                imgData = arr[2];
                remindStr = arr[3];
                remindDate = arr[4];
                repeatStr = arr[5];
                dict = arr[6];
                
                // 从 note 中删除
                [self.noteArr removeObjectAtIndex:(self.noteArr.count-1-row)];
                [self.noteArr writeToFile:str atomically:YES];
                break;
            }
    }
    // 在 private 中新建
    [self newPrivateWithText:textStr Date:dateStr imgData:imgData remindStr:remindStr remindDate:remindDate repeatStr:repeatStr dict:dict];
    
    [self viewChanged];
}
// 在 private 中新建
-(void)newPrivateWithText:(NSString *)text Date:(NSString *)date imgData:(NSData *)img remindStr:(NSString *)remindStr remindDate:(NSDate *)remindDate repeatStr:(NSString *)repeatStr dict:(NSMutableDictionary *)dict {
    
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *str=[documents stringByAppendingString:@"/private.plist"];
    NSMutableArray *privateArr = [NSMutableArray new];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager contentsOfDirectoryAtPath:documents error:nil];
    for (NSObject *tmp in paths) {
        NSString *fileName = [NSString stringWithFormat:@"%@",tmp];
        
        if ([fileName containsString:@"private.plist"]) {
            // 若沙盒目录中已有 plist文件，即已有信息，则先读取信息
            privateArr = [NSMutableArray arrayWithContentsOfFile:str];
            // 保证内容不重复
            int i = 0;
            for (i = 0; i < privateArr.count; ++i) {
                NSArray *arr = privateArr[i];
                if ([text isEqualToString:arr[0]]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"The note exited!" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    break;
                }
            }
            if (i == privateArr.count) {
                // 将获取到的信息存入 plist 中
                NSArray *arr1 = @[text,date,img,remindStr,remindDate,repeatStr,dict];
                [privateArr addObject:arr1];
                [privateArr writeToFile:str atomically:YES];
            }
            return ;
        }
    }
    // 将获取到的信息存入 plist 中
    NSArray *arr1 = @[text,date,img,remindStr,remindDate,repeatStr,dict];
    [privateArr addObject:arr1];
    [privateArr writeToFile:str atomically:YES];
}

#pragma mark  - searBar的代理方法
//点击虚拟键盘上的搜索按键
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self filterByString:searchBar.text];
    [searchBar resignFirstResponder];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
        self.isSearch = NO;
        [self.noteTableView reloadData];
        return;
    }
    [self filterByString:searchBar.text];
    [self.noteTableView reloadData];
}
-(void)filterByString:(NSString *)subStr {
    self.isSearch=YES;
    // 模糊搜索
    NSPredicate *pred=[NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@",subStr];
    _searchArr= [[_textArr filteredArrayUsingPredicate:pred]copy];
}

#pragma mark - 点击 edit 可进行批量管理 移动和删除
-(void)editBtnClick {
    isAudio  = 1;
    [self.noteTableView reloadData];
    NSString *string = !_noteTableView.editing?@"Cancel":@"Edit";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:string style:UIBarButtonItemStyleDone target:self action:@selector(editBtnClick)];
    
    // 切换是否在 编辑状态
    self.noteTableView.editing = !self.noteTableView.editing;
    
    if (self.noteTableView.editing)
        toolBar.hidden = NO;
    else
        toolBar.hidden = YES;
}
// 可批量移动
-(void)moveItem {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"~.~ move" message:@"please choose" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *all = [UIAlertAction actionWithTitle:@"move All" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _editArr = nil;
        _editArr = [NSMutableArray new];
        for (NSInteger row = self.textArr.count-1; row >=0; --row)
            [self moveToPrivate:row];
        _editArr = nil;
        _editArr = [NSMutableArray new];
    }];
    UIAlertAction *part = [UIAlertAction actionWithTitle:@"move Chosen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (int i = 0; i < _editArr.count; i++) {
            NSInteger row = [_editArr[i] integerValue];
            [self moveToPrivate:row];
        }
        // 移动后清空 临时数组， 并初始化，可继续进行编辑
        _editArr = nil;
        _editArr = [NSMutableArray new];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [sheet addAction:all];
    [sheet addAction:part];
    [sheet addAction:cancel];
    [self presentViewController:sheet animated:YES completion:nil];
}

// 可批量删除
-(void)deleteItem {
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"~.~ delete" message:@"please choose" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *all = [UIAlertAction actionWithTitle:@"delete All" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _editArr = nil;
        _editArr = [NSMutableArray new];
        for (NSInteger row = self.textArr.count-1; row >=0; --row)
            [self deleteFile:row];
        _editArr = nil;
        _editArr = [NSMutableArray new];
    }];
    UIAlertAction *part = [UIAlertAction actionWithTitle:@"delete Chosen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        for (int i = 0; i < _editArr.count; i++) {
            NSInteger row = [_editArr[i] integerValue];
            [self deleteFile:row];
        }
        // 删除后清空 临时数组， 并初始化，可继续进行编辑
        _editArr = nil;
        _editArr = [NSMutableArray new];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [sheet addAction:all];
    [sheet addAction:part];
    [sheet addAction:cancel];
    [self presentViewController:sheet animated:YES completion:nil];
}

@end
