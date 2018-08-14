//
//  BlueView.m
//  RACDemo_2
//
//  Created by zkzk on 2018/8/13.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import "BlueView.h"

@implementation BlueView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)ButtonClick:(id)sender {
    NSLog(@"%s", __FUNCTION__);
    
    [self laileCeshi:@"99999999"];
}

- (void)laileCeshi:(NSString*)tets{
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.frame = CGRectMake(50, 50, 200, 200);
}



@end
