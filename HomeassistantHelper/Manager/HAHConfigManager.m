//
//  HAHConfigManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/27.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHConfigManager.h"

@interface HAHConfigManager ()

@end

@implementation HAHConfigManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modelConfigMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"modelConfigMap" ofType:@"plist"]];
    }
    return self;
}

- (void)updateConfig
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/TozyZuo/HomeassistantHelper/master/HomeassistantHelper/Resource/modelConfigMap.plist"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
          {
              if (data && !error) {
                  weakSelf.modelConfigMap = (__bridge NSDictionary *)CFPropertyListCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListImmutable, NULL, NULL);
              }
          }] resume];

    });
}

@end
