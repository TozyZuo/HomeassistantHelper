//
//  NSObject_HAH.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/28.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
    浮点传参有问题
 */

@interface NSObject (HAHObserve)
/**
 *  block里的东西一定要弱引用，否则可能产生内存问题
 *  多次添加，多次调用，因为用block，所以无法判断是否之前添加过，建议添加之前先移除一次
 *  如果用target & selector可以去重，但是使用不便
 */
- (void)addObserver:(NSObject *)observer selector:(SEL)selector preprocessor:(id)block;
- (void)addObserver:(NSObject *)observer selector:(SEL)selector postprocessor:(id)block;
- (void)removeAllObserver;
- (void)removeObserver:(NSObject *)observer;
- (void)removeObserver:(NSObject *)observer selector:(SEL)selector;
- (void)removePreprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector;
- (void)removePostprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector;
@end
