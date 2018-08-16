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

//    [self RACTimer];
    
    //[self ARC_hong];
    //[self subscribTheSameSignalManyTime];
    
    //[self RACCommand];
    //[self RAC_MAP_DEMO];
    
    //[self concatzuhe];
    //[self thenZuhe];
    
    //[self mergeZuhe];
    //[self zipZuhe];
    //[self filterGuolv];
    //[self ignoreGuoLv];
    //[self takeGuolV];
   // [self takeLastGuolV];
    //[self takeUntileGuolV];
    //[self distinGuolV];
    
    [self skipGuoLv];
}

// 跳过前几个信号
- (void)skipGuoLv{
    RACSubject* subject = [RACSubject subject];
    
    // skip 跳过前面2个信号 接受后面的信号
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];// 数据被忽略
    [subject sendNext:@"2"];// 数据被忽略
    [subject sendNext:@"3"];// 数据被拿到
}

// 忽略重复信号
- (void)distinGuolV{
    
    RACSubject* subject = [RACSubject subject];
    
    // 忽略重复数据 当收到的数据是重复数据时，就会忽略后来收到的
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"接收到信号 = %@",x);
    }];
    
    [subject sendNext:@"1"];// 数据被拿到
    [subject sendNext:@"1"];// 数据被忽略
    
    [subject sendNext:@"2"];// 数据被拿到
    [subject sendNext:@"2"];// 数据被忽略
}

- (void)takeUntileGuolV{
    
    RACSubject* subject = [RACSubject subject];
    RACSubject* signal = [RACSubject subject];
    
    // takeUntil 调用后，如果subject 有发送多个信号，只会调用到在signal之前的所有信号
    [[subject takeUntil:signal] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];// 数据被拿到
    [subject sendNext:@"3"];// 数据被拿到
    
    [signal sendNext:@"-----标记"];// 这是标记，调用标记的signal后 后面的信号就不会被处理
    //[signal sendCompleted]; // 和发送信号有同样的功效 后面的方法也就不会被处理
    [subject sendNext:@"2"];//数据被忽略
    [subject sendCompleted];
}

- (void)takeLastGuolV{
    
    RACSubject* subject = [RACSubject subject];
    // 指定从后往前拿去几条数据 注意信号发送完成后必须执行sendCompleted方法
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"接受到数据 = %@",x);
    }];
    
    [subject sendNext:@"1"];// 数据被忽略
    [subject sendNext:@"3"];// 数据被拿到
    [subject sendNext:@"2"];// 数据被拿到
    [subject sendCompleted];
}

- (void)takeGuolV{
    
    RACSubject* subject = [RACSubject subject];
    // 指定从前面拿几条数据
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"接受到数据 = %@",x);
    }];
    
    [subject sendNext:@"1"];// 数据被拿到
    [subject sendNext:@"3"];// 数据被拿到
    [subject sendNext:@"2"];// 数据被忽略
    
}

// 忽略
- (void)ignoreGuoLv{
    RACSubject* subject = [RACSubject subject];
    
    // 可以使用ignore 连续忽略多个信号的值，只针对值进行忽略
    RACSignal* ignoreSignal = [[[subject ignore:@"1"] ignore:@"3"] ignore:@"18"];
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"收到信号 ---- %@",x);
    }];
    
    [subject sendNext:@"1"];// 信号被忽略
    [subject sendNext:@"3"];// 信号被忽略
    [subject sendNext:@"18"];// 信号被忽略
    [subject sendNext:@"12"];// 该信号会被处理
}

// 过滤
- (void)filterGuolv{
    // 1、filter 返回一个信号， 之后直接订阅该信号。
    [[_textField.rac_textSignal filter:^BOOL(id value) {
        //2、value 为_textField.rac_textSignal信号对应传递的值
        //3、block内部有返回值，当返回值为NO，filter返回的信号就不能被订阅，这样4中的代码就不能被执行
        // 只有返回YES 时，才会执行4 中的代码
        // 这样就可以对value进行过滤 达到某个条件时才执行4中的代码。
        return [value length] > 4;
    }] subscribeNext:^(id x) {
        //4
        NSLog(@"x is  = %@",x);
    }] ;
}

