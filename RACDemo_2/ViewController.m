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
#import "BlueView.h"
#import <ReactiveCocoa/RACEXTScope.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, strong) id<RACSubscriber> subscriber;

@property (weak, nonatomic) IBOutlet BlueView *blueView;

@property (weak, nonatomic) IBOutlet UILabel *lable;


@property (nonatomic, strong) RACDisposable* disposable;

@property (nonatomic, strong) HKView *hkView;
@property (nonatomic, strong) UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self constuctHKView];
    //[self signalTestFirst];
    //[self disposableTestFirst];
    //[self signalDisposableTestSec];
    
    //[self RACArrayTest2];
//    [self BlueButtonClick];
//
//    [self RACTimer];
    
    //[self ARC_hong];
    //[self subscribTheSameSignalManyTime];
    
    [self RACCommand];
}

//bind
- (void)BindFunc{
    RACSubject* subject = [RACSubject subject];
    [subject bind:^RACStreamBindBlock{
        
        return ^RACStream *(id value, BOOL *stop){
            return [RACSignal empty];
        };
       
    }];
}

- (void)RACCommand{
    RACCommand* command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@",input);// 这里就是输入的指令
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行完命令后产生的数据"];
            return nil;
        }];
    }];
    
    RACSignal* signal = [command execute:@"输入指令"];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);// 这里是执行完命令后产生的数据
    }];
}

// 多次订阅同一个信号
- (void)subscribTheSameSignalManyTime{
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求 创建信号中的block");
        [subscriber sendNext:@"发送"];
        return nil;
    }];
    
    // 每订阅一次 就会发送一个数据
    [signal subscribeNext:^(id x) {
        NSLog(@"A在处理数据");
    }];
    
    // 再次订阅 又会重新发发送数据 这样 如果对同一个信号多次订阅，就会导致创建信号中的block会被多次调用
    [signal subscribeNext:^(id x) {
        NSLog(@"B在处理数据");
    }];
    
    
    //RACMulticastConnection 连接类，用于当一个信号被多次订阅的时候，避免多次调用创建信号中的block
    
    //不管订阅多少次信号，只会请求一次数据
    // 将信号转成连接类
   RACMulticastConnection* multiCastConnet = [signal publish];
    [multiCastConnet.signal subscribeNext:^(id x) {
        NSLog(@"A 处理数据%@",x);
    }];
    
    [multiCastConnet.signal subscribeNext:^(id x) {
        NSLog(@"B 处理数据 = %@",x);
    }];
    
    //通过连接类 建立连接 这样就多次订阅 却只会发送一次请求
    [multiCastConnet connect];
}

//RAC 的宏
- (void)ARC_hong{
    // 1、给某个对象的某个属性 绑定信号,一旦信号产生数据，就会将内容赋值给属性
    // 所以 _textField.rac_textSignal 文本对应的信号 会发送给text 属性
    RAC(_lable,text) = _textField.rac_textSignal;
    
    //2、监听某个对象的某个属性  RACObserve(self.view, frame) 返回一个信号 然后订阅
    [RACObserve(self.lable, text) subscribeNext:^(id x) {
        NSLog(@"text is = %@",x);
    }];

    //3、弱引用  #import <ReactiveCocoa/RACEXTScope.h>
    @weakify(self);
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        NSLog(@"%@",self);
        return nil;
    }];
    
    //4、打包元祖 解包元祖
    RACTuple* tuple = RACTuplePack(@1,@2);
    NSLog(@"%@",tuple[0]);
    
    //解包装
    //RACTupleUnpack(<#...#>)
}

// 多任务结束后 调用某方法
- (void)RAC_LiftSelector{
    
    // RAC信号创建
    RACSignal* signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"网络数据请求1");
        [subscriber sendNext:@"网络数据1 来了"];
        return nil;
    }];
    
    RACSignal* signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSLog(@"网络数据请求 2 ");
        [subscriber sendNext:@"网络数据2 来了"];
        return nil;
    }];
    
    //一次行订阅所有信号 只有等所有信号全部发送回来后 才会调用updateOneData:TwoData: 方法
    // 并且注意参数必须和信号一一对应
    [self rac_liftSelector:@selector(updateOneData:TwoData:)withSignalsFromArray:@[signal1,signal2]];
}

- (void)updateOneData:(NSString*)oneData TwoData:(NSString*)twoData{
    //拿到数据进行更新
}

//RAC 定时器
- (void)RACTimer{
    //RAC 定时器的使用
    // 创建RAC 定时器
    //[RACScheduler scheduler] 其实就是全景队列 在子线程中执行block
    //[RACScheduler mainThreadScheduler] 其实就是主队列 在主线程中执行block
    // 可以使用返回的RACDisposable 取消订阅
   RACDisposable* disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler scheduler]] subscribeNext:^(id x) {
        NSLog(@"%@",[NSThread currentThread]);
    }];
    
    _disposable = disposable;
    
    // 取消订阅
    [_disposable dispose];
}

- (void)BlueButtonClick{
    // 1 代替事 件
    // 首先获取到blueView 的rac信号  然后订阅该信号
    // 此时的x 就是button
    // 当然也可以使用使用别的函数 进行传递值
    [[_blueView rac_signalForSelector:@selector(ButtonClick:)] subscribeNext:^(id x) {
        NSLog(@"订阅了 blueview 中的ButtonClick信号,而且信号参数 %@",x);
    }];
    
    // 方法可以不用再.h文件中定义 直接订阅就行
    // 使用原组进行包装
    [[_blueView rac_signalForSelector:@selector(laileCeshi:)] subscribeNext:^(id x) {
        NSLog(@"---------%@",x[0]);
    }];
 
    //RAC KVO
    //2.代替KVO
    //[_blueView rac_valuesForKeyPath:@"frame" observer:nil] 是创建信号
    // x 是实时变化的值
    [[_blueView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id x) {
        NSLog(@"修改了x %@",x);
    } error:^(NSError *error) {
        
    } completed:^{
        
    }];
    
    //3. 监听事件
    // 首先根据btn 创建一个upInside 的信号，然后订阅该信号 x是对应的按钮
    [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
    }];
    
    //4. 代替通知
    // 使用rac 创建一个需要订阅类型的信号， 然后订阅该信号 此处x 是NSNotification
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        //NSLog(@"x is = %@",x);
    }];
    
    //5. 监听文本框输入
    [[_textField rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        NSLog(@"value change %@",x);
    }];
    
    // 监听文本框文字内容的改变
    [_textField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"x = %@",x);
    }];
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
    
    // 1、创建信号
    RACSignal* signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        weakself.subscriber = subscriber;
        
        //3、 发送信号
        [subscriber sendNext:@"TMD 什么鬼  由信号订阅者发送信号  "];
        
        //5.如果有信号取消时调用
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号 取消发送 ---- ");
        }];
    }];
    
    //2、 订阅信号
   RACDisposable* disposable = [signal subscribeNext:^(id x) {// 接收信号
        NSLog(@"接收到信号 ---- %@",x);
    }];
    
    //4、信号取消
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
