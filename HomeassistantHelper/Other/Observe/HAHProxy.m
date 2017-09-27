//
//  HAHProxy.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/21.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHProxy.h"
#import "CTBlockDescription.h"

@interface HAHProxySelectorTableModel : NSObject
@property (nonatomic, strong) NSMutableArray *preprocessors;
@property (nonatomic, strong) NSMutableArray *postprocessor;
@end

@interface HAHProxy ()
@property (nonatomic, strong) id target;
@property (nonatomic, strong) NSMutableDictionary<NSString *, HAHProxySelectorTableModel *> *selectorTable;
@end

@implementation HAHProxy

- (void)dealloc
{
    
}

+ (instancetype)proxyWithTarget:(id)target
{
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(id)target
{
    self.target = target;
    self.selectorTable = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)injectToSelector:(SEL)selector preprocessor:(id)block
{
    HAHProxySelectorTableModel *table = self.selectorTable[NSStringFromSelector(selector)];
    if (!table) {
        table = [[HAHProxySelectorTableModel alloc] init];
        self.selectorTable[NSStringFromSelector(selector)] = table;
    }
    [table.preprocessors addObject:[block copy]];
}

- (void)injectToSelector:(SEL)selector postprocessor:(id)block
{
    HAHProxySelectorTableModel *table = self.selectorTable[NSStringFromSelector(selector)];
    if (!table) {
        table = [[HAHProxySelectorTableModel alloc] init];
        self.selectorTable[NSStringFromSelector(selector)] = table;
    }
    [table.postprocessor addObject:[block copy]];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    HAHProxySelectorTableModel *table = self.selectorTable[NSStringFromSelector(invocation.selector)];

    for (id block in table.preprocessors) {
        [self invokeBlock:block invocation:invocation];
    }

    invocation.target = self.target;
    [invocation invoke];

    for (id block in table.postprocessor) {
        [self invokeBlock:block invocation:invocation];
    }
}

- (NSInvocation *)invokeBlock:(id)block invocation:(NSInvocation *)invocation
{
    NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:[[CTBlockDescription alloc] initWithBlock:block].blockSignature];
    blockInvocation.target = block;
    NSUInteger count = MIN(invocation.methodSignature.numberOfArguments, blockInvocation.methodSignature.numberOfArguments - 1);
    id argument;
    for (int i = 0; i < count; i++) {
        [invocation getArgument:&argument atIndex:i+2];
        [blockInvocation setArgument:&argument atIndex:i+1];
    }
    [blockInvocation invoke];
    return blockInvocation;
}

@end

@implementation HAHProxySelectorTableModel

- (NSMutableArray *)preprocessors
{
    if (!_preprocessors) {
        _preprocessors = [[NSMutableArray alloc] init];
    }
    return _preprocessors;
}

- (NSMutableArray *)postprocessor
{
    if (!_postprocessor) {
        _postprocessor = [[NSMutableArray alloc] init];
    }
    return _postprocessor;
}

@end
