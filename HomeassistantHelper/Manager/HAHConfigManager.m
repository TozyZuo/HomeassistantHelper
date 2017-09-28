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
                  NSDictionary *modelConfigMap = (__bridge_transfer NSDictionary *)CFPropertyListCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListImmutable, NULL, NULL);
                  if (![modelConfigMap isEqualToDictionary:weakSelf.modelConfigMap]) {
                      weakSelf.modelConfigMap = modelConfigMap;
                      NSString *path = [[NSBundle mainBundle] pathForResource:@"modelConfigMap" ofType:@"plist"];
                      if (![modelConfigMap writeToFile:path atomically:NO]) {
                          HAHLOG(@"更新配置文件失败");
                      }
                  }
              }
          }] resume];

    });
}

@end
