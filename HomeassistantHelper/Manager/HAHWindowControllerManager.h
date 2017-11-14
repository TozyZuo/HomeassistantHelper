//
//  HAHWindowControllerManager.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HAHWindowControllerManager : NSWindowController

// 子类需重写返回不同key
@property (nonatomic, readonly) NSString *windowFrameKey;

+ (instancetype)sharedManager;

- (void)toggleDisplay;

@end

@interface HAHManagerController : NSObjectController
@property (nonatomic, readonly) Class managerClass;
@end