- (void)zipZuhe{
    RACSubject* subjectA = [RACSubject subject];
    RACSubject* subjectB = [RACSubject subject];
    
    // 使用信号压缩组合，将两个信号压缩成一个信号。并且只有两个信号都发送一次数据才会执行组合后信号对应的订阅
    // 信号接收顺序和发送数据顺序无关，只和订阅顺序有关
    RACSignal* zipSignal = [subjectA zipWith:subjectB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"收到数据 = %@",x);
    }];
    
    // 注意 只有发送一次A 同时发送一次B 才会调用zipSignal的订阅信息
    [subjectA sendNext:@"组合数据A"];
    [subjectB sendNext:@"组合数据B"];
    
    [subjectA sendNext:@"组合数据A"];
    [subjectB sendNext:@"组合数据B"];
    
    [subjectA sendNext:@"组合数据A"];
    [subjectB sendNext:@"组合数据B"];
}

- (void)mergeZuhe{
    
    // merge 组合 处理数据的顺序和组合信号的顺序没有关系，那个信号的数据先发送，就先出里那个
    RACSubject* signalA = [RACSubject subject];
    RACSubject* signalB = [RACSubject subject];
    RACSubject* signalC = [RACSubject subject];
    
    RACSignal* mergeSignal = [RACSignal merge:@[signalA,signalB,signalC]];
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"收到信号%@",x);
    }];
    
    [signalB sendNext:@"B数据"];
    [signalA sendNext:@"A数据"];
    [signalC sendNext:@"C数据"];
}

- (void)thenZuhe{
    RACSignal* signalA= [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"信号A");
        
        [subscriber sendNext:@"发送数据A"];
        
        // 注意需要调用发送完成的方法
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal* signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"信号B");
        [subscriber sendNext:@"发送数据B"];
        return nil;
    }];
    
   RACSignal* thenSignal = [signalA then:^RACSignal *{
        return signalB;
    }];
    
    // then 组合的目的就是忽略信号A的数据 使用信号B的数据，不过必须在信号A发送完成之后 才能走到信号B ，所以信号A必须调用sendCompleted
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"收到数据 %@",x);
    }];
}

// 组合
- (void)concatzuhe{
    
    RACSignal* signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"A信号");
        [subscriber sendNext:@"发送信号A"];
        // 所以A信号发送结束后，需要调用 完成方法
        // 代表发送结束，这样才会调用信号B 发送的方法
        [subscriber sendCompleted];
        
        // 如果调用sendError方法 那不会调用信号B的发送
        //[subscriber sendError:nil];
        return nil;
    }];
    
    RACSignal* signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"B信号");
        [subscriber sendNext:@"发送信号B"];
        return nil;
    }];
    
    // 将A信号 和B 信号组合，这样只有当A信号成功发送结束后，才能发送B信号
   RACSignal* signalConcat = [signalA concat:signalB];
    
    [signalConcat subscribeNext:^(id x) {
        NSLog(@"谁的信号= %@",x);
    }];
    
    // 当有7、8个信号时，刚刚的方式就比较麻烦了。  如果有方法能够直接添加数组就好了
    //[RACSignal concat:@[signalC,signalD,signalE]]; 这种方式正好解决。
    RACSignal* signalC = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"C信号");
        [subscriber sendNext:@"发送信号C"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal* signalD = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"D信号");
        [subscriber sendNext:@"发送信号D"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal* signalE = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"E信号");
        [subscriber sendNext:@"发送信号E"];
        return nil;
    }];
    
   RACSignal* signal = [RACSignal concat:@[signalC,signalD,signalE]];
    [signal subscribeNext:^(id x) {
        NSLog( @"谁的信号 ----- %@",x);
    }];
}


