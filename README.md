NSObject-YRSerialization
========================

This is a class for Objective-C.

A category for NSObject that can serialization and unserialization any custom class.

It is universally to all custom class, and you just need use to two method to make serialize and unserialize.

I make obj to dictionary and obj from dictionary . you can do dictionary to json and to NSUserDefaults etc by yourself.. yes you can ..


Warning : This category not support basic data type , such as NSValue,NSString,NSArray,NSDictionary,NSSet etc.
You should better use this category for your custom subclass of NSObject ,it will be safe and work well. If you want to make it work for other class such as UIViewController,I am not sure there are not error but you can try.
