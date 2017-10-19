//
//  NSObject_HAH.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/28.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "NSObject_HAH.h"
#import "HAHSOStructDefine.h"
#import "CTBlockDescription.h"
#import <objc/objc-runtime.h>
#import <pthread.h>
#import <dlfcn.h>


static NSString * const HAHSOClassPrefix = @"HAHSONotifying_";
static NSMutableSet *HAHSOClassSet;
static NSMutableSet *HAHSOValidSelectorSet;


id   HAHSOTransmissionFunction(id self, SEL _cmd, ...);
void HAHSOKVOTransmissionFunction(id self, SEL _cmd, ...);
void HAHSOSetArguments(NSInvocation *invocation, NSMethodSignature *signature, NSUInteger startIndex, va_list *ap);

Class HAHSOObjectGetOriginClass(id self);
Class HAHSOObjectGetSOClass(id self); // 防止KVO之后拿到的class不对
Class HAHSOObjectGetSOClass(id self); // 防止KVO之后拿到的class不对
BOOL  HAHSOObjectIsKVOObject(id self);
BOOL  HAHSOObjectEnableSO(id self);
BOOL  HAHSOObjectSetMethodImplementation(id self, SEL _cmd);
BOOL  HAHSOClassOverrideMethod(Class class, SEL sel, id block);
BOOL  HAHSOClassSwizzleMethod(Class class, SEL originSel, SEL newSel, id block);
SEL   HAHSOSelectorToKVO(SEL sel);


@interface HAHObserveSelectorTableModel : NSObject
@property (nonatomic, strong) NSMutableArray *preprocessors;
@property (nonatomic, strong) NSMutableArray *postprocessors;
@end


@interface HAHSOController : NSObject
{
    pthread_mutex_t _lock;
}
@property (nonatomic,  weak ) NSObject *object;
@property (nonatomic, strong) NSString *objectClass;
@property (nonatomic, strong) NSString *objectAddress;
@property (nonatomic, strong) NSMapTable<NSObject */* observers */, NSMutableDictionary<NSString */* selectors */, HAHObserveSelectorTableModel *> *> *observerTable;
@end

@implementation HAHSOController

- (void)dealloc
{
    NSLog(@"%@ %@ %s", self.objectClass, self.objectAddress, __PRETTY_FUNCTION__);
    pthread_mutex_destroy(&_lock);
}

