//
//  DemoModel.m
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "DemoModel.h"
#import "NSObject+YRSerializationCategory.h"

@implementation DemoModel
-(NSDictionary *)savePropertiesToDictionary{
    NSMutableDictionary *d=[super savePropertiesToDictionary];
    [d setObject:_t.b forKey:@"testt"];
    return d;
}
-(BOOL)restorePropertiesFromDictionary:(NSDictionary *)dictionary{
    [super restorePropertiesFromDictionary:dictionary];
    _t.b=[dictionary objectForKey:@"testt"];
    return true;
}


//+(NSDictionary *)auxiliaryYRClassNameDictionary{
//    return @{@"demoSubModel2":@"DemoSubModel"};
//}
@end