- (void)RAC_MAP_DEMO{
    // 1、正常流程
    RACSubject* subject = [RACSubject subject];

    [subject subscribeNext:^(id x) {
        NSLog(@"收到信号 --- %@",x);
    }];

    [subject sendNext:@"123"];

    RACSubject* subject2 = [RACSubject subject];
    
    // 2、map返回一个信号，map内部对初次发送过来的信号进行处理。
    // 下面这段代码就是映射
    [[subject2 map:^id(id value) {
        //返回一个id类型的对象
        return [NSString stringWithFormat:@"处理后的数据 %@",value];
    }] subscribeNext:^(id x) {
        //通过上面对接受到的数据进行处理，处理完成后再通过订阅使用处理完成之后的数据。
        NSLog(@"接收处理之后的数据 ---- %@",x);
    }];
    
    [subject2 sendNext:@"345"];
    
    // 3、a信号中发送一个信号
    RACSubject* signalOfSignal = [RACSubject subject];
    RACSubject* signal = [RACSubject subject];
    
    [signalOfSignal subscribeNext:^(RACSignal* x) {
        
        [x subscribeNext:^(id x) {
            NSLog(@"x is %@",x); //输出x是123
        }];
        
    }];
    
    //b 或则通过属性切换到最新的
    [signalOfSignal.switchToLatest subscribeNext:^(id x) {
        NSLog(@"x is %@",x); //输出x是123
    }];
    
    // c 使用flattenMap 处理信号中的信号
    // 或者通过一个新的方式 flattenMap  value是一个信号，flattenMap需要返回一个信号，所以有下面的代码
    [[signalOfSignal flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"x is %@",x); //输出x是123
    }] ;
    
    [signalOfSignal sendNext:signal];
    [signal sendNext:@"123"];
}

//映射

//bind
- (void)BindFunc{
    RACSubject* subject = [RACSubject subject];
    [subject bind:^RACStreamBindBlock{
        
        return ^RACStream *(id value, BOOL *stop){
            return [RACSignal empty];
        };
       
    }];
}

// 监控命令是否正在执行
- (void)RACCommandExecuting{
    RACCommand* command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"%@",input);// 这里就是输入的指令
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行完命令后产生的数据"];
            [subscriber sendCompleted];// 需要调用发送结束的方法 才能在调用结束后执行executing中结束的方法（命令已经结束）
            return nil;
        }];
    }];
    
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue]) {
            NSLog(@"命令正在执行");
        } else {
            NSLog(@"命令已经结束&&或者还没有开始");
        }
    }];
    RACSignal* signal = [command execute:@"输入指令"];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);// 这里是执行完命令后产生的数据
    }];
}

// RACCommand信号源 switch
- (void)RACCommandExecutionSignalSwitchSignal{
    RACCommand* command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行完命令后产生的数据"];
            return nil;
        }];
    }];
    
    //executionSignals 信号源，即信号中的信号 而不用调用execute 返回信号后才订阅
    // 根据上面的代码可知，x是一个信号(打印一下也知道),可以直接订阅
    //switchToLatest 代表信号源中 最新的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);// 拿到的X 是执行命令之后产生的数据
    }];
    
    // 执行命令
    [command execute:@"执行---"];
}


// RACCommand信号源
- (void)RACCommandExecutionSignal{
    RACCommand* command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行完命令后产生的数据"];
            return nil;
        }];
    }];
    
    //executionSignals 信号源，即信号中的信号 而不用调用execute 返回信号后才订阅
    // 根据上面的代码可知，x是一个信号(打印一下也知道),可以直接订阅
    [command.executionSignals subscribeNext:^(RACSignal* x) {
        [x subscribeNext:^(id x) {
            NSLog(@"接受到的信号 ---- %@",x);
        }];
    }];
    
    // 执行命令
    [command execute:@"执行---"];
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
