//
//  HKView.m
//  RACDemo_2
//
//  Created by zkzk on 2018/8/9.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import "HKView.h"



@implementation HKView

- (RACSubject *)btnClickSignal{
    if (_btnClickSignal == nil) {
        _btnClickSignal = [[RACSubject alloc] init];
    }
    return _btnClickSignal;
}

- (instancetype)init{
    if (self = [super init]) {
         UIButton* btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(50, 50, 80, 60);
        [btn setTitle:@"点击发送" forState:UIControlStateNormal];
        [btn setTintColor:[UIColor redColor]];
        [btn addTarget:self action:@selector(BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}

- (void)BtnClick:(UIButton*)btn{
    [self.btnClickSignal sendNext:[UIColor blueColor]];
}

@end