- (instancetype)initWithObject:(NSObject *)object
{
    self = [super init];
    if (self) {
        self.object = object;
        self.objectClass = NSStringFromClass([object class]);
        self.objectAddress = [NSString stringWithFormat:@"%p", object];
        self.observerTable = [NSMapTable weakToStrongObjectsMapTable];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector preprocessor:(id)block
{
    if (!block) {
        return;
    }

    NSAssert([self.object respondsToSelector:selector], @"%@ does not response %@.", self.object, NSStringFromSelector(selector));

    if (![HAHSOValidSelectorSet containsObject:NSStringFromSelector(selector)]) {
        @try {
            [self.object methodSignatureForSelector:selector];
        } @catch (NSException *exception) {
            NSLog(@"-[%@ %@] can not be observed.", [self.object class], NSStringFromSelector(selector));
            return;
        } @finally {
            [HAHSOValidSelectorSet addObject:NSStringFromSelector(selector)];
        }
    }

    pthread_mutex_lock(&_lock);

    HAHSOObjectEnableSO(self.object);
    HAHSOObjectSetMethodImplementation(self.object, selector);

    NSMutableDictionary *selectorTable = [self.observerTable objectForKey:observer];
    if (!selectorTable) {
        selectorTable = [[NSMutableDictionary alloc] init];
        [self.observerTable setObject:selectorTable forKey:observer];
    }
    HAHObserveSelectorTableModel *model = selectorTable[NSStringFromSelector(selector)];
    if (!model) {
        model = [[HAHObserveSelectorTableModel alloc] init];
        selectorTable[NSStringFromSelector(selector)] = model;
    }
    [model.preprocessors addObject:[block copy]];

    pthread_mutex_unlock(&_lock);
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector postprocessor:(id)block
{
    if (!block) {
        return;
    }

    NSAssert([self.object respondsToSelector:selector], @"%@ does not response %@.", self.object, NSStringFromSelector(selector));

    if (![HAHSOValidSelectorSet containsObject:NSStringFromSelector(selector)]) {
        @try {
            [self.object methodSignatureForSelector:selector];
        } @catch (NSException *exception) {
            NSLog(@"-[%@ %@] can not be observed.", [self.object class], NSStringFromSelector(selector));
            return;
        } @finally {
            [HAHSOValidSelectorSet addObject:NSStringFromSelector(selector)];
        }
    }

    pthread_mutex_lock(&_lock);
    
    HAHSOObjectEnableSO(self.object);
    HAHSOObjectSetMethodImplementation(self.object, selector);

    NSMutableDictionary *selectorTable = [self.observerTable objectForKey:observer];
    if (!selectorTable) {
        selectorTable = [[NSMutableDictionary alloc] init];
        [self.observerTable setObject:selectorTable forKey:observer];
    }
    HAHObserveSelectorTableModel *model = selectorTable[NSStringFromSelector(selector)];
    if (!model) {
        model = [[HAHObserveSelectorTableModel alloc] init];
        selectorTable[NSStringFromSelector(selector)] = model;
    }
    [model.postprocessors addObject:[block copy]];

    pthread_mutex_unlock(&_lock);
}

- (void)removeAllObserver
{
    pthread_mutex_lock(&_lock);
    [self.observerTable removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (void)removeObserver:(NSObject *)observer
{
    pthread_mutex_lock(&_lock);
    [self.observerTable removeObjectForKey:observer];
    pthread_mutex_unlock(&_lock);
}

- (void)removeObserver:(NSObject *)observer selector:(SEL)selector
{
    pthread_mutex_lock(&_lock);
    [self.observerTable objectForKey:observer][NSStringFromSelector(selector)] = nil;
    pthread_mutex_unlock(&_lock);
}

- (void)removePreprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector
{
    pthread_mutex_lock(&_lock);
    [[self.observerTable objectForKey:observer][NSStringFromSelector(selector)].preprocessors removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (void)removePostprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector
{
    pthread_mutex_lock(&_lock);
    [[self.observerTable objectForKey:observer][NSStringFromSelector(selector)].postprocessors removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString stringWithFormat:@"<%@:%p", NSStringFromClass([self class]), self];
    [s appendFormat:@" object:<%@:%p>\n", self.objectClass, self.objectAddress];

    pthread_mutex_lock(&_lock);

    [s appendFormat:@"%@", self.observerTable];

    pthread_mutex_unlock(&_lock);
    
    [s appendString:@">"];
    return s;
}

@end


@interface NSObject (HAHObserve_Private)
@property HAHSOController *SOController;
- (BOOL)_isKVOA;
- (void)KVO_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
- (void)KVO_setHidden:(BOOL)hidden;
@end
@implementation NSObject (HAHObserve)

void *HAHSOControllerKey = &HAHSOControllerKey;

- (HAHSOController *)SOController
{
    HAHSOController *controller = objc_getAssociatedObject(self, HAHSOControllerKey);
    if (!controller) {
        controller = [[HAHSOController alloc] initWithObject:self];
        self.SOController = controller;
    }
    return controller;
}

- (void)setSOController:(HAHSOController *)controller
{
    objc_setAssociatedObject(self, HAHSOControllerKey, controller, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isSelectorObserved
{
    return NO;
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector preprocessor:(id)block
{
    [self.SOController addObserver:observer selector:selector preprocessor:block];
}

- (void)addObserver:(NSObject *)observer selector:(SEL)selector postprocessor:(id)block
{
    [self.SOController addObserver:observer selector:selector postprocessor:block];
}

- (void)removeAllObserver
{
    if ([self isSelectorObserved]) {
        [self.SOController removeAllObserver];
    }
}

- (void)removeObserver:(NSObject *)observer
{
    if ([self isSelectorObserved]) {
        [self.SOController removeObserver:observer];
    }
}

- (void)removeObserver:(NSObject *)observer selector:(SEL)selector
{
    if ([self isSelectorObserved]) {
        [self.SOController removeObserver:observer selector:selector];
    }
}

- (void)removePreprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector
{
    if ([self isSelectorObserved]) {
        [self.SOController removePreprocessorsWithObserver:observer selector:selector];
    }
}

- (void)removePostprocessorsWithObserver:(NSObject *)observer selector:(SEL)selector
{
    if ([self isSelectorObserved]) {
        [self.SOController removePostprocessorsWithObserver:observer selector:selector];
    }
}

@end


@implementation HAHObserveSelectorTableModel

- (void)dealloc
{

}

- (NSMutableArray *)preprocessors
{
    if (!_preprocessors) {
        _preprocessors = [[NSMutableArray alloc] init];
    }
    return _preprocessors;
}

- (NSMutableArray *)postprocessors
{
    if (!_postprocessors) {
        _postprocessors = [[NSMutableArray alloc] init];
    }
    return _postprocessors;
}

- (NSString *)descriptionFromBlock:(id)block
{
    struct CTBlockLiteral *blockRef = (__bridge struct CTBlockLiteral *)block;
    struct dl_info info;
    dladdr(blockRef->invoke, &info);
    return [NSString stringWithUTF8String:info.dli_sname];
}

- (NSArray *)descriptionArrayFromArray:(NSArray *)array
{
    NSMutableArray *descriptionArray = [[NSMutableArray alloc] init];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        [descriptionArray addObject:[self descriptionFromBlock:obj]];
    }];

    return descriptionArray;
}

- (NSString *)debugDescription
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.preprocessors.count) {
        dic[@"preprocessors"] = [self descriptionArrayFromArray:self.preprocessors];
    }
    if (self.postprocessors.count) {
        dic[@"postprocessors"] = [self descriptionArrayFromArray:self.postprocessors];
    }

    return [[super description] stringByAppendingFormat:@"%@", dic];
}

- (NSString *)description
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.preprocessors.count) {
        dic[@"preprocessors"] = [self descriptionArrayFromArray:self.preprocessors];
    }
    if (self.postprocessors.count) {
        dic[@"postprocessors"] = [self descriptionArrayFromArray:self.postprocessors];
    }

    return [NSString stringWithFormat:@"%@", dic];
}

@end



id HAHSOTransmissionFunction(id self, SEL _cmd, ...)
{
    Class currentClass = object_getClass(self);
    Class originClass = HAHSOObjectGetOriginClass(self);

    va_list ap;


    va_start(ap, _cmd);
    int f = va_arg(ap, int);


    void *ap2;
    ap2 = (SEL *)&_cmd + sizeof(SEL);

    int a = *(int *)ap2;


    // 调用preprocessors
    for (NSDictionary *selectorTable in [[self SOController] observerTable].objectEnumerator) {
        HAHObserveSelectorTableModel *table = selectorTable[NSStringFromSelector(_cmd)];
        for (id block in table.preprocessors) {

            CTBlockDescription *bd = [[CTBlockDescription alloc] initWithBlock:block];
            NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:bd.blockSignature];
            va_start(ap, _cmd);
            HAHSOSetArguments(blockInvocation, bd.blockSignature, 1, &ap);
            [blockInvocation invokeWithTarget:block];
            va_end(ap);
        }
    }

    // 调用原方法
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:_cmd];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = _cmd;
    va_start(ap, _cmd);
    HAHSOSetArguments(invocation, methodSignature, 2, &ap);
    va_end(ap);

    object_setClass(self, originClass);
    invocation.target = self;
    [invocation invoke];
    object_setClass(self, currentClass);

    // 调用postprocessors
    for (NSDictionary *selectorTable in [[self SOController] observerTable].objectEnumerator) {
        HAHObserveSelectorTableModel *table = selectorTable[NSStringFromSelector(_cmd)];
        for (id block in table.postprocessors) {

            CTBlockDescription *bd = [[CTBlockDescription alloc] initWithBlock:block];
            NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:bd.blockSignature];
            va_start(ap, _cmd);
            HAHSOSetArguments(blockInvocation, bd.blockSignature, 1, &ap);
            [blockInvocation invokeWithTarget:block];
            va_end(ap);
        }
    }

    id returnValue = nil;

    if (methodSignature.methodReturnLength) {
        [invocation getReturnValue:&returnValue];
    }

    return returnValue;
}

void HAHSOKVOTransmissionFunction(id self, SEL _cmd, ...)
{
    va_list ap;

    // 调用preprocessors
    for (NSDictionary *selectorTable in [[self SOController] observerTable].objectEnumerator) {
        HAHObserveSelectorTableModel *table = selectorTable[NSStringFromSelector(_cmd)];
        for (id block in table.preprocessors) {

            CTBlockDescription *bd = [[CTBlockDescription alloc] initWithBlock:block];
            NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:bd.blockSignature];
            va_start(ap, _cmd);
            HAHSOSetArguments(blockInvocation, bd.blockSignature, 1, &ap);
            [blockInvocation invokeWithTarget:block];
            va_end(ap);
        }
    }

    // 调用原方法
    Class class = object_getClass(self);
    Method m = class_getInstanceMethod(class, HAHSOSelectorToKVO(_cmd));
    IMP originIMP = method_getImplementation(m);
    va_start(ap, _cmd);

#define KVOInvokeByType(type)\
type arg = va_arg(ap, type);\
((void (*)(id, SEL, type))originIMP)(self, _cmd, arg);\
break;

    const char *type = [[self methodSignatureForSelector:_cmd] getArgumentTypeAtIndex:2];

    switch (*type) {
        case _C_BOOL:
        case _C_CHR:
        case _C_UCHR:
        case _C_SHT:
        case _C_USHT:
        case _C_INT:
        {KVOInvokeByType(int);}
        case _C_UINT:
        {KVOInvokeByType(unsigned int);}
        case _C_LNG:
        {KVOInvokeByType(long);}
        case _C_ULNG:
        {KVOInvokeByType(unsigned long);}
        case _C_LNG_LNG:
        {KVOInvokeByType(long long);}
        case _C_ULNG_LNG:
        {KVOInvokeByType(unsigned long long);}

        case _C_FLT:
            // 有警告也要加，不能用double
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
        {KVOInvokeByType(float);}
#pragma clang diagnostic pop

        case _C_DBL:
        {KVOInvokeByType(double);}

        case _C_PTR:
        case _C_CHARPTR:
        case _C_ID:
        case _C_CLASS:
        case _C_SEL:
        case _C_ARY_B:
        {KVOInvokeByType(void *);}

        case _C_UNION_B:
        case _C_STRUCT_B:
        {
            NSUInteger size;
            NSGetSizeAndAlignment(type, &size, NULL);

#define CaseSize1(aSize)\
    } else if (size <= aSize) {\
        HAHSOStruct##aSize arg = va_arg(ap, HAHSOStruct##aSize);\
        ((void (*)(id, SEL, HAHSOStruct##aSize))originIMP)(self, _cmd, arg);\

#define CaseSize2(aSize)\
CaseSize1(aSize ## 0)\
CaseSize1(aSize ## 1)\
CaseSize1(aSize ## 2)\
CaseSize1(aSize ## 3)\
CaseSize1(aSize ## 4)\
CaseSize1(aSize ## 5)\
CaseSize1(aSize ## 6)\
CaseSize1(aSize ## 7)\
CaseSize1(aSize ## 8)\
CaseSize1(aSize ## 9)

#define CaseSize3(aSize)\
CaseSize2(aSize ## 0)\
CaseSize2(aSize ## 1)\
CaseSize2(aSize ## 2)\
CaseSize2(aSize ## 3)\
CaseSize2(aSize ## 4)\
CaseSize2(aSize ## 5)\
CaseSize2(aSize ## 6)\
CaseSize2(aSize ## 7)\
CaseSize2(aSize ## 8)\
CaseSize2(aSize ## 9)

            if (NO) {
                CaseSize1(1)
                CaseSize1(2)
                CaseSize1(3)
                CaseSize1(4)
                CaseSize1(5)
                CaseSize1(6)
                CaseSize1(7)
                CaseSize1(8)
                CaseSize1(9)
                CaseSize2(1)
                CaseSize2(2)
                CaseSize2(3)
                CaseSize2(4)
                CaseSize2(5)
                CaseSize2(6)
                CaseSize2(7)
                CaseSize2(8)
                CaseSize2(9)
                CaseSize3(1)
                CaseSize3(2)
                CaseSize3(3)
                CaseSize3(4)
                CaseSize3(5)
                CaseSize3(6)
                CaseSize3(7)
                CaseSize3(8)
                CaseSize3(9)
                CaseSize3(10)
            } else {
                HAHSOStruct1099 s = va_arg(ap, HAHSOStruct1099);
                ((void (*)(id, SEL, HAHSOStruct1099))originIMP)(self, _cmd, s);
            }

            break;
        }
        default:
        {
            NSCAssert(NO, @"Should not be here.");
            break;
        }
    }

    va_end(ap);

    // 调用postprocessors
    for (NSDictionary *selectorTable in [[self SOController] observerTable].objectEnumerator) {
        HAHObserveSelectorTableModel *table = selectorTable[NSStringFromSelector(_cmd)];
        for (id block in table.postprocessors) {

            CTBlockDescription *bd = [[CTBlockDescription alloc] initWithBlock:block];
            NSInvocation *blockInvocation = [NSInvocation invocationWithMethodSignature:bd.blockSignature];
            va_start(ap, _cmd);
            HAHSOSetArguments(blockInvocation, bd.blockSignature, 1, &ap);
            [blockInvocation invokeWithTarget:block];
            va_end(ap);
        }
    }
}

void HAHSOSetArguments(NSInvocation *invocation, NSMethodSignature *signature, NSUInteger startIndex, va_list *ap)
{
    for (NSUInteger i = startIndex; i < signature.numberOfArguments; i++) {

        const char *type = [signature getArgumentTypeAtIndex:i];

#define SetArgumentByType(type)\
    type arg = va_arg(*ap, type);\
    [invocation setArgument:&arg atIndex:i];\
    break;

        switch (*type) {
            case _C_BOOL:
            case _C_CHR:
            case _C_UCHR:
            case _C_SHT:
            case _C_USHT:
            case _C_INT:
            {SetArgumentByType(int);}
            case _C_UINT:
            {SetArgumentByType(unsigned int);}
            case _C_LNG:
            {SetArgumentByType(long);}
            case _C_ULNG:
            {SetArgumentByType(unsigned long);}
            case _C_LNG_LNG:
            {SetArgumentByType(long long);}
            case _C_ULNG_LNG:
            {SetArgumentByType(unsigned long long);}

            case _C_FLT:
                // 有警告也要加，不能用double
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
            {SetArgumentByType(float);}
#pragma clang diagnostic pop

            case _C_DBL:
            {SetArgumentByType(double);}

            case _C_PTR:
            case _C_CHARPTR:
            case _C_ID:
            case _C_CLASS:
            case _C_SEL:
            case _C_ARY_B:
            {SetArgumentByType(void *);}
                
            case _C_UNION_B:
            case _C_STRUCT_B:
            {
                NSUInteger size;
                NSGetSizeAndAlignment([signature getArgumentTypeAtIndex:i], &size, NULL);

#undef CaseSize1
#undef CaseSize2
#undef CaseSize3

#define CaseSize1(aSize)\
    } else if (size <= aSize) {\
        HAHSOStruct##aSize s = va_arg(*ap, HAHSOStruct##aSize);\
        [invocation setArgument:&s atIndex:i];

#define CaseSize2(aSize)\
CaseSize1(aSize ## 0)\
CaseSize1(aSize ## 1)\
CaseSize1(aSize ## 2)\
CaseSize1(aSize ## 3)\
CaseSize1(aSize ## 4)\
CaseSize1(aSize ## 5)\
CaseSize1(aSize ## 6)\
CaseSize1(aSize ## 7)\
CaseSize1(aSize ## 8)\
CaseSize1(aSize ## 9)

#define CaseSize3(aSize)\
CaseSize2(aSize ## 0)\
CaseSize2(aSize ## 1)\
CaseSize2(aSize ## 2)\
CaseSize2(aSize ## 3)\
CaseSize2(aSize ## 4)\
CaseSize2(aSize ## 5)\
CaseSize2(aSize ## 6)\
CaseSize2(aSize ## 7)\
CaseSize2(aSize ## 8)\
CaseSize2(aSize ## 9)

                if (NO) {
                    CaseSize1(1)
                    CaseSize1(2)
                    CaseSize1(3)
                    CaseSize1(4)
                    CaseSize1(5)
                    CaseSize1(6)
                    CaseSize1(7)
                    CaseSize1(8)
                    CaseSize1(9)
                    CaseSize2(1)
                    CaseSize2(2)
                    CaseSize2(3)
                    CaseSize2(4)
                    CaseSize2(5)
                    CaseSize2(6)
                    CaseSize2(7)
                    CaseSize2(8)
                    CaseSize2(9)
                    CaseSize3(1)
                    CaseSize3(2)
                    CaseSize3(3)
                    CaseSize3(4)
                    CaseSize3(5)
                    CaseSize3(6)
                    CaseSize3(7)
                    CaseSize3(8)
                    CaseSize3(9)
                    CaseSize3(10)
                } else {
                    HAHSOStruct1099 s = va_arg(*ap, HAHSOStruct1099);
                    [invocation setArgument:&s atIndex:i];
                }

                break;
            }
            default:
            {
                NSCAssert(NO, @"Can not decode type %s", type);
                break;
            }
        }
    }
}

BOOL HAHSOClassOverrideMethod(Class class, SEL sel, id block)
{
    if (!class_addMethod(class, sel, imp_implementationWithBlock(block), method_getTypeEncoding(class_getInstanceMethod(class_getSuperclass(class), sel))))
    {
        NSLog(@"add method failed -[%@ %@] %s", class, NSStringFromSelector(HAHSOSelectorToKVO(sel)), __PRETTY_FUNCTION__);
        return NO;
    }
    return YES;
}

BOOL HAHSOClassSwizzleMethod(Class class, SEL originSel, SEL newSel, id block)
{
    Method originMethod = class_getInstanceMethod(class, originSel);

    if (!class_addMethod(class, newSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod)))
    {
        NSLog(@"add method failed -[%@ %@] %s", class, NSStringFromSelector(newSel), __PRETTY_FUNCTION__);
        return NO;
    }

    method_setImplementation(originMethod, imp_implementationWithBlock(block));
    
    return YES;
}

SEL HAHSOSelectorToKVO(SEL sel)
{
    return sel_registerName([NSString stringWithFormat:@"KVO_%@", NSStringFromSelector(sel)].UTF8String);
}

Class HAHSOObjectGetOriginClass(id self)
{
    Class soClass = HAHSOObjectGetSOClass(self);
    return soClass ? class_getSuperclass(soClass) : [self class];
}

Class HAHSOObjectGetSOClass(id self)
{
    Class class = object_getClass(self);
//    while (![NSStringFromClass(class) hasPrefix:HAHSOClassPrefix]) {
    while (![HAHSOClassSet containsObject:class]) {
        if (class == [NSObject class] || !class) {
            return nil;
        }
        class = class_getSuperclass(class);
    }
    return class;
}

BOOL HAHSOObjectIsKVOObject(id self)
{
    return [self respondsToSelector:@selector(_isKVOA)] && [self _isKVOA];
}

BOOL HAHSOObjectEnableSO(id self)
{
    if (![self isSelectorObserved]) {

        if (HAHSOObjectIsKVOObject(self))
        {
            Class class = object_getClass(self);

            HAHSOClassSwizzleMethod(class, @selector(removeObserver:forKeyPath:), @selector(KVO_removeObserver:forKeyPath:), ^(NSObject *self, NSObject *observer, NSString *keyPath)
            {
                Class class = object_getClass(self);

                IMP originalIMP = class_getMethodImplementation(class, @selector(KVO_removeObserver:forKeyPath:));
                ((void (*)(id, SEL, id, NSString *))originalIMP)(self, @selector(removeObserver:forKeyPath:), observer, keyPath);

                // 还原
                method_setImplementation(class_getInstanceMethod(class, @selector(removeObserver:forKeyPath:)), originalIMP);

                HAHSOObjectEnableSO(self);
                for (NSDictionary *selectors in self.SOController.observerTable.objectEnumerator) {
                    for (NSString *selector in selectors) {
                        HAHSOObjectSetMethodImplementation(self, NSSelectorFromString(selector));
                    }
                }
            });

            // 重写 isSelectorObserved 方法
            HAHSOClassOverrideMethod(class, @selector(isSelectorObserved), ^BOOL{
                return YES;
            });

            return YES;
        }

        NSString *soClassString = [HAHSOClassPrefix stringByAppendingString:NSStringFromClass(object_getClass(self))];
        Class soClass = NSClassFromString(soClassString);
        if (!soClass) {
            objc_registerClassPair(objc_allocateClassPair(object_getClass(self), soClassString.UTF8String, 0));
            soClass = NSClassFromString(soClassString);

            // 重写 class 方法
            HAHSOClassOverrideMethod(soClass, @selector(class), ^Class(id self, SEL sel){
                return HAHSOObjectGetOriginClass(self);
            });

            // 重写 dealloc 方法
            HAHSOClassOverrideMethod(soClass, NSSelectorFromString(@"dealloc"), ^(NSObject *self, SEL sel)
            {
                NSLog(@"%@ %p %s", object_getClass(self), self, __PRETTY_FUNCTION__);
#ifdef DEBUG
                // 用 observerTable.count 不准，weak object挂掉并没有清理count
                NSUInteger count = 0;
                HAHSOController *controller = self.SOController;
                for (__unused id key in controller.observerTable) {
                    count++;
                }
                if (count) {
                    NSLog(@"An instance %p of class %@ was deallocated while selector observers were still registered with it. Current observation info: %@", self, [self class], controller);
                }
                self.SOController = nil;
#endif
            });

            // 重写 isSelectorObserved 方法
            HAHSOClassOverrideMethod(soClass, @selector(isSelectorObserved), ^BOOL{
                return YES;
            });
        }
        object_setClass(self, soClass);
        [HAHSOClassSet addObject:soClass];
        return YES;
    }
    return NO;
}

BOOL HAHSOObjectSetMethodImplementation(id self, SEL _cmd)
{
    if (HAHSOObjectIsKVOObject(self))
    {
        // KVO 换方法
        Class class = object_getClass(self);

        Method originBackup = class_getInstanceMethod(class, HAHSOSelectorToKVO(_cmd));

        if (!originBackup) {

            // TODO cache IMP
            Method originMethod = class_getInstanceMethod(class, _cmd);
            IMP originIMP = method_getImplementation(originMethod);

            SEL kovSel = HAHSOSelectorToKVO(_cmd);

            if (!class_addMethod(class, kovSel, originIMP, method_getTypeEncoding(originMethod))) {
                NSLog(@"add method failed -[%@ %@] %s", class, NSStringFromSelector(kovSel), __PRETTY_FUNCTION__);
                return NO;
            }

            method_setImplementation(originMethod, (IMP)HAHSOKVOTransmissionFunction);

            return YES;
        }
    }
    else
    {
        // 加方法
        Class originClass = HAHSOObjectGetOriginClass(self);
        Class soClass = HAHSOObjectGetSOClass(self);
        IMP originIMP = class_getMethodImplementation(originClass, _cmd);
        IMP soIMP = class_getMethodImplementation(soClass, _cmd);
        if (originIMP == soIMP) {

            if (!class_addMethod(soClass, _cmd, (IMP)HAHSOTransmissionFunction, method_getTypeEncoding(class_getInstanceMethod(originClass, _cmd)))) {
                NSLog(@"add method failed -[%@ %@] %s", soClass, NSStringFromSelector(_cmd), __PRETTY_FUNCTION__);
                return NO;
            }

            return YES;
        }
    }

    return NO;
}

static void __attribute__((constructor)) HAHSOInitialize(void)
{
    HAHSOClassSet = [[NSMutableSet alloc] init];
    HAHSOValidSelectorSet = [[NSMutableSet alloc] init];
}
