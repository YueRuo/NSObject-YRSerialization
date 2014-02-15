###Why made this
Normally , we can use JSON or save an Object to NSUserDefault if the class is simple,but if the class has an other class property (class A have a propery p,but p is B class),the system method don't work.  
So I made this.

###What can this do

* A category for NSObject that can serialization and unserialization any custom class.

* It is universally to all custom class, and you just need use to two method to make serialize and unserialize.

* This can make obj to dictionary and obj from dictionary . I think you can do dictionary to json or to NSUserDefaults etc by yourself .. yes you can ..
 
> This category work for any class except basic data type ,and be attention,the linked data structure may caused a dead loop.（Details see warning.）

###Method
    -(NSDictionary*)savePropertiesToDictionary;//Make an object to a dictionary,and this dictionary can purely be saved to the NSUserDefaults or to a json.
    -(BOOL)restorePropertiesFromDictionary:(NSDictionary*)dictionary;//This method make to obj back from the dictionary you previous saved by the savePropertiesToDictionary method.


###Example
1.Here is a class:@interface CustomClass:NSObject....,may have a lot of properties(maybe propertyA,propertyB etc.).    

    //1.when save an object to dictionary
    CustomClass *customClass=[CustomClass new];
    customClass.propertyA=a;//set it's property
    customClass.propertyB=b;//support another class
    ...
    NSDicitonary *infoDictonary=[customClass savePropertiesToDictionary];//very simply,the CustomClass's all property saved to the dictionary.  
   infoDictonary is the result that you can save or make it to JSONString ...

    //2.when you want make the obj back,just do like this:
     CustomClass *customClassForRestore=[CustomClass new];
     [customClassForRestore restorePropertiesFromDictionary:infoDictonary];
     
2.You can override the method     

    -(NSDictionary*)savePropertiesToDictionary;  
to do someting special , such as remove unsupport value , edit value , add extra valua and so on.

    -(NSDictionary*)savePropertiesToDictionary{
    	NSDictionary *dictionarySupper=[super savePropertiesToDictionary];
    	NSMutableDictionary *dictionary=[NSMutableDictionary dictionaryWithDictionary:dictionarySupper];
    	[dictionary setObject:@"customValue" forKey:@"customKey"];//add or set customValue you want to save , must be NSString.
    	[dictionary removeObjectForKey:@"oneKey"];
    	return dictionary;
    }

###Warning：  
* This category `not support basic data type`, such as NSValue,NSString,NSNumber,NSArray,NSDictionary,NSSet etc. (for example , [a savePropertiesToDictionary] , if a is NSValue class , the method will return nil)      
* `Not support C struct` , if you really need to save the struct in your class , you should override the method -(NSDictionary*)savePropertiesToDictionary;
* You should better use this category for your custom subclass of NSObject , it will be safe and work well . If you want to make it work for other class such as UIViewController , I am not sure there are no error but you can try.

###How it works
I use the KVC and the runtime to get & set the properties ,and I check if there is any super class and property class to make sure all it's properties will be find and used (But this may take a dead loop if this class has linked data structure).  
If you really interest in the principle , just see my sources.

###At the end
If you have any question，you can email me :wxy_yueruo@163.com
