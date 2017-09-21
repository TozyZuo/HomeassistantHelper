//
//  HAHProxy.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/21.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAHProxyProtocol.h"

@interface HAHProxy : NSProxy
<HAHProxyProtocol>
+ (instancetype)proxyWithTarget:(id)target;
@end
