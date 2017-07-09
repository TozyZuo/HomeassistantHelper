//
//  HAHDefine.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#ifndef HAHDefine_h
#define HAHDefine_h

#ifdef DEBUG

#define HAHLOG(...) NSLog(__VA_ARGS__)

#else /* DEBUG */

#define HAHLOG(...)

#endif /* DEBUG */



#endif /* HAHDefine_h */
