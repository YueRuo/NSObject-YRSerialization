//
//  DemoModel.h
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoSubModel.h"

@interface DemoModel : NSObject
@property (assign,nonatomic) int demoInt;
@property (retain,nonatomic) NSString *demoString;
@property (retain,nonatomic) NSArray *demoArray;
@property (retain,nonatomic) NSDictionary *demoDictionary;
@property (retain,nonatomic) DemoSubModel *demoSubModel;//another class

@property (retain,nonatomic) id demoSubModel2;//another class with id property
@end
