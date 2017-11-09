//
//  HAHGroupFile.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHFile.h"

@class HAHPageModel;

@interface HAHGroupFile : HAHFile
@property (readonly) NSMutableArray<HAHPageModel *> *pages;
@end
