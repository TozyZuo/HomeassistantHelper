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


#ifdef DEBUG

#define HAHLOG(...) CMLog(__VA_ARGS__)

#else /* DEBUG */

#define HAHLOG(...)

#endif /* DEBUG */




#endif /* HAHDefine_h */
