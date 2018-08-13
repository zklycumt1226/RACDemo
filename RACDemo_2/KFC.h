//
//  KFC.h
//  RACDemo_2
//
//  Created by zkzk on 2018/8/13.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFC : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *icon;

+ (instancetype)kfcWithDict:(NSDictionary*)dict;

@end
