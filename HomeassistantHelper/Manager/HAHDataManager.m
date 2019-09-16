//
//  HAHDataManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHDataManager.h"
#import "HAHEntityParser.h"
#import "HAHGroupModel.h"
#import "HAHPageModel.h"
#import "HAHBackupModel.h"
#import "HAHConfigurationFile.h"
#import "HAHGroupFile.h"
#import "HAHRequest.h"
#import "HAHParser.h"
#import <NMSSH/NMSSH.h>


//#define LoadFileFromLocal // 本地开发测试

static NSString * const HAHBackupFolder = @"HomeassistantHelperBackup";

#ifdef LoadFileFromLocal

static NSString * const HAHHomeassistantPath = @"/Homeassistant/";

#else

//static NSString * const HAHHomeassistantPath = @"/home/homeassistant/.homeassistant/";
static NSString * const HAHHomeassistantPath = @"/usr/share/hassio/homeassistant/";

#endif


@interface HAHDataManager ()

// public
@property (nonatomic, strong) NSString              *URL;
@property (nonatomic, strong) NSString              *user;
@property (nonatomic, strong) NSString              *password;

// private
@property (nonatomic, strong) NSMutableSet          *filesToSave;
@property (nonatomic, strong) dispatch_queue_t      sshQueue;
@property (nonatomic, strong) NMSSHSession          *session;
@property (nonatomic, strong) NSArray<HAHEntityModel *> *entities;
@property (nonatomic, strong) HAHConfigurationFile  *configurationFile;

@property (nonatomic,  copy ) void (^requestDataCompleteBlock)(NSArray<HAHEntityModel *> *, NSArray<HAHPageModel *> *);
@end

@implementation HAHDataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sshQueue = dispatch_queue_create("HAH.ssh.queue", DISPATCH_QUEUE_SERIAL);
        self.filesToSave = [[NSMutableSet alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateNotification:) name:NSApplicationWillTerminateNotification object:nil];
    }
    return self;
}

#pragma mark - Notification

- (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    [self.session disconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (void)requestDataWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password complete:(void (^)(NSArray<HAHEntityModel *> *, NSArray<HAHPageModel *> *))completeBlock
{
    self.requestDataCompleteBlock = completeBlock;
    self.entities = nil;
    self.configurationFile = nil;
    self.URL = url;
    self.user = user;
    self.password = password;

#ifndef LoadFileFromLocal
    [self initializeSSHWithURL:url user:user password:password];
#endif

    [self startEntitiesRequestWithURL:url];
    [self startFileRequest];
}

- (void)requestBackupWithComplete:(void (^)(HAHBackupModel *))completeBlock
{
    dispatch_async(self.sshQueue, ^{

        NSString *result = [self execute:@"ls", @"-t", [NSString stringWithFormat:@"%@%@", HAHHomeassistantPath, HAHBackupFolder], nil];
        HAHBackupModel *backupModel = [[HAHBackupModel alloc] init];
        backupModel.backupFolders = [[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"\n"];
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(backupModel);
            });
        }
    });
}

- (void)saveFile:(HAHFile *)file
{
    // 多次保存同一个文件，只保存一次
    [self.filesToSave addObject:file];

    // 下个loop一起保存
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        // 子线程保存
        dispatch_async(self.sshQueue, ^{

            if (self.filesToSave.count) {

                HAHFile *file = self.filesToSave.anyObject;

                if ([self backupFile:file.name]) {
                    [self execute:@"echo", [NSString stringWithFormat:@"\"%@\" > %@%@", file.text, HAHHomeassistantPath, file.name], nil];
                }

                [self.filesToSave removeObject:file];
            }

        });
    });
}

- (void)restoreBackupWithFolder:(NSString *)folder complete:(void (^)(NSString *))completeBlock
{
    dispatch_async(self.sshQueue, ^{

        NSString *result = [self execute:@"cp", [NSString stringWithFormat:@"%@%@/%@/*", HAHHomeassistantPath, HAHBackupFolder, folder], HAHHomeassistantPath, nil];

        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }
    });
}

- (void)restartHomeassistantServiceWithComplete:(void (^)(NSString *))completeBlock
{
    HAHLOG(@"重启服务");
    dispatch_async(self.sshQueue, ^{
        NSString *result = [self execute:@"systemctl restart home-assistant@homeassistant.service", nil];
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(result);
            });
        }
    });
}

#pragma mark - Private

- (void)initializeSSHWithURL:(NSString *)url user:(NSString *)user password:(NSString *)password
{
    if (self.session && self.session.isAuthorized) {
        return;
    }

    dispatch_async(self.sshQueue, ^{

        self.session = [NMSSHSession connectToHost:[NSURL URLWithString:url].host withUsername:user];

        if (self.session.isConnected) {
            [self.session authenticateByPassword:password];

            if (self.session.isAuthorized) {
                HAHLOG(@"SSH通道建立");
            } else {
                HAHLOG(@"SSH连接失败，请检查用户名密码是否正确");
                [self callBackFailure];
            }
        } else {
            HAHLOG(@"SSH连接失败，请检查IP和端口是否正确");
            [self callBackFailure];
        }
    });
}

