//
//  KFC.m
//  RACDemo_2
//
//  Created by zkzk on 2018/8/13.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import "KFC.h"

@implementation KFC

+ (instancetype)kfcWithDict:(NSDictionary*)dict{
    
    KFC * kfc = [[KFC alloc] init];
    
    [kfc setValuesForKeysWithDictionary:dict];
    
    return kfc;
}

@end
