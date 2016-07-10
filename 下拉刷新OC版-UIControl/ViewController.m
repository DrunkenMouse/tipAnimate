//
//  ViewController.m
//  下拉刷新OC版-UIControl
//
//  Created by 王奥东 on 16/7/10.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "RefreshControl.h"
#import "ViewController.h"

@interface ViewController ()
//保存自定义的ref
@property(nonatomic,strong)RefreshControl *ref;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    RefreshControl *ref = [[RefreshControl alloc]init];
    ref.backgroundColor = [UIColor purpleColor];
    self.ref = ref;
    
    [self.tableView addSubview:ref];
    //给tip动画添加一个事件监听，通过此来完成数据请求等操作
    [ref addTarget:self action:@selector(pullDownRefresh) forControlEvents:UIControlEventValueChanged];
    
    
}

-(void)pullDownRefresh{
    
    //模拟请求结束后关闭下拉刷新tip动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.ref endRefreshing];
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
