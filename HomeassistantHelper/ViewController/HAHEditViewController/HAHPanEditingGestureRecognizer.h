//
//  HAHPanEditingGestureRecognizer.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/11/15.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol HAHPanEditingGestureRecognizer <NSGestureRecognizerDelegate>
@optional
- (void)flagsChanged:(NSEvent *_Nullable)event;
@end

@interface HAHPanEditingGestureRecognizer : NSPanGestureRecognizer
@property (nullable, weak) id <HAHPanEditingGestureRecognizer> delegate;
@end
