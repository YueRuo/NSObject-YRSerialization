###Introduction
Normally , we can use JSON or save an Object to NSUserDefault if the class is simple,but if the class has an other class property (class A have a propery p,but p is B class),the system method don't work.  
So I made this.

###What is this

* A category for NSObject that can serialization and unserialization any custom class.

* It is universally to all custom class, and you just need use to two method to make serialize and unserialize.

* This can make obj to dictionary and obj from dictionary . I think you can do dictionary to json or to NSUserDefaults etc by yourself .. yes you can ..


###Features
* Support complex class .  
* Detector the custom C struct and ignore the unsupport value .
* Implement the NSCoding protocol .  
* Can change the key to save and restore , usually we used it in network transfer .  

> This category work for any custom class , but be attention,the linked data structure may caused a dead loop.（Details see warning.）  
    
###Warning  
* This category `not support basic data type`, such as NSValue,NSString,NSNumber,NSArray,NSDictionary,NSSet etc. (for example , [a savePropertiesToDictionary] , if a is NSValue class , the method will return nil)      
* `Not support C struct` , I have do my best to help you to save CGRect,CGPoint,CGSize,UIOffset,UIEdgeInsets,CGAffineTransform struct , if you really need to save other struct in your class , you'd better override the method -(NSDictionary*)savePropertiesToDictionary;
* You should better use this category for your custom subclass of NSObject , it will be safe and work well . If you want to make it work for other class such as UIViewController , I am not sure there are no error but you can try.

###How it works
I use the KVC and the runtime to get & set the properties ,and I check if there is any super class and property class to make sure all it's properties will be find and used (But this may take a dead loop if this class has linked data structure).  
If you really interest in the principle , just see my sources.

###At the end
If you have any question，you can email me :wxy_yueruo@163.com
