//
//  DemoModel.h
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoSubModel.h"

typedef struct {
    int a;
    NSString *b;
}TestStruct;

@interface DemoModel : NSObject
@property (assign,nonatomic) int demoInt;
@property (retain,nonatomic) NSString *demoString;
@property (retain,nonatomic) NSArray *demoArray;
@property (retain,nonatomic) NSDictionary *demoDictionary;
@property (retain,nonatomic) DemoSubModel *demoSubModel;//another class

//supported struct
@property (assign,nonatomic) CGRect frame;
@property (assign,nonatomic) CGSize size;
@property (assign,nonatomic) UIEdgeInsets edgeInsets;
@property (assign,nonatomic) CGAffineTransform affineTransform;
@property (assign,nonatomic) UIOffset offset;
@property (assign,nonatomic) CGPoint point;

@property (assign,nonatomic,getter = isSelect) BOOL select;

@property (assign,nonatomic) TestStruct t;//custom C Struct ,unsupport ,but this property will be ignored

@property (retain,nonatomic) id demoSubModel2;//another class with id property
@end
