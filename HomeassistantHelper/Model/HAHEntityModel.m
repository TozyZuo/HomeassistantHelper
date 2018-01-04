//
//  HAHEntityModel.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEntityModel.h"

@interface HAHEntityModel ()
@property (nonatomic, strong) NSMutableDictionary *extensions;
@end

@implementation HAHEntityModel

- (void)dealloc
{
//    NSLog(@"%@ %p %@", object_getClass(self), self, self.name);
}

// TODO 暂时只重写了Entity的相等判断，后续考虑挪到基类
- (NSUInteger)hash
{
    return self.id.hash ^ self.name.hash;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        return [self.name isEqualToString:[object name]] &&
        [self.id isEqualToString:[object id]];
    }
    return NO;
}

- (NSArray *)ignoreProperties
{
    static NSArray *ignoreProperties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ignoreProperties = [@[@"extensions"] arrayByAddingObjectsFromArray:super.ignoreProperties];
    });
    return ignoreProperties;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    id value = self.extensions[key];
    if ([[self.infomation classStringForProperty:key] isEqualToString:@"BOOL"]) {
        return @([value boolValue]);
    }
    return value;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([[self.infomation classStringForProperty:key] isEqualToString:@"BOOL"]) {
        self.extensions[key] = [value boolValue] ? @"true" : @"false";
    } else {
        self.extensions[key] = value;
    }
}

@end
