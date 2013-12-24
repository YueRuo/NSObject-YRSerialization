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
 
 *  @note  Warning ! This class don't support the basic data type , such as NSString,NSValue,NSArray,NSDictionary,NSSet etc. In fact ,those class do not need use this category. And not support struct property!!
 */
#import <Foundation/Foundation.h>


@interface NSObject (YRSerializationCategory)

/*!
 *	@brief	abstract method，let you forbid some class use this category
 *
 *	@return	true means ok，false means can't support，default value is true
 */
-(BOOL)supportYRSerialization;


/*!
 *	@brief	all this class's perporties,normally,you do not need use it
 *
 *	@return	the array with class's perporties
 */
-(NSArray*)propertyKeys;


/*!
 *	@brief	make obj to dictionary,will check the class whether can support this category
 *
 *	@return	an dictionary,,this dictionary can purely be saved to the NSUserDefaults or to a json.
 *  @note This class don't support the basic data type , such as NSString,NSValue,NSArray,NSDictionary,NSSet etc. , and not support struct property!
 */
-(NSDictionary*)savePropertiesToDictionary;

/*!
 *	@brief	This method make to obj back from the dictionary you previous saved by the savePropertiesToDictionary method.
 *
 *	@param 	dictionary 	the dictionary you previous saved by the savePropertiesToDictionary method
 *
 *	@return	true means success,false means failed
 *  @note if return failed, you'd better not use the retored failed obj,may have unknown bug.
 */
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary;


@end
