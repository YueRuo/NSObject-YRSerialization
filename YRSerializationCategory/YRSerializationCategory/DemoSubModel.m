//
//  DemoSubModel.m
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "DemoSubModel.h"

@implementation DemoSubModel

//-(NSDictionary *)propertyKeysToSaveKeys{//change the save key
//    return @{@"demoSubString":@"subs",@"f":@"rect",@"date":@"de"};
//}
+(NSDictionary *)auxiliaryYRClassNameDictionary{
    return @{@"date":@"NSDate"};
}
@end
