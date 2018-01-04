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
{
    NSMutableArray *_propertyNames;
}
@property (nonatomic, strong) NSMutableDictionary *classTypeMap;
@end

@implementation HAHModelInformation

- (instancetype)initWithModel:(HAHModel *)model
{
    if (self = [super init]) {

        NSMutableArray *propertyNames = [[NSMutableArray alloc] init];
        NSMutableDictionary *classTypeMap = [[NSMutableDictionary alloc] init];

        Class class = model.class;

        while (class != [NSObject class]) {

            objc_property_t *pList;
            unsigned count;
            pList = class_copyPropertyList(class, &count);

            for (int i = 0; i < count; i++) {

                objc_property_t p = pList[i];

                if ([model.ignoreProperties containsObject:@(property_getName(p))]) {
                    continue;
                }

                // propertyName
                NSString *propertyName = [NSString stringWithUTF8String:property_getName(p)];
                [propertyNames addObject:propertyName];

                // class map
                unsigned count;
                objc_property_attribute_t *attributes = property_copyAttributeList(p, &count);
                for (int i = 0; i < count; i++) {
                    if ([@(attributes[i].name) isEqualToString:@"T"]) {
                        NSString *classString = @(attributes[i].value);
                        classTypeMap[propertyName] = [classString substringWithRange:NSMakeRange(2, classString.length - 3)];
                    }
                }
                free(attributes);
            }
            free(pList);
            class = class_getSuperclass(class);
        }
        _propertyNames = propertyNames.reverseObjectEnumerator.allObjects.mutableCopy;
        self.classTypeMap = classTypeMap;
    }
    return self;
}

- (NSArray *)propertyNames
{
    return _propertyNames;
}

- (NSString *)classStringForProperty:(NSString *)property
{
    return self.classTypeMap[property];
}

- (void)addProperty:(NSString *)property classString:(NSString *)classString
{
    [_propertyNames addObject:property];
    self.classTypeMap[property] = classString;
}

@end

@implementation HAHModel
@synthesize infomation = _infomation;

- (HAHModelInformation *)infomation
{
    if (!_infomation) {
        _infomation = [[HAHModelInformation alloc] initWithModel:self];
    }
    return _infomation;
}

- (NSArray *)ignoreProperties
{
    static NSArray *ignoreProperties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignoreProperties = @[@"infomation", @"ignoreProperties"];
    });
    return ignoreProperties;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p ", [self class], self];

    NSMutableArray *properties = [[NSMutableArray alloc] init];
    for (NSString *property in self.infomation.propertyNames) {
        [properties addObject:[NSString stringWithFormat:@"%@ = %@", property, [self valueForKey:property]]];
    }

    [description appendFormat:@"%@>", properties];

    return description;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        for (NSString *property in self.infomation.propertyNames) {
            [self setValue:[aDecoder decodeObjectForKey:property] forKey:property];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *property in self.infomation.propertyNames) {
        [aCoder encodeObject:[self valueForKey:property] forKey:property];
    }
}

@end
