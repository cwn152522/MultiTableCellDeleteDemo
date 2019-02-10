//
//  ViewController.m
//  MultiTableCellDeleteDemo
//
//  Created by mac on 2019/2/10.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewController.h"
#import "Others/UIView+CWNView.m"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CollectionViewController *vc = [CollectionViewController new];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    
    [vc.view cwn_makeConstraints:^(UIView *maker) {
        maker.edgeInsetsToSuper(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
