//
//  HAHModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/11.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHModel.h"
#import <objc/runtime.h>

@interface HAHModelInformation ()
@property (nonatomic, strong) NSArray       *propertyNames;
@property (nonatomic, strong) NSDictionary  *data;
@end
@implementation HAHModelInformation

- (instancetype)initWithModelClass:(Class)class
{
    if (self = [super init]) {

        NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];

        while (class != [NSObject class]) {

            objc_property_t *pList;
            unsigned count;
            pList = class_copyPropertyList(class, &count);

            for (int i = 0; i < count; i++) {

                objc_property_t p = pList[i];

                // TODO 添加白名单列表，过滤不关心的属性
                if ([[NSString stringWithUTF8String:property_getName(p)] isEqualToString:@"infomation"]) {
                    continue;
                }

                // propertyName
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(p)];
                [propertyNames addObject:propertyName];

                // data
                unsigned count;
                objc_property_attribute_t *attributes = property_copyAttributeList(p, &count);
                for (int i = 0; i < count; i++) {
                    if ([@(attributes[i].name) isEqualToString:@"T"]) {
                        NSString *classString = @(attributes[i].value);
                        data[propertyName] = [classString substringWithRange:NSMakeRange(2, classString.length - 3)];
                    }
                }

            }
            free(pList);
            class = class_getSuperclass(class);
        }
        self.propertyNames = propertyNames.reverseObjectEnumerator.allObjects.copy;
        self.data = data.copy;
    }
    return self;
}

- (NSString *)classStringForProperty:(NSString *)property
{
    return self.data[property];
}

@end

@implementation HAHModel

void *runtimekeyHAHModelInformation = &runtimekeyHAHModelInformation;

+ (HAHModelInformation *)infomation
{
    HAHModelInformation *infomation = objc_getAssociatedObject(self, runtimekeyHAHModelInformation);

    if (!infomation) {
        infomation = [[HAHModelInformation alloc] initWithModelClass:self];
        objc_setAssociatedObject(self, runtimekeyHAHModelInformation, infomation, OBJC_ASSOCIATION_RETAIN);
    }

    return infomation;
}

- (NSString *)description
{
    NSMutableString *description = super.description.mutableCopy;

    for (NSString *property in [self.class infomation].propertyNames) {
        [description appendFormat:@" [%@] %@", property, [self valueForKey:property]];
    }

    return description;
}

@end
