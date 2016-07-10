//
//  RefreshControl.m
//  下拉刷新OC版-UIControl
//
//  Created by 王奥东 on 16/7/10.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "RefreshControl.h"
#import "Masonry.h"
#import "UIView+Extension.h"

typedef enum : NSUInteger{
   //下拉刷新
    Noraml,
    //松手就刷新
    Pulling,
    //正在刷新
    Refreshing
    
}RefreshState;
//当前控件的高度
CGFloat RefreshControlH = 50;

@interface RefreshControl()
//刷新状态，通过枚举值来控制
@property(nonatomic,assign)RefreshState refreshState;
//刷新时的箭头，此Demo中为空
@property(nonatomic,strong)UIImageView * iconView;
//菊花转
@property(nonatomic,strong)UIActivityIndicatorView * indicatorView;
//显示的信息
@property(nonatomic,strong)UILabel * messageLabel;
//保存父控件
@property(nonatomic,strong)UIScrollView * currentScrollView;
//保存上一次refresh的状态
@property(nonatomic,assign)RefreshState oldValue;

@end

@implementation RefreshControl
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
         [self setupUI];
    }
    return self;
}

-(void)setupUI{
    
    //对控件的初始化
//    self.iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"天空-栏杆"]];
    self.iconView = [[UIImageView alloc]init];
    
    self.refreshState = Noraml;
    
    self.messageLabel = [[UILabel alloc]init];
    self.messageLabel.textColor = [UIColor redColor];
    self.messageLabel.font = [UIFont systemFontOfSize:12];
    
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    
    [self addSubview:self.iconView];
    [self addSubview:self.messageLabel];
    [self addSubview:self.indicatorView];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-35);
        make.centerY.equalTo(self);
    }];
    
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconView);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.iconView.mas_trailing);
        make.centerY.equalTo(self);
    }];
    
}

//当添加到父类控件时会调用此方法
-(void)willMoveToSuperview:(UIView *)newSuperview{

    UIScrollView *scroll = (UIScrollView *)newSuperview;
    if (scroll != nil) {
        //设置自己的frame
        self.size = CGSizeMake(scroll.frame.size.width, RefreshControlH);
        self.y = -RefreshControlH;
        //监听父控件的事件
        [scroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        //记录添加的滚动视图
        self.currentScrollView = scroll;
        
    }
}

-(void)endRefreshing{
    
        
        self.refreshState = Noraml;
}

//移除通知
-(void)dealloc{
    
    [self.currentScrollView removeObserver:self forKeyPath:@"contentOffset"];
    
}

//KVO的监听方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    //监听的就是可以滚动的视图，如果获取可以使用全局变量记录
//    NSLog(@"%f",self.currentScrollView.contentOffset.y);
    //  接下来的操作判断状态
    if ([self.currentScrollView isDragging]) {
        //注意，临界点是负值，偏移量也是负值
        //所以数越少，代表滑动的范围越大
        //临界点
        CGFloat maxY = -(self.currentScrollView.contentInset.top + RefreshControlH);
        //偏移量
        CGFloat contentOffSetY = self.currentScrollView.contentOffset.y;
         //  如果当前的偏移量小于临界点则是pulling状态
        //也就是此时的状态是滑动超过需要滑动的范围才会小于临界点
        if (contentOffSetY < maxY && self.refreshState == Noraml){
            self.refreshState = Pulling;
            self.oldValue = self.refreshState;
        }
        //如果大于等于临界点，则是滑动的范围还没达到需要滑动的范围
        else if (contentOffSetY >= maxY && self.refreshState == Pulling) {
            
            self.refreshState = Noraml;
            self.oldValue = self.refreshState;
        }
    }
    else{
        //  判断上一次是pulling状态在进入刷新状态
        if (self.refreshState == Pulling) {
            //负值oldValue时不能通过self.refreshState
            //否则State复制完毕后会通过set内部的方法是自身变成Normal状态
            //所以要通过手动设置
            self.oldValue = Refreshing;
            self.refreshState = Refreshing;
           
        }
    }
    
}

-(void)setRefreshState:(RefreshState)refreshState{
   
    _refreshState = refreshState;
    
    switch (refreshState) {
            
    //  显示下拉刷新文本，停止菊花转，按钮重置动画
        case Noraml:{
            NSLog(@"%lu",(unsigned long)self.oldValue);
            self.iconView.hidden = NO;
            self.messageLabel.text = nil;
            self.messageLabel.text = @"下拉刷新";
            [self.indicatorView stopAnimating];
            [UIView animateWithDuration:0.25 animations:^{
                //重置箭头
                self.iconView.transform = CGAffineTransformIdentity;
            }];
             //  判断上一次是刷新状态，设置为原始的contentInset
            if (self.oldValue == Refreshing) {
                [UIView animateWithDuration:2 animations:^{
                    self.currentScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }];
            }
            break;
        }
         
            //显示松手就刷新文本，箭头调转
        case Pulling:{
            
            self.messageLabel.text = nil;
            self.messageLabel.text = @"松手就刷新";
            [UIView animateWithDuration:0.24 animations:^{
                self.iconView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
            break;

        }
            
        case Refreshing:{
            self.messageLabel.text = nil;
            //显示正在刷新文本，菊花转起来，下拉箭头隐藏
            self.messageLabel.text = @"正在刷新";
            self.iconView.hidden = YES;
            [self.indicatorView startAnimating];
           //改变此时的显示位置
            self.currentScrollView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
           
            //给父类发送事件
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
            
        default:
            break;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}














@end
