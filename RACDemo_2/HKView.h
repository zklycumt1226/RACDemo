//
//  HKView.h
//  RACDemo_2
//
//  Created by zkzk on 2018/8/9.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface HKView : UIView

// 按钮点击对应的信号
@property (nonatomic, strong) RACSubject *btnClickSignal;

@end
