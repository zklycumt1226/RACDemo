//
//  ViewController.m
//  RACDemo_2
//
//  Created by zkzk on 2018/8/7.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "HKView.h"
#import "KFC.h"

@interface ViewController ()
@property (nonatomic, strong) id<RACSubscriber> subscriber;

@property (nonatomic, strong) HKView *hkView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self constuctHKView];
    //[self signalTestFirst];
    //[self disposableTestFirst];
    //[self signalDisposableTestSec];
    
    [self RACArrayTest2];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //[self subjectTestAlone];
    //[self subJectTestSec];
}

- (void)RACArrayTest2{
    NSString* fileP = [[NSBundle mainBundle] pathForResource:@"kfc.plist" ofType:@""];
    NSArray* dictArr = [NSArray arrayWithContentsOfFile:fileP];
   
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        //NSLog(@"%@",x);
    }];
    
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        
    }];
    
    // 数组类 遍历  默认在子线程遍历
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        //NSLog(@"%@ , x is = %@",[NSThread currentThread],x);
    } error:^(NSError *error) {
        
    } completed:^{
        
    }];
    
    
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        NSDictionary* dic = (NSDictionary*)x;
        [dic.rac_sequence.signal subscribeNext:^(id x) {
            RACTupleUnpack(NSString* key,NSString* value) = x;
            NSLog(@"key %@ :  value %@",key, value);
        }];
    }];
    
    NSArray* arr = [[dictArr.rac_sequence map:^id(id value) {
        return [KFC kfcWithDict:value];
    }] array];
    NSLog(@"%@",arr);
}

- (void)RACArrayTest{
    NSString* fileP = [[NSBundle mainBundle] pathForResource:@"kfc.plist" ofType:@""];
    NSArray* dictArr = [NSArray arrayWithContentsOfFile:fileP];
    NSLog(@"dictArr = %@",dictArr);
    
    RACTuple* tuple = [RACTuple tupleWithObjectsFromArray:dictArr];
    
    for (int i = 0; i < tuple.count; ++i) {
        NSDictionary* dict = tuple[i];
        NSLog(@"%@",dict);
    }
    
}

- (void)constuctHKView{
    self.hkView = [[HKView alloc] init];
    self.hkView.frame = CGRectMake(100, 200, 200, 200);
    self.hkView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.hkView];
    __weak typeof(self)weakself = self;
    
    // 提前订阅好 这样代码就能全部放在一起，可读性更高，而且替换了代理，代码更易读
    [self.hkView.btnClickSignal subscribeNext:^(id x) {
        weakself.view.backgroundColor = (UIColor*)x;
    }];
}


- (void)subJectTestSec{
    RACSubject* subject = [RACSubject subject];
    [subject subscribeNext:^(id x) {
        NSLog(@"jisdou - %@",x);
    }];
    
    [subject sendNext:@"打算 "];
}

- (void)subjectTestAlone{
    // 创建一个单独的信号
    RACSubject* subject = [RACSubject subject];
    
    // 订阅信号 订阅必须在发送之前
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅信号  ---- %@",x);
    }];
    
    // 发送信号
    [subject sendNext:@"fasong----- "];
}


- (void)signalDisposableTestSec{
    
    __weak typeof(self)weakself = self;
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        weakself.subscriber = subscriber;
        [subscriber sendNext:@"TMD 什么鬼  由信号订阅者发送信号  "];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 取消发送 ---- ");
        }];
    }];
    
   RACDisposable* disposable = [signal subscribeNext:^(id x) {// 接收信号
        NSLog(@"接收到信号 ---- %@",x);
    }];
    
    // 取消某个信号   一般来说 一个信号发送完毕后就会主动取消订阅
    // 可是只要订阅者subscriber 在 就不会取消订阅
    // 需要手动取消订阅 清空资源
    [disposable dispose];
}

- (void)disposableTestFirst{
    __weak typeof(self)weakself = self;
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"fasong --- "];
        
        // 如果没有引用  subscriber 取消对应的打印没有过来
        weakself.subscriber = subscriber;
        return [RACDisposable disposableWithBlock:^{// 取消订阅会走这里 在这里清空资源
            NSLog(@"disposable ----  取消 ");
        }];
    }];
    
    // 点进去发现 订阅信号的时候 也返回了一个disposable 接收一下
    RACDisposable * disposable =[signal subscribeNext:^(id x) {
        NSLog(@"已经收到发送过来的信号 ---- %@",x);
    }];
    
    //信号可以被多次订阅
    [signal subscribeNext:^(id x) {
        NSLog(@"2222222222已经收到发送过来的信号 ---- %@",x);
    }];
    
    //默认情况下 当信号发送完毕 就会自动取消订阅
    // 不过 subscriber在 就不会自动取消 需要手动取消
    // 尝试一下取消
    [disposable dispose];
}

- (void)signalTestFirst{
    
    // 创建信号  信号是冷信号 一旦信号被订阅 就成了热信号

    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"前");
        
        [subscriber sendNext:@"随便发送信号 "];
        NSLog(@"后");
        return nil;
    }];
    
    // 信号被订阅  signal 成为热信号
    [signal subscribeNext:^(id x) {
        [NSThread sleepForTimeInterval:1];
        NSLog(@"接受到信号后处理  ----- %@",x);
    }];
}


@end
