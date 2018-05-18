//
//  HAHRequest.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2018/5/16.
//  Copyright © 2018年 TozyZuo. All rights reserved.
//

#import "HAHRequest.h"
#import "HAHDataManager.h"

@interface HAHRequest ()
@property (nonatomic, strong) NSString *url;
@end

@implementation HAHRequest

+ (__kindof HAHRequest *(^)(NSString *))GETWithURL
{
    return ^__kindof HAHRequest *(NSString *url) {
        HAHRequest *request = [[self alloc] init];
        request.url = url;
        return request;
    };
}

+ (__kindof HAHRequest *)GET
{
    return self.GETWithURL(nil);
}

- (__kindof HAHRequest *(^)(void (^)(id, NSURLResponse *, NSError *)))completion
{
    return ^__kindof HAHRequest *(void (^completionHandler)(id data, NSURLResponse *response, NSError *error))
    {
        HAHDataManager *dataManager = [HAHDataManager sharedManager];
        NSString *url = self.url ?: [NSString stringWithFormat:@"%@/api/%@?api_password=%@", dataManager.URL, self.api, dataManager.password];
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
        {
            if (completionHandler) {
                if (error) {
                    completionHandler(nil, response, error);
                } else {
                    NSError *e;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
                    HAHLogError(e);
                    completionHandler(jsonObject, response, e);
                }
            }

        }] resume];

        return self;
    };
}

@end


@implementation HAHStatesRequest

- (NSString *)api
{
    return @"states";
}

@end
