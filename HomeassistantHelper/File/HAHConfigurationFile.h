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
@property (readonly) HAHGroupFile       *groupFile;
@property (readonly) HAHCustomizeFile   *customizeFile;

- (NSArray<HAHEntityModel *> */*ungroupedEntities*/)mergeInfomationWithEntities:(NSArray<HAHEntityModel *> *)entities;

@end
