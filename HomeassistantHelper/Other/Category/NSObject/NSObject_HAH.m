//
//  NSObject_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/28.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSObject_HAH.h"
#import "Aspects.h"
#import <objc/runtime.h>

@interface HAHObserverMap : NSObject
{
    id _transmition;
}
@property (nonatomic) NSMapTable <NSObject */*observer*/, NSMutableDictionary<NSString */*SEL*/, NSMutableArray<NSHashTable<id<AspectInfo>> *> *> *> *mapTable;
@property (readonly) HAHObserverMap *(^observer)(NSObject *observer);
@property (readonly) HAHObserverMap *(^selector)(SEL selector);
@property (readonly) NSHashTable *(^option)(AspectOptions option);
@property (readonly) NSMutableDictionary *(^selectorsWithObserver)(NSObject *observer);
@end

@implementation HAHObserverMap

- (NSMapTable<NSObject *,NSMutableDictionary<NSString *,NSMutableArray<NSHashTable<id<AspectInfo>> *> *> *> *)mapTable
{
    if (!_mapTable) {
        _mapTable = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _mapTable;
}

- (HAHObserverMap *(^)(NSObject *observer))observer
{
    return ^(NSObject *observer){
        if (!_transmition) {
            NSMutableDictionary *selectorDictionary = [self.mapTable objectForKey:observer];
            if (!selectorDictionary) {
                selectorDictionary = [[NSMutableDictionary alloc] init];
                [self.mapTable setObject:selectorDictionary forKey:observer];
            }
            _transmition = selectorDictionary;
        }
        return self;
    };
}

- (NSMutableDictionary *(^)(NSObject *observer))selectorsWithObserver
{
    return ^(NSObject *observer){
        return [self.mapTable objectForKey:observer];
    };
}

- (HAHObserverMap *(^)(SEL selector))selector
{
    return ^(SEL selector){
        if ([_transmition isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *selectorDictionary = _transmition;
            NSString *selectorKey = NSStringFromSelector(selector);
            NSMutableArray *aspects = selectorDictionary[selectorKey];
            if (!aspects) {
                aspects = [[NSMutableArray alloc] init];
                selectorDictionary[selectorKey] = aspects;
            }
            _transmition = aspects;
        }
        return self;
    };
}

- (NSHashTable *(^)(AspectOptions option))option
{
    return ^(AspectOptions option){
        NSHashTable *ret;
        if ([_transmition isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *aspects = _transmition;
            if (!aspects.count) {
                [aspects addObject:[NSHashTable weakObjectsHashTable]];
                [aspects addObject:[NSHashTable weakObjectsHashTable]];
            }
            switch (option) {
                case AspectPositionBefore:
                    ret = aspects.firstObject;
                    break;
                case AspectPositionAfter:
                    ret = aspects.lastObject;
                    break;
                default:
                    break;
            }
            _transmition = nil;
        }
        return ret;
    };
}

@end

@interface NSObject (HAHObserve_Private)
@property (readonly) HAHObserverMap *observerMap;
@end

@implementation NSObject (HAHObserve)

void *HAHObserverMapKey = &HAHObserverMapKey;

- (HAHObserverMap *)observerMap
{
    HAHObserverMap *observerMap = objc_getAssociatedObject(self, HAHObserverMapKey);
    if (!observerMap) {
        observerMap = [[HAHObserverMap alloc] init];
        objc_setAssociatedObject(self, HAHObserverMapKey, observerMap, OBJC_ASSOCIATION_RETAIN);
    }
    return observerMap;
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector preprocessor:(id)block
{
    NSError *error;
    id aspectToken = [self aspect_hookSelector:selector withOptions:AspectPositionBefore usingBlock:block error:nil];
    HAHLogError(error);

    [self.observerMap.observer(observer).selector(selector).option(AspectPositionBefore) addObject:aspectToken];
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector postprocessor:(id)block
{
    NSError *error;
    id aspectToken = [self aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:block error:nil];
    HAHLogError(error);

    [self.observerMap.observer(observer).selector(selector).option(AspectPositionAfter) addObject:aspectToken];
}

- (void)removeAllObserver
{
    for (NSObject *observer in self.observerMap.mapTable) {
        [self removeObserver:observer];
    }
}

- (void)removeObserver:(NSObject *)observer
{
    for (NSString *selector in self.observerMap.selectorsWithObserver(observer)) {
        [self removeObserver:observer selector:NSSelectorFromString(selector)];
    }
}

- (void)removeObserver:(NSObject *)observer selector:(SEL)selector
{
    [self removePreprocessorsWithObserver:observer selector:selector];
    [self removePostprocessorsWithObserver:observer selector:selector];
}

- (void)removePreprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector
{
    for (id<AspectToken> token in self.observerMap.observer(observer).selector(selector).option(AspectPositionBefore))
    {
        [token remove];
    }
}

- (void)removePostprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector
{
    for (id<AspectToken> token in self.observerMap.observer(observer).selector(selector).option(AspectPositionAfter))
    {
        [token remove];
    }
}

@end

