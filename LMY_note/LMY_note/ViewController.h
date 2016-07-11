//
//  ViewController.h
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/7.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
                        <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noNoteLabel;
// note 文本内容
@property (weak, nonatomic) IBOutlet UITableView *noteTableView;
// note 个数
@property (weak, nonatomic) IBOutlet UILabel *noteNum;
// 搜索栏
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// 存放 note 内容的数组
@property (nonatomic, strong) NSMutableArray *textArr;
@property (nonatomic, strong) NSMutableArray *dateArr;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray *remindArr;
@property (nonatomic, strong) NSMutableArray *audioArr;
@property (nonatomic, strong) NSMutableArray *audioPathArr;

@end

