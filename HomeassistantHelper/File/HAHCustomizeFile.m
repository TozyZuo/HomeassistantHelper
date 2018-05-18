//
//  HAHCustomizeFile.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHCustomizeFile.h"
#import <objc/runtime.h>

@interface HAHCustomizeFileDataPorxy : NSProxy
@property (nonatomic, strong) NSString         *entityID;
@property (nonatomic,  weak ) HAHCustomizeFile *file;
@property (nonatomic,  weak ) id               target;
- (instancetype)initWithEntityID:(NSString *)entityID customizeFile:(HAHCustomizeFile *)file;
@end

@interface HAHCustomizeFile ()
HAH_CLANG_WARNING_IGNORE_BEGIN(-Wobjc-property-synthesis)
@property (nonatomic, strong) NSMutableDictionary<NSString */*id*/, NSMutableDictionary<NSString */*property*/, NSString */*value*/> *> *data;
HAH_CLANG_WARNING_IGNORE_END
@end

@implementation HAHCustomizeFile

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super initWithDictionary:dictionary]) {
        self.data = dictionary.mutableCopy;
    }
    return self;
}

- (NSMutableDictionary<NSString */*property*/, NSString */*value*/> *)objectForKeyedSubscript:(NSString *)key
{
    return (NSMutableDictionary *)[[HAHCustomizeFileDataPorxy alloc] initWithEntityID:key customizeFile:self];
}

- (NSString *)name
{
    return (NSString *)HAHSCustomizeFileName;
}

- (NSString *)debugDescription
{
    return [[super debugDescription] stringByAppendingString:self.data.debugDescription];
}

@end


@implementation HAHCustomizeFileDataPorxy

- (instancetype)initWithEntityID:(NSString *)entityID customizeFile:(HAHCustomizeFile *)file
{
    self.entityID = entityID;
    self.file = file;
    self.target = file.data[entityID];
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.target;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(class_getInstanceMethod([NSMutableDictionary class], sel))];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if (!self.target && [NSStringFromSelector(invocation.selector) hasPrefix:@"set"]) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        self.target = dictionary;
        self.file.data[self.entityID] = dictionary;
        invocation.target = dictionary;
        [invocation invoke];
    }
}

@end
