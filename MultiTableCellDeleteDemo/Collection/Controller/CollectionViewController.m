//
//  CollectionViewController.m
//  GuDaShi
//
//  Created by mac on 2019/2/10.
//  Copyright © 2019年 晨曦科技. All rights reserved.
//

#import "UITableViewCell+ReuseID.h"
#import "CollectionViewController.h"
#import "CollectionTableViewCell.h"
#import "CollectionModel.h"
#import "NavigationView.h"
#import "UIView+CWNView.h"
#define WeakObj(o) __weak typeof(o) weak##o = o
#define HexColor(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0]

@interface CollectionViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NavigationView *navigationBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;

//cell删除
@property (strong, nonatomic) NSMutableArray *deleteDatas;//选中的待删除项
@property (weak, nonatomic) IBOutlet UIButton *selectAllBtn;//全选按钮
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;//删除按钮

//约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *originY;//页面初始位置，默认为64，需要适配iphonex
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editViewTop;//编辑视图顶部约束，默认-44即隐藏，0即显示

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化视图
    [self initUI];
    
    // 获取数据
    [self getDataFormServer];
}


#pragma mark - <************************** 获取数据 **************************>
// !!!: 获取数据
-(void)getDataFormServer{
    WeakObj(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.33 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.data removeAllObjects];
        [self.deleteDatas removeAllObjects];
        self.tableView.editing = YES;//模拟editing从yes到no
        [self navigationViewReghtDlegate];//模拟editing从yes到no
        
        //模拟数据
        for (int i = 0; i < 20; i ++) {
            CollectionModel *model = [CollectionModel new];
            [self.data addObject:model];
        }
        [self.tableView reloadData];

        weakself.navigationBar.reghtBtn.hidden = weakself.data.count == 0;
        [weakself.tableView reloadData];
    });
}


#pragma mark - <************************** 配置视图 **************************>
// !!!: 配置视图
-(void)initUI{
    //controller
    [self.navigationBar setTitle:@"我的收藏" leftBtnImage:@"zhiboLeft" rightBtnText:@"编辑"];
    self.navigationBar.reghtBtn.hidden = YES;
//    self.isNeedGoBack = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.originY.constant = self.navigationBar.frame.size.height;
    
    //table
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.separatorColor = [UIColor groupTableViewBackgroundColor];
}


#pragma mark - <*********************** 初始化控件/数据 **********************>
- (NSMutableArray *)data{
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}
- (NSMutableArray *)deleteDatas{
    if (!_deleteDatas) {
        _deleteDatas = [NSMutableArray array];
    }
    return _deleteDatas;
}
- (NavigationView *)navigationBar{
    if(!_navigationBar){
        _navigationBar = [NavigationView new];
        _navigationBar.backgroundColor = HexColor(0xff5a5a);
        _navigationBar.delegate = self;
            [self.view addSubview:_navigationBar];
        [_navigationBar  cwn_makeConstraints:^(UIView *maker) {
            maker.leftToSuper(0).rightToSuper(0).topToSuper(0).height(64);
        }];
        [self.view layoutIfNeeded];
    }
    return _navigationBar;
}


#pragma mark - <************************** 代理方法 **************************>
#pragma mark NavigationBarDelegate
// !!!: 返回
-(void)navigationViewLeftDlegate{
    [self.navigationController popViewControllerAnimated:YES];
}
// !!!: 编辑、退出编辑状态
- (void)navigationViewReghtDlegate{
    [self.tableView setEditing:!self.tableView.editing animated:NO];
    [self.navigationBar.reghtBtn setTitle:self.tableView.isEditing ? @"完成" : @"编辑" forState:UIControlStateNormal];
    
    //底部编辑视图显示隐藏
    self.editViewTop.constant = self.tableView.editing ? 0 : -44;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    //底部编辑视图状态
    [self setSeletionViewState:NO];
    
    if(self.tableView.editing == NO){
        [self.deleteDatas removeAllObjects];
    }
}

#pragma mark UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data. count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CollectionTableViewCell *cell = [CollectionTableViewCell cellFromXibWithTableView:tableView IndexPath:indexPath];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 125;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        // 多选
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }else{
        // 删除
        return UITableViewCellEditingStyleDelete;
    }
}

// !!!: 选中cell，跳转详情页或添加待删除项
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        CollectionModel *data = self.data[indexPath.row];
        if (![self.deleteDatas containsObject:data]) {
            [self.deleteDatas addObject:data];
        }
        
        [self setSeletionViewState:self.data.count == self.deleteDatas.count];
        return;
    }

    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"跳转详情页" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
}

// !!!: 取消选中cell，取消某列表项的删除
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.isEditing) {
        CollectionModel *data = self.data[indexPath.row];
        if ([self.deleteDatas containsObject:data]) {
            [self.deleteDatas removeObject:data];
        }

        [self setSeletionViewState: NO];
        return;
    }
}

#pragma mark - <************************** 点击事件 **************************>
// !!!: 底部删除菜单项点击事件(全选、删除按钮)
- (IBAction)onClickSelectViewBtn:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{// !!!: 全选按钮点击事件
            if(self.data.count == self.deleteDatas.count){//全选-未选
                [self.deleteDatas removeAllObjects];
                [self setSeletionViewState:NO];
            }else{//未选到全选
                [self.deleteDatas removeAllObjects];
                [self.deleteDatas addObjectsFromArray:self.data];
                [self setSeletionViewState:YES];
            }

            CGPoint offsety = _tableView.contentOffset;//记录列表初始内容位置
            for (int i = 0; i< self.data.count; i++) {//对所有cell进行选择、取消选择操作
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                self.data.count == self.deleteDatas.count ? [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop] : [_tableView deselectRowAtIndexPath:indexPath animated:NO];
            }
            [self.tableView setContentOffset:offsety];
        }
            break;
        case 1:{// !!!: 删除按钮点击事件
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定删除所选的收藏项(%ld项)?", self.deleteDatas.count] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"删除成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
                [self.data removeObjectsInArray:self.deleteDatas];
                [self.deleteDatas removeAllObjects];
                [self setSeletionViewState:NO];
            }];
            [vc addAction:cancel];
            [vc addAction:sure];
            [self presentViewController:vc animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - <************************** 私有方法 **************************>
// !!!: 底部删除菜单项(全选、删除按钮)状态修改
- (void)setSeletionViewState:(BOOL)selected{
    [self.selectAllBtn setTitle:selected ? @"取消全选" : @"全选" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:self.deleteDatas.count ? HexColor(0xff5a5a) : [UIColor lightGrayColor] forState:UIControlStateNormal];
    self.deleteBtn.userInteractionEnabled = self.deleteDatas.count;
}

@end
