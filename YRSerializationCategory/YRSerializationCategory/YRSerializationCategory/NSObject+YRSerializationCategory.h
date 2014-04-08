//
//  NSObject+YRSerializationCategory.h
//  YRSnippets
//
//  Created by 王晓宇 on 13-8-26.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//



/*!
 *	@class	this class can do obj to easy encode and decode
 *  this category suport complex class and can get the property from it's supper class .
 *  in this class , I do not make the obj to json method, you can do it by yourself ,or use the famous third part library such as JSONKit ..
 *  ok , I hope you can enjoy the convenience made by this class.
 */
#import <Foundation/Foundation.h>


@interface NSObject (YRSerializationCategory)<NSCoding>

/*!
 *	@brief	abstract method，let you forbid some class use this category
 *
 *	@return	true means ok，false means can't support，default value is true
 */
-(BOOL)supportYRSerialization;

/*!
 *	@brief	abstract method，let you change the key to save ,or remove some key,useful for server data
 *
 *	@return	NSDictionary, localKey:saveKey
 *  @note default return nil,so save all it's property keys
 */
-(NSDictionary*)propertyKeysToSaveKeys;


-(NSArray*)propertyKeys;

-(NSMutableDictionary*)savePropertiesToDictionary;//This dictionary can purely be saved to the NSUserDefaults or to a json . save some custom class name for restore
-(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary;//This method make to obj back from the dictionary you previous saved by the savePropertiesToDictionary method.

-(NSMutableDictionary*)savePropertiesWithoutAuxiliaryClassName;//This dictionary can purely be saved to the NSUserDefaults or to a json . Without any class name info , so you'd better not use this returned dictionary to restore.


/*
-(id)saveObjectToSafeStore;
-(id)restoreObjectFromSafeSave:(id)savedObj;
*/

@end

@interface NSArray (YRSerializationCategory)
-(NSMutableArray*)saveObjectsToArray;//This array can purely be saved to the NSUserDefaults or to a json.
-(NSMutableArray*)restoreObjectsFromArray;//This method make to obj back from the array you previous saved by the saveObjectsToArray method.
@end

@interface NSDictionary (YRSerializationCategory)
/*!
 *	@brief	normally the NSObject category may save some custom class name for restore ，if you do not need restore ,for example send to server ,you can remove all auxiliary class name info to save traffic.
 */
-(void)removeAllAuxiliaryYRClassName;

-(NSMutableDictionary*)saveObjectsToDictionary;//This dictionary can purely be saved to the NSUserDefaults or to a json.
-(NSMutableDictionary*)restoreObjectsFromDictionary;//This method make to obj back from the dictionary you previous saved by the saveObjectsToDictionary method.
@end

@interface NSSet (YRSerializationCategory)
-(NSMutableSet*)saveObjectsToSet;//This set can purely be saved to the NSUserDefaults or to a json.
-(NSMutableSet*)restoreObjectsFromSet;//This method make to obj back from the set you previous saved by the saveObjectsToSet method.
@end

@interface NSValue (YRSerializationCategory)
//attention!!! this category can only work for NSNumber and some C Struct as CGRect,CGSize,CGPoint,UIOffset,UIEdgeInsets,CGAffineTransform ,for they all have [NSValue valueWith... method.
-(id)saveObjectToSafeStore;
-(NSValue *)restoreObjectFromSafeSave:(id)savedObj;
+(NSValue *)valueWithDescriptionString:(NSString*)description;
@end
