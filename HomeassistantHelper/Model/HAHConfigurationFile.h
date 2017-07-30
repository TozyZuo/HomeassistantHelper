//
//  HAHConfigurationFile.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/30.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHFile.h"

@class HAHGroupFile, HAHCustomizeFile, HAHEntityModel;

@interface HAHConfigurationFile : HAHFile
@property (readonly) HAHGroupFile       *group;
@property (readonly) HAHCustomizeFile   *customize;

- (void)mergeInfomationWithEntities:(NSArray<HAHEntityModel *> *)entities;

@end
