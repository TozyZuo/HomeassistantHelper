//
//  HAHObservableArray.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/21.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HAHProxyProtocol.h"

@interface HAHObservableArray<ObjectType> : NSMutableArray<ObjectType>
<HAHProxyProtocol>
@end
