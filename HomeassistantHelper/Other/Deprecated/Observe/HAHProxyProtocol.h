//
//  HAHProxyProtocol.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/9/21.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HAHProxyProtocol <NSObject>
- (void)injectToSelector:(SEL)selector preprocessor:(id)block;
- (void)injectToSelector:(SEL)selector postprocessor:(id)block;
@end
