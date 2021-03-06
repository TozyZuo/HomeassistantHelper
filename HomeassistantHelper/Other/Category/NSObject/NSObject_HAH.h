//
//  NSObject_HAH.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/28.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (HAHObserve)

- (void)addObserver:(NSObject *)observer selector:(SEL)selector preprocessor:(id)block;
- (void)addObserver:(NSObject *)observer selector:(SEL)selector postprocessor:(id)block;

- (void)removeAllObserver;
- (void)removeObserver:(NSObject *)observer;
- (void)removeObserver:(NSObject *)observer selector:(SEL)selector;
- (void)removePreprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector;
- (void)removePostprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector;

@end
