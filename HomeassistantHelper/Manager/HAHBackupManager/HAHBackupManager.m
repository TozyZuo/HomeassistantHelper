//
//  HAHBackupManager.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/11/14.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHBackupManager.h"
#import "HAHDataManager.h"
#import "HAHBackupModel.h"
#import "HAHBackupCell.h"

@interface HAHBackupManager ()
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) HAHBackupModel *backupModel;
@end

@implementation HAHBackupManager

- (void)windowDidLoad
{
    [super windowDidLoad];

    self.tableView.doubleAction = @selector(doubleClickTableViewAction:);
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"HAHBackupCell" bundle:nil] forIdentifier:[HAHBackupCell identifier]];

    NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    indicator.style = NSProgressIndicatorSpinningStyle;
    indicator.center = self.tableView.center;
    [indicator startAnimation:nil];
    [self.tableView addSubview:indicator];

    __weak typeof(self) weakSelf = self;
    [[HAHDataManager sharedManager] requestBackupComplete:^(HAHBackupModel *backup)
    {
        [indicator removeFromSuperview];

        weakSelf.backupModel = backup;
        [weakSelf.tableView reloadData];
    }];
}

- (NSString *)windowFrameKey
{
    return HAHUDBackupWindowFrameKey;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.backupModel.backupFolders.count;
}

#pragma mark - NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 22;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (!tableColumn) {
        return nil;
    }

    HAHBackupCell *cell = [tableView makeViewWithIdentifier:[HAHBackupCell identifier] owner:nil];
    cell.textField.stringValue = self.backupModel.backupFolders[row];

    return cell;
}


- (void)doubleClickTableViewAction:(NSTableView *)tableView
{
    NSInteger selectedRow = tableView.selectedRow;
    if (selectedRow >= 0) {

        NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        indicator.style = NSProgressIndicatorSpinningStyle;
        indicator.center = self.tableView.center;
        [indicator startAnimation:nil];
        [self.tableView.superview addSubview:indicator];

        [[HAHDataManager sharedManager] restoreBackupWithFolder:self.backupModel.backupFolders[selectedRow] complete:^(NSString *result)
        {
            [indicator removeFromSuperview];

            if (result.length) {
                HAHLOG(@"Restore backup failed. %@ %s", result, __PRETTY_FUNCTION__);
            } else {
                // 成功
                [[NSNotificationCenter defaultCenter] postNotificationName:HAHRestorBackupNotification object:self];
            }
        }];
    }
}

@end


@implementation HAHBackupManagerController

- (Class)managerClass
{
    return [HAHBackupManager class];
}

@end
