//
//  HAHConfigManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/8/27.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHConfigManager.h"

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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://raw.githubusercontent.com/TozyZuo/HomeassistantHelper/master/HomeassistantHelper/Resource/modelConfigMap.plist"]] queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError)
        {
            if (data && !connectionError) {
                self.modelConfigMap = (__bridge NSDictionary *)CFPropertyListCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)data, kCFPropertyListImmutable, NULL, NULL);
            }
        }];
    });
}

@end
