//
//  HAHRequest.h
//  HomeassistantHelper
//
//  Created by TozyZuo on 2018/5/16.
//  Copyright © 2018年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HAHRequest : NSObject
@property (readonly, class) __kindof HAHRequest *(^GETWithURL)(NSString *url);
@property (readonly, class) __kindof HAHRequest *GET;
@property (readonly) __kindof HAHRequest *(^completion)(void (^)(id data, NSURLResponse *response, NSError *error));
@property (nonatomic, strong) NSString *api;
@end


@interface HAHStatesRequest : HAHRequest

@end
