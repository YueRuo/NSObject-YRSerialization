//
//  DemoSubModel.h
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+YRSerializationCategory.h"

@interface DemoSubModel : NSObject
@property (retain,nonatomic) NSString *demoSubString;
@property (retain,nonatomic) NSData *data;
@property (retain,nonatomic) NSDate *date;
@property (assign,nonatomic) char m;
//@property (assign,nonatomic) char *s;
@end
