//
//  HAHDefine.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#ifndef HAHDefine_h
#define HAHDefine_h

#import <Cocoa/Cocoa.h>


FOUNDATION_EXPORT void CMLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;


#define HAH_CLANG_WARNING_IGNORE_HELPER0(x) #x
#define HAH_CLANG_WARNING_IGNORE_HELPER1(x) HAH_CLANG_WARNING_IGNORE_HELPER0(clang diagnostic ignored x)
#define HAH_CLANG_WARNING_IGNORE_HELPER2(y) HAH_CLANG_WARNING_IGNORE_HELPER1(#y)

#define HAH_CLANG_WARNING_IGNORE_END _Pragma("clang diagnostic pop")
#define HAH_CLANG_WARNING_IGNORE_BEGIN(x)\
_Pragma("clang diagnostic push")\
_Pragma(HAH_CLANG_WARNING_IGNORE_HELPER2(x))

#define HAH_CLANG_WARNING_IGNORE_BEGIN_TWO(x,y)\
_Pragma("clang diagnostic push")\
_Pragma(HAH_CLANG_WARNING_IGNORE_HELPER2(x))\
_Pragma(HAH_CLANG_WARNING_IGNORE_HELPER2(y))


#define HAHLOG(...) if (HAHDebug) { CMLog(__VA_ARGS__); }


#define HAHLogError(error) \
if (error) {\
    HAHLOG(@"%@ %s(%d)", error, __PRETTY_FUNCTION__, __LINE__);\
}

#ifdef DEBUG

#else /* DEBUG */

#endif /* DEBUG */




#endif /* HAHDefine_h */
