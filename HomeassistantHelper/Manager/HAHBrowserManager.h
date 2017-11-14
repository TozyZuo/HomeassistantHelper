//
//  HAHBrowserManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHWindowControllerManager.h"

@interface HAHBrowserManager : HAHWindowControllerManager

- (void)loadWithURL:(NSString *)url;

@end

@interface HAHBrowserManagerController : HAHManagerController

@end
