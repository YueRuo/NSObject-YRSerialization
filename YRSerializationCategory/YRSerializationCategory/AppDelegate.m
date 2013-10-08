//
//  AppDelegate.m
//  YRSerializationCategory
//
//  Created by 王晓宇 on 13-10-8.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "AppDelegate.h"
#import "DemoModel.h"
#import "NSObject+YRSerializationCategory.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //******************************
    //*-begin-- testSave
    //******************************
    DemoModel *demoModel=[[DemoModel alloc]init];
    [demoModel setDemoInt:100];
    [demoModel setDemoString:@"this is a test for YRSerializationCategory,this is DemoModel"];
    [demoModel setDemoArray:[NSArray arrayWithObjects:@20,@[@19,@"64"],@"arraryObj", nil]];
    [demoModel setDemoDictionary:[NSDictionary dictionaryWithObject:@"dictionaryValue" forKey:@"dictionaryKey"]];
    DemoSubModel *demoSubModel=[[DemoSubModel alloc]init];
    [demoSubModel setDemoSubString:@"this is demoSubModel"];
    [demoModel setDemoSubModel:demoSubModel];//set the custom class of DemoModel
    
    NSDictionary *savedDicationary=[demoModel savePropertiesToDictionary];//easy to save
    NSLog(@"-->>the savedDicationary=%@",savedDicationary);//you can use this dictionary to json or...
    //----------------------------
    //-end-- testSave
    //---------------------------
    
    //******************************
    //*-begin-- testRestore
    //******************************
    DemoModel *newDemoMode=[[DemoModel alloc]init];
    [newDemoMode restorePropertiesFromDictionary:savedDicationary];//easy to restore
    NSLog(@"-->>the newDemoMode=%@\nthe newDemoMode dictionary=%@",newDemoMode,[newDemoMode savePropertiesToDictionary]);//you can make a breakpoint to see the property.
    //----------------------------
    //-end-- testRestore
    //---------------------------
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
