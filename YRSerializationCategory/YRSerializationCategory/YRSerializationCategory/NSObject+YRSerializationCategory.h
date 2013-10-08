//
//  NSObject+YRSerializationCategory.h
//  YRSnippets
//
//  Created by 王晓宇 on 13-8-26.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//



/*!
 *	@class	this class can do obj to dictionary and restore obj from the dictionary .
 *  this class make the subclass of NSObject to a dictionary , you can use this dictionary safely saved do a lot of things , such as to json,to save to NSUserDefaults and so on . And then you can get the obj back by the restore method.
 *  this category suport complex class and can get the property from it's supper class .
 *  in this class , I do not make the obj to json method, you can do it by yourself ,or use the famous third part library such as JSONKit ..
 *  ok , I hope you can enjoy the convenience made by this class.
 
 *  @note  Warning ! This class don't support the basic data type , such as NSString,NSValue,NSArray,NSDictionary,NSSet etc. In fact ,those class do not need use this category.
 */
#import <Foundation/Foundation.h>


@interface NSObject (YRSerializationCategory)

-(NSArray*)propertyKeys;
-(NSDictionary*)savePropertiesToDictionary;//This dictionary can purely be saved to the NSUserDefaults or to a json.
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary;//This method make to obj back from the dictionary you previous saved by the savePropertiesToDictionary method.

@end
