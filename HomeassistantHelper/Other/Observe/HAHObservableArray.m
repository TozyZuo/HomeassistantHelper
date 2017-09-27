//
//  HAHObservableArray.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/21.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHObservableArray.h"
#import "HAHProxy.h"

@implementation HAHObservableArray

HAH_CLANG_WARNING_IGNORE_BEGIN(-Wobjc-designated-initializers)

- (instancetype)init
{
    return (id)[HAHProxy proxyWithTarget:[[NSMutableArray alloc] init]];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return (id)[HAHProxy proxyWithTarget:[[NSMutableArray alloc] initWithCapacity:numItems]];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    return (id)[HAHProxy proxyWithTarget:[[NSMutableArray alloc] initWithCoder:aDecoder]];
}

HAH_CLANG_WARNING_IGNORE_END

- (void)injectToSelector:(SEL)selector preprocessor:(id)block{}
- (void)injectToSelector:(SEL)selector postprocessor:(id)block{}

@end