- (void)startEntitiesRequestWithURL:(NSString *)url
{
#ifdef LoadFileFromLocal

    self.entities = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%@entities", HAHHomeassistantPath]];
    [self tryToCallBack];

#else
    HAHLOG(@"请求设备信息");

    HAHStatesRequest.GET.completion(^(id data, NSURLResponse *response, NSError *error) {
        if (error) {
            HAHLOG(@"设备信息请求失败 %@", error);
            [self callBackFailure];
        } else {
            HAHLOG(@"设备信息请求成功");
            self.entities = [HAHEntityParser parse:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self tryToCallBack];
            });
        }
    });

#endif
}

- (void)startFileRequest
{
#ifdef LoadFileFromLocal

    self.configurationFile = [[HAHConfigurationFile alloc] initWithDictionary:[HAHParser parseYAML:[self requestFile:(NSString *)HAHSConfigurationFileName]]];
    [self tryToCallBack];

#else

    dispatch_async(self.sshQueue, ^{

        if (self.session.isAuthorized) {

            HAHLOG(@"请求配置文件数据");
            self.configurationFile = [[HAHConfigurationFile alloc] initWithDictionary:[HAHParser parseYAML:[self requestFile:(NSString *)HAHSConfigurationFileName]]];

            if (self.configurationFile) {
                HAHLOG(@"配置文件请求成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self tryToCallBack];
                });
            } else {
                HAHLOG(@"配置文件请求失败，请点击\"获取\"按钮重试");
            }

        }
    });

#endif
}

- (void)tryToCallBack
{
    if (self.requestDataCompleteBlock && self.entities && self.configurationFile)
    {
        NSArray *ungroupedEntities = [self.configurationFile mergeInfomationWithEntities:self.entities];
        self.requestDataCompleteBlock(ungroupedEntities, self.configurationFile.groupFile.pages);
        self.requestDataCompleteBlock = nil;
    }
}

- (void)callBackFailure
{
    if (self.requestDataCompleteBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.requestDataCompleteBlock(nil, nil);
        });
    }
}

#pragma mark SSH

- (NSString *)execute:(NSString *)command, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:command];

    va_list ap;
    va_start(ap, command);
    NSString *arg;
    while ((arg = va_arg(ap, NSString *))) {
        [arguments addObject:arg];
    }
    va_end(ap);

#ifdef LoadFileFromLocal

    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c", [arguments componentsJoinedByString:@" "]];
    task.currentDirectoryPath = HAHHomeassistantPath;

    NSPipe *pipe = [NSPipe pipe];
    task.standardOutput = pipe;

    NSFileHandle *fileHandle = pipe.fileHandleForReading;

    [task launch];

    return [[NSString alloc] initWithData:[fileHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];

#else

    [arguments insertObject:@"sudo" atIndex:0];

    NSError *error;
    NSString *result = [self.session.channel execute:[arguments componentsJoinedByString:@" "] error:&error];
    HAHLogError(error);
    return result;
    
#endif
}

- (NSString *)requestFile:(NSString *)fileName
{
    return [self execute:@"cat", [NSString stringWithFormat:@"%@%@", HAHHomeassistantPath, fileName], nil];
}

- (BOOL)createFolderWithPath:(NSString *)path folderName:(NSString *)folderName
{
    NSString *result = [self execute:@"ls", path, nil];
    if (![result containsString:folderName]) {
        NSString *fullPath = [NSString stringWithFormat:@"%@%@%@", path, [path hasSuffix:@"/"] ? @"" : @"/", folderName];
        NSString *result = [self execute:@"mkdir", fullPath, nil];
        if (result.length) {
            HAHLOG(@"Create folder error %@ \n%@\n %s", fullPath, result,  __PRETTY_FUNCTION__);
            return NO;
        }
        return YES;
    }
    return YES;
}

- (BOOL)backupFile:(NSString *)fileName
{
    if ([self createFolderWithPath:HAHHomeassistantPath folderName:HAHBackupFolder])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyyMMdd";
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        NSString *today = [dateFormatter stringFromDate:[NSDate date]];

        NSString *backupPath = [NSString stringWithFormat:@"%@%@/", HAHHomeassistantPath, HAHBackupFolder];

        if ([self createFolderWithPath:backupPath folderName:today])
        {
            NSString *result = [self execute:@"cp", @"-n", [NSString stringWithFormat:@"%@%@", HAHHomeassistantPath, fileName], [NSString stringWithFormat:@"%@%@/%@", backupPath, today, fileName], nil];
            if (result.length) {
                HAHLOG(@"Back %@ up error! \n%@\n %s", fileName, result,  __PRETTY_FUNCTION__);
                return NO;
            }
            return YES;
        }
        return NO;
    }
    return NO;
}


@end
