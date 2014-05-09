//
//  DemoModel.m
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "DemoModel.h"
#import "NSObject+YRSerialization.h"

@implementation DemoModel
-(NSDictionary *)savePropertiesToDictionary{
    NSMutableDictionary *d=[super savePropertiesToDictionary];
    [d setObject:[NSNumber numberWithInt:_t.a] forKey:@"testt"];
    return d;
}
-(BOOL)restorePropertiesFromDictionary:(NSDictionary *)dictionary{
    [super restorePropertiesFromDictionary:dictionary];
    _t.a=[[dictionary objectForKey:@"testt"] intValue];
    return true;
}


//+(NSDictionary *)auxiliaryYRClassNameDictionary{
//    return @{@"demoSubModel2":@"DemoSubModel"};
//}
@end
