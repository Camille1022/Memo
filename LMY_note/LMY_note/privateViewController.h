//
//  privateViewController.h
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/8.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface privateViewController : UIViewController
                        <UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *noNoteLabel;
// private 文本内容
@property (weak, nonatomic) IBOutlet UITableView *privateTableView;
// private 个数
@property (weak, nonatomic) IBOutlet UILabel *privateNum;
// 底部工具栏
@property (weak, nonatomic) IBOutlet UIToolbar *privateToolBar;
// 搜索栏
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

// 存放 private 内容的数组
@property (nonatomic, strong) NSMutableArray *privateText;
@property (nonatomic, strong) NSMutableArray *privateDate;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic, strong) NSMutableArray *remindArr;
@property (nonatomic, strong) NSMutableArray *audioArr;
@property (nonatomic, strong) NSMutableArray *audioPathArr;

@end
