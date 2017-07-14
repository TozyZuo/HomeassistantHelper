//
//  HAHModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHModel.h"
#import <objc/runtime.h>

@implementation HAHModel

void *runtimekey_propertyKeys = &runtimekey_propertyKeys;

- (NSString *)description
{
    NSMutableArray *propertyKeys = objc_getAssociatedObject([self class], runtimekey_propertyKeys);
    if (!propertyKeys) {
        propertyKeys = [[NSMutableArray alloc] init];
        objc_setAssociatedObject([self class], runtimekey_propertyKeys, propertyKeys, OBJC_ASSOCIATION_RETAIN);
        Class class = [self class];
        while (class != [NSObject class]) {
            objc_property_t *pList;
            unsigned count;
            pList = class_copyPropertyList(class, &count);
            for (int i = 0; i < count; i++) {
                objc_property_t p = pList[i];
                [propertyKeys addObject:[NSString stringWithUTF8String:property_getName(p)]];
            }
            free(pList);
            class = class_getSuperclass(class);
        }
    }

    NSMutableString *description = [super description].mutableCopy;
    for (NSString *propertyKey in propertyKeys.reverseObjectEnumerator) {
        [description appendFormat:@" [%@] %@", propertyKey, [self valueForKey:propertyKey]];
    }

    return description;
}

@end
