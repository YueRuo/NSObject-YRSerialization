/*
 The MIT License (MIT)
 
 Copyright (c) 2014 YueRuo,王晓宇
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "NSObject+YRSerializationCategory.h"
#import <objc/runtime.h>

#if ! __has_feature(objc_arc)
#define YRRelease(__v) ([__v release]);
#else
#define YRRelease(__v)
#endif

#define YRSerializationClassNamekey @"__yrcn"
#define YRSerializationStructNamekey @"__yrsn"
#define YRSerializationStructValuekey @"__yrsv"
#define YRSerializationDateNamekey @"__yrde"
#define YRSerializationNSCodingKey  @"coder"

static char *assoKeyProperty="__yrakp";

@implementation NSObject (YRSerializationCategory)


+(BOOL)supportYRSerialization{
    return true;
}
+(NSDictionary*)auxiliaryYRClassNameDictionary{
    return nil;
}

-(NSArray*)propertyKeys{
    NSArray *propertyKeysC = objc_getAssociatedObject([self class], assoKeyProperty);
    if (!propertyKeysC) {
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
        propertyKeysC=[NSArray arrayWithArray:propertyKeys];
        objc_setAssociatedObject([self class], assoKeyProperty, propertyKeysC, OBJC_ASSOCIATION_RETAIN);
    }
    return propertyKeysC;
}
-(NSMutableDictionary*)savePropertiesToDictionary{
    if ([self isKindOfClass:[NSDictionary class]]||[self isKindOfClass:[NSArray class]]||[self isKindOfClass:[NSValue class]]||[self isKindOfClass:[NSString class]]||[self isKindOfClass:[NSSet class]]||[self isKindOfClass:[NSDate class]]||[self isKindOfClass:[NSData class]]) {
        NSLog(@"warning : the class %@ can not use this method !please check and use your custom class",[self class]);
        return nil;
    }
    return [self objectToSafeSave:self];
}
-(NSMutableDictionary*)savePropertiesWithoutAuxiliaryClassName{
    NSMutableDictionary *dictionary=[self savePropertiesToDictionary];
    [dictionary removeAllAuxiliaryYRClassName];
    return dictionary;
}
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary{
    if (!dictionary||![dictionary isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    return [self restorePropertiesFromDictionary:dictionary class:[self class]];
}
-(NSDictionary *)propertyKeysToSaveKeys{
    return nil;//default return nil
}



#pragma NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder{
    id result= [self savePropertiesToDictionary];
    if (!result) {
        result=[self objectToSafeSave:self];
    }
    if (result) {
        [aCoder encodeObject:result forKey:YRSerializationNSCodingKey];
    }
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    id object=[aDecoder decodeObjectForKey:YRSerializationNSCodingKey];
    [self restorePropertiesFromDictionary:object];
//    [self restoreObjectFromSafeSave:object];
    return self;
}



#pragma mark transfer
-(id)objectToSafeSave:(id)object{
    if (![[self class] supportYRSerialization]) {
#if DEBUG
        NSAssert(false, @"YRSerializationCategory: the class %@ can't support the YRSerializationCategory ,because the developer of this class forbid it",[self class]);
#endif
        return nil;
    }

    id resultObj=nil;
    if ([object isKindOfClass:[NSArray class]]) {
        resultObj=[self saveObjectsFromArray:object];
    }else if ([object isKindOfClass:[NSDictionary class]]){
        resultObj=[self saveObjectsFromDictionary:object];
    }else if ([object isKindOfClass:[NSSet class]]){
        resultObj=[self saveObjectsFromSet:object];
    }else if ([object isKindOfClass:[NSString class]]){
        resultObj=object;
    }else if ([object isKindOfClass:[NSValue class]]){
        resultObj=[self saveObjectsFromValue:object];
    }else if ([object isKindOfClass:[NSNull class]]){
        resultObj=object;
    }else if ([object isKindOfClass:[NSDate class]]){
        resultObj=[self saveObjectsFromDate:object];
    }else{
        resultObj=[object saveObjectPropertiesToDictionary];
    }
    return resultObj;
}

-(id)objectToSafeRestore:(id)object{
    return [self objectToSafeRestore:object propertyName:nil];
}
-(id)objectToSafeRestore:(id)object propertyName:(NSString*)propertyName{
    id resultObj=nil;
    if ([object isKindOfClass:[NSArray class]]) {
        resultObj=[self restoreObjectsFromArray:object];
    }else if ([object isKindOfClass:[NSDictionary class]]){
        NSString *propertyClassName=nil;
        if (propertyName) {
            NSDictionary *propertyClassNameDictionary=[[self class]auxiliaryYRClassNameDictionary];
            propertyClassName=[propertyClassNameDictionary objectForKey:propertyName];
        }
        BOOL directRestore=true;
        if (propertyClassName) {
            Class className=NSClassFromString(propertyClassName);
            if ([className isSubclassOfClass:[NSDate class]]) {//无须重新new的类
                directRestore=true;
            }
            if (!directRestore) {
                resultObj=[[className alloc]init];
                [resultObj restorePropertiesFromDictionary:object class:className];
            }
        }
        if (directRestore) {
            resultObj=[self restoreObjectsFromDictionary:object];
        }
    }else if ([object isKindOfClass:[NSSet class]]){
        resultObj=[self restoreObjectsFromSet:object];
    }else if ([object isKindOfClass:[NSString class]]){
        resultObj=object;
    }else if ([object isKindOfClass:[NSValue class]]){
        resultObj=object;
    }else if ([object isKindOfClass:[NSNull class]]){
        resultObj=object;
    }else{
        resultObj=object;
    }
    return resultObj;
}

-(id)saveObjectToSafeStore{
    return [self objectToSafeSave:self];
}

-(id)restoreObjectFromSafeSave:(id)savedObj{
    return [self objectToSafeRestore:savedObj];
}

-(NSMutableArray*)saveObjectsFromArray:(NSArray*)array{
    if (array&&[array isKindOfClass:[NSArray class]]) {
        NSMutableArray *resultArray=[NSMutableArray arrayWithCapacity:[array count]];
        for (id obj in array) {
            id safeObj=[self objectToSafeSave:obj];
            if (safeObj) {
                [resultArray addObject:safeObj];
            }
        }
        return resultArray;
    }
    return nil;
}

-(NSMutableDictionary *)saveObjectsFromDictionary:(NSDictionary*)dictionary{
    if (dictionary&&[dictionary isKindOfClass:[NSDictionary class]]) {
        __block NSMutableDictionary *resultDictionary=[NSMutableDictionary dictionaryWithCapacity:[dictionary count]];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [resultDictionary setObject:[self objectToSafeSave:obj] forKey:key];
        }];
        return resultDictionary;
    }
    return nil;
}
-(NSSet *)saveObjectsFromSet:(NSSet*)set{
    if (set&&[set isKindOfClass:[NSSet class]]) {
        NSMutableSet *resultSet=[NSMutableSet setWithCapacity:[set count]];
        for (id obj in set) {
            id safeObj=[self objectToSafeSave:obj];
            if (safeObj) {
                [resultSet addObject:safeObj];
            }
        }
        return resultSet;
    }
    return nil;
}
-(id)saveObjectsFromValue:(NSValue*)value{
    if (value&&[value isKindOfClass:[NSValue class]]) {
        NSString *objcTypeString=[NSString stringWithCString:[value objCType] encoding:NSUTF8StringEncoding];
        NSLog(@"objcTypeString=%@",objcTypeString);
        if ([objcTypeString length]==1) {//系统基本上能直接识别
            return value;
        }else if([objcTypeString hasPrefix:@"{"]&&[objcTypeString hasSuffix:@"}"]){//复杂且麻烦的结构体
            NSString *resultString=[value description];
            if (!resultString||[resultString hasPrefix:@"<"]) {
                NSLog(@"--->>warning! find a unknow struct to save! ignored this value ,value=%@",value);
                return nil;
            }
            return @{YRSerializationStructNamekey:@1,YRSerializationStructValuekey:resultString};
        }else{
            return value;
        }
        
    }
    return value;
}
-(id)saveObjectsFromDate:(NSDate*)date{
    if (date&&[date isKindOfClass:[NSDate class]]) {
        NSTimeInterval time=[date timeIntervalSince1970];
        return @{YRSerializationDateNamekey:[NSNumber numberWithDouble:time]};
    }
    return nil;
}

-(NSMutableDictionary*)saveObjectPropertiesToDictionary{
    if ([self isKindOfClass:[NSDictionary class]]||[self isKindOfClass:[NSArray class]]||[self isKindOfClass:[NSValue class]]||[self isKindOfClass:[NSString class]]||[self isKindOfClass:[NSSet class]]||[self isKindOfClass:[NSDate class]]||[self isKindOfClass:[NSData class]]) {
#if DEBUG
        NSLog(@"warning : the class %@ can not use this method !please check and use your custom class",[self class]);
#endif
        return nil;
    }
    NSArray *propertyKeys=[self propertyKeys];
    if ([propertyKeys count]==0) {
        return nil;
    }
    NSMutableDictionary *dictionary=[NSMutableDictionary dictionaryWithCapacity:[propertyKeys count]];
    [dictionary setObject:NSStringFromClass([self class]) forKey:YRSerializationClassNamekey];
    NSDictionary *propertyKeysToSaveKeys=[self propertyKeysToSaveKeys];
    for (NSString *key in propertyKeys) {
        NSString *saveKey=key;
        if (propertyKeysToSaveKeys) {
            saveKey=[propertyKeysToSaveKeys objectForKey:key];
            if (!saveKey) {
                continue;
            }
        }
        
        id propertyValue = [self valueForKey:key];
        if (propertyValue) {
            id propertyValueObj=[self objectToSafeSave:propertyValue];
            if (propertyValueObj) {
                [dictionary setObject:propertyValueObj forKey:saveKey];
            }
        }
    }
    return dictionary;
}


-(NSMutableArray*)restoreObjectsFromArray:(NSArray*)array{
    NSMutableArray *resultArray=[NSMutableArray arrayWithCapacity:[array count]];
    for (id obj in array) {
        id safeObj=[self objectToSafeRestore:obj];
        if (safeObj) {
            [resultArray addObject:safeObj];
        }
    }
    return resultArray;
}
-(NSMutableSet*)restoreObjectsFromSet:(NSSet*)set{
    NSMutableSet *resultSet=[NSMutableSet setWithCapacity:[set count]];
    for (id obj in set) {
        id safeObj=[self objectToSafeRestore:obj];
        if (safeObj) {
            [resultSet addObject:safeObj];
        }
    }
    return resultSet;
}
-(NSValue*)restoreObjectsFromValueDescriptionString:(NSString*)valueDescription{
    NSValue *value=nil;
    if ([valueDescription hasPrefix:@"NSPoint"]) {
        value=[NSValue valueWithCGPoint:CGPointFromString(valueDescription)];
    }else if ([valueDescription hasPrefix:@"NSRect"]){
        value=[NSValue valueWithCGRect:CGRectFromString(valueDescription)];
    }else if ([valueDescription hasPrefix:@"NSSize"]){
        value=[NSValue valueWithCGSize:CGSizeFromString(valueDescription)];
    }else if ([valueDescription hasPrefix:@"CGAffineTransform"]){
        value=[NSValue valueWithCGAffineTransform:CGAffineTransformFromString(valueDescription)];
    }else if ([valueDescription hasPrefix:@"UIEdgeInsets"]){
        value=[NSValue valueWithUIEdgeInsets:UIEdgeInsetsFromString(valueDescription)];
    }else if ([valueDescription hasPrefix:@"UIOffset"]){
        value=[NSValue valueWithUIOffset:UIOffsetFromString(valueDescription)];
    }else{
        NSLog(@"--->>warning! find a unknow struct to restore!,value=%@",value);
    }
    return value;
}

-(id)restoreObjectsFromDictionary:(NSDictionary *)dictionary{
    if (!dictionary||![dictionary isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    NSString *subClassName=[dictionary objectForKey:YRSerializationClassNamekey];
    if (subClassName) {
        Class className=NSClassFromString(subClassName);
        id classObj=[[className alloc]init];
        [classObj restorePropertiesFromDictionary:dictionary class:className];
        return classObj;
    }else{
        NSNumber *timeNumber=[dictionary objectForKey:YRSerializationDateNamekey];
        if (timeNumber) {
            return [NSDate dateWithTimeIntervalSince1970:[timeNumber doubleValue]];
        }else{
            NSString *structName=[dictionary objectForKey:YRSerializationStructNamekey];
            if (structName) {
                return [self restoreObjectsFromValueDescriptionString:[dictionary objectForKey:YRSerializationStructValuekey]];
            }else{
                __block NSMutableDictionary *resultDictionary=[NSMutableDictionary dictionaryWithCapacity:[dictionary count]];
                [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [resultDictionary setObject:[self objectToSafeRestore:obj] forKey:key];
                }];
                return resultDictionary;
            }
        }
    }
    return nil;
}
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary class:(Class)class{
    if (![class supportYRSerialization]) {
#if DEBUG
        NSAssert(false, @"YRSerializationCategory: the class %@ can't support the YRSerializationCategory ,because the developer of this class forbid it",[self class]);
#endif
        return false;
    }
    if (!dictionary||![dictionary isKindOfClass:[NSDictionary class]]) {
        return false;
    }
    NSDictionary *propertyKeysToSaveKeys=[self propertyKeysToSaveKeys];
    BOOL ret = false;
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *saveKey=propertyName;
        if (propertyKeysToSaveKeys) {
            saveKey=[propertyKeysToSaveKeys objectForKey:propertyName];
            if (!saveKey) {
                continue;
            }
        }
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            ret = ([dictionary valueForKey:saveKey]==nil)?false:true;
        }else{
            ret = [dictionary respondsToSelector:NSSelectorFromString(saveKey)];
        }
        if (ret) {
            id propertyValue = [dictionary valueForKey:saveKey];
            if (propertyValue) {
                id safeObj=[self objectToSafeRestore:propertyValue propertyName:propertyName];
                if (safeObj) {
                    [self setValue:safeObj forKey:propertyName];
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

-(id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"-->>try to get undefinekey %@ from %@",key,self);
    return nil;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"-->>try to set undefinekey %@ value %@ to %@",key,value,self);
}

@end


@implementation NSArray (YRSerializationCategory)
-(NSMutableArray*)saveObjectsToArray{
    if (self&&[self isKindOfClass:[NSArray class]]) {
        return [super saveObjectsFromArray:self];
    }
    return nil;
}
-(NSMutableArray*)restoreObjectsFromArray{
    if (self&&[self isKindOfClass:[NSArray class]]) {
        return [super restoreObjectsFromArray:self];
    }
    return nil;
}
@end

@implementation NSDictionary (YRSerializationCategory)
-(void)removeAllAuxiliaryYRClassName{
    if (self&&[self isKindOfClass:[NSMutableDictionary class]]) {
        [(NSMutableDictionary*)self removeObjectForKey:YRSerializationClassNamekey];
        NSArray *allKeys=[self allKeys];
        for (NSInteger i=allKeys.count-1; i>=0; i--) {
            id obj=[self objectForKey:allKeys[i]];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [obj removeAllAuxiliaryYRClassName];
            }
        }
    }
}

-(NSMutableDictionary*)saveObjectsToDictionary{
    if (self&&[self isKindOfClass:[NSDictionary class]]) {
        return [super saveObjectsFromDictionary:self];
    }
    return nil;
}
-(NSMutableDictionary*)restoreObjectsFromDictionary{
    if (self&&[self isKindOfClass:[NSDictionary class]]) {
        return [super restoreObjectsFromDictionary:self];
    }
    return nil;
}
@end

@implementation NSSet (YRSerializationCategory)
-(NSMutableSet*)saveObjectsToSet{
    if (self&&[self isKindOfClass:[NSSet class]]) {
        return [super saveObjectToSafeStore];
    }
    return nil;
}
-(NSMutableSet*)restoreObjectsFromSet{
    if (self&&[self isKindOfClass:[NSSet class]]) {
        return [super restoreObjectsFromSet:self];
    }
    return nil;
}
@end

@implementation NSValue (YRSerializationCategory)
-(id)saveObjectToSafeStore{
    if (self&&[self isKindOfClass:[NSValue class]]) {
        return [super saveObjectsFromValue:self];
    }
    return nil;
}
-(NSValue *)restoreObjectFromSafeSave:(id)savedObj{
    id restoreObj=[super restoreObjectFromSafeSave:savedObj];
    if ([restoreObj isKindOfClass:[NSValue class]]) {
        return restoreObj;
    }
    return nil;
}
+(NSValue *)valueWithDescriptionString:(NSString*)description{
    return [super restoreObjectsFromValueDescriptionString:description];
}
@end