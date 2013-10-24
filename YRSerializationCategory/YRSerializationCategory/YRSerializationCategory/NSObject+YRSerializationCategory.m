//
//  NSObject+YRSerializationCategory.m
//  YRSnippets
//
//  Created by 王晓宇 on 13-8-26.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "NSObject+YRSerializationCategory.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#define YRRelease(__v) ([__v release]);
#else
#define YRRelease(__v)
#endif
@implementation NSObject (YRSerializationCategory)

-(NSArray*)propertyKeys{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    NSMutableArray *propertyKeys = [NSMutableArray arrayWithCapacity:outCount];
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [propertyKeys addObject:propertyName];
        YRRelease(propertyName);
    }
    free(properties);
    Class superClass=class_getSuperclass([self class]);
    if (superClass != [NSObject class]) {
        NSArray *superPropertyKeys=[superClass propertyKeys];
        if (superPropertyKeys&&[superPropertyKeys count]>0) {
            [propertyKeys addObjectsFromArray:superPropertyKeys];
        }
    }
    return propertyKeys;
}

-(NSDictionary*)savePropertiesToDictionary{
    if ([self isKindOfClass:[NSDictionary class]]||[self isKindOfClass:[NSArray class]]||[self isKindOfClass:[NSValue class]]||[self isKindOfClass:[NSString class]]||[self isKindOfClass:[NSSet class]]) {
//        NSLog(@"warning : the class %@ can not use this method !please check and use your custom class",[self class]);
        return nil;
    }
    NSArray *propertyKeys=[self propertyKeys];
    if ([propertyKeys count]==0) {
        return nil;
    }
    NSMutableDictionary *dictionary=[NSMutableDictionary dictionaryWithCapacity:[propertyKeys count]];
    for (NSString *key in propertyKeys) {
        id propertyValue = [self valueForKey:key];
        if (propertyValue&&![propertyValue isKindOfClass:[NSNull class]]) {
            if ([propertyValue isKindOfClass:[NSArray class]]) {//if an array，check it
                NSMutableArray *subPropertyArray=[NSMutableArray arrayWithCapacity:[propertyValue count]];
                for (id obj in propertyValue) {
                    if ([obj class]==[self class]) {//pass the loop property
                        continue;
                    }
                    id subPropertyArrayObj=[obj savePropertiesToDictionary];
                    if (subPropertyArrayObj) {
                        [subPropertyArrayObj setObject:NSStringFromClass([obj class]) forKey:@"__yrname"];
                        [subPropertyArray addObject:subPropertyArrayObj];
                    }else{
                        [subPropertyArray addObject:obj];
                    }
                }
                [dictionary setObject:subPropertyArray forKey:key];
            }else{
                id obj=[propertyValue savePropertiesToDictionary];
                if (obj) {
                    [dictionary setObject:obj forKey:key];
                }else{
                    [dictionary setObject:propertyValue forKey:key];
                }
            }
        }
    }
    return dictionary;
}
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary{
    if (!dictionary||![dictionary isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    return [self restorePropertiesFromDictionary:dictionary class:[self class]];
}
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary class:(Class)class{
    BOOL ret = false;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            ret = ([dictionary valueForKey:propertyName]==nil)?false:true;
        }else{
            ret = [dictionary respondsToSelector:NSSelectorFromString(propertyName)];
        }
        if (ret) {
            id propertyValue = [dictionary valueForKey:propertyName];
            if (propertyValue&&![propertyValue isKindOfClass:[NSNull class]]) {
                BOOL isSetDone=false;
                if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                    NSString *propertyAttributes=[NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
                    NSArray *tempArray=[propertyAttributes componentsSeparatedByString:@"\""];
                    if ([tempArray count]>1) {
                        NSString *className=[tempArray objectAtIndex:1];
                        if ([propertyAttributes rangeOfString:@"ictionary"].length==0) {//not a dictionary
                            id subPropertyObj=[[NSClassFromString(className) alloc]init];
                            [subPropertyObj restorePropertiesFromDictionary:propertyValue];
                            [self setValue:subPropertyObj forKey:propertyName];
                            YRRelease(subPropertyObj);
                            isSetDone=true;
                        }
                    }
                }else if([propertyValue isKindOfClass:[NSArray class]]){
                    NSArray *subPropertyArray=[self supPropertyRestoreFromArray:propertyValue];
                    [self setValue:subPropertyArray forKey:propertyName];
                    isSetDone=true;
                }
                if (!isSetDone) {
                    [self setValue:propertyValue forKey:propertyName];
                }
            }
        }
        YRRelease(propertyName);
    }
    free(properties);
    
    Class superClass=class_getSuperclass(class);
    if (superClass != [NSObject class]) {
        [self restorePropertiesFromDictionary:dictionary class:superClass];
    }
    return ret;
}


-(NSArray*)supPropertyRestoreFromArray:(NSArray*)propertyValue{
    NSMutableArray *subPropertyArray=[NSMutableArray arrayWithCapacity:[propertyValue count]];
    for (id obj in propertyValue) {
        BOOL isSubPropertySetDone=false;
        if ([obj isKindOfClass:[NSDictionary class]]) {//if it contains dictionary
            NSString *subClassName=[obj objectForKey:@"__yrname"];
            if (subClassName) {
                id subPropertyObj=[[NSClassFromString(subClassName) alloc]init];
                [subPropertyObj restorePropertiesFromDictionary:obj];
                [subPropertyArray addObject:subPropertyObj];
                YRRelease(subPropertyObj);
                isSubPropertySetDone=true;
            }
        }else if ([obj isKindOfClass:[NSArray class]]){
            NSArray *nextSubPropertyArrayObj=[self supPropertyRestoreFromArray:obj];
            [subPropertyArray addObject:nextSubPropertyArrayObj];
            isSubPropertySetDone=true;
        }
        if (!isSubPropertySetDone) {
            [subPropertyArray addObject:obj];
        }
    }
    return subPropertyArray;
}

-(id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"-->>try to get undefinekey %@ from %@",key,self);
    return nil;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"-->>try to set undefinekey %@ value %@ to %@",key,value,self);
}

@end
