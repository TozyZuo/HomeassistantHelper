//
//  HAHHomeViewController.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/9.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHHomeViewController.h"
#import "HAHEntityModel.h"
#import "HAHPageModel.h"
#import "HAHEditViewController.h"
#import "HAHDataManager.h"
#import "HAHConsoleManager.h"
#import "HAHBrowserManager.h"


@interface HAHHomeViewController ()

@property (weak) IBOutlet NSButton          *readInfoButton;
@property (weak) IBOutlet NSButton          *restartServiceButton;
@property (weak) IBOutlet NSTextField       *addressTextField;
@property (weak) IBOutlet NSTextField       *userNameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (weak) IBOutlet NSButton          *keepPasswordButton;

@property (nonatomic, strong) HAHEditViewController     *editViewController;

@end

@implementation HAHHomeViewController

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];

    for (__kindof NSViewController *childViewController in self.childViewControllers) {
        if ([childViewController isKindOfClass:[HAHEditViewController class]]) {
            self.editViewController = childViewController;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreBackupNotification:) name:HAHRestorBackupNotification object:nil];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.addressTextField.stringValue = [userDefaults objectForKey:HAHUDAdressKey] ?: @"http://192.168.x.x:8123";
    self.userNameTextField.stringValue = [userDefaults objectForKey:HAHUDUserNameKey] ?: @"";
    self.passwordTextField.stringValue = [userDefaults objectForKey:HAHUDPasswordKey] ?: @"";
    self.keepPasswordButton.state = [[userDefaults objectForKey:HAHUDKeepPasswordKey] boolValue];
}

#pragma mark - Action

- (IBAction)readInfoButtonAction:(NSButton *)sender
{
    if (!self.addressTextField.stringValue.length) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"请填写Homeassistant地址";
        [alert addButtonWithTitle:@"确定"];
        [alert runModal];
        return;
    }

    [self disableUI];
    [self.editViewController reset];

    sender.title = @"获取中";

    NSString *url = self.addressTextField.stringValue;
    NSString *user = self.userNameTextField.stringValue.length ? self.userNameTextField.stringValue : self.userNameTextField.placeholderString;
    NSString *password = self.passwordTextField.stringValue.length ? self.passwordTextField.stringValue : self.passwordTextField.placeholderString;
    __weak typeof(self) weakSelf = self;

    [[HAHDataManager sharedManager] requestDataWithURL:url user:user password:password complete:^(NSArray<HAHEntityModel *> *ungroupedEntities, NSArray<HAHPageModel *> *pages)
    {
//        HAHLOG(@"%@", pages);
        sender.title = @"获取";
        [weakSelf enableUI];

        // 记录用户配置
        [[NSUserDefaults standardUserDefaults] setObject:url forKey:HAHUDAdressKey];
        if (weakSelf.userNameTextField.stringValue.length) {
            [[NSUserDefaults standardUserDefaults] setObject:user forKey:HAHUDUserNameKey];
        }
        if (weakSelf.passwordTextField.stringValue.length &&
            weakSelf.keepPasswordButton.state) {
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:HAHUDPasswordKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];

        [weakSelf.editViewController reloadWithPages:pages ungroupedEntities:ungroupedEntities];
    }];

    [[HAHBrowserManager sharedManager] loadWithURL:url];
}

- (IBAction)keepPasswordButtonAction:(NSButton *)sender
{
    if (sender.state) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:HAHUDKeepPasswordKey];
    } else {
        // 取消记住密码，清空记录
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:HAHUDPasswordKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:HAHUDKeepPasswordKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)restartHomeassistantService:(NSButton *)sender
{
    [self disableUI];

    __weak typeof(self) weakSelf = self;
    [[HAHDataManager sharedManager] restartHomeassistantServiceWithComplete:^(NSString *result)
    {
        [weakSelf enableUI];
        if (result.length) {
            HAHLOG(@"重启服务失败 %@", result);
        }
    }];
}

#pragma mark - Notification

- (void)restoreBackupNotification:(NSNotification *)notification
{
    [self readInfoButtonAction:self.readInfoButton];
}

#pragma mark - Private

- (void)disableUI
{
    self.addressTextField.enabled = NO;
    self.userNameTextField.enabled = NO;
    self.passwordTextField.enabled = NO;
    self.readInfoButton.enabled = NO;
    self.restartServiceButton.enabled = NO;
    self.keepPasswordButton.enabled = NO;
}

- (void)enableUI
{
    self.addressTextField.enabled = YES;
    self.userNameTextField.enabled = YES;
    self.passwordTextField.enabled = YES;
    self.readInfoButton.enabled = YES;
    self.restartServiceButton.enabled = YES;
    self.keepPasswordButton.enabled = YES;
}

@end
