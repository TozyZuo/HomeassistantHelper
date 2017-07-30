//
//  HAHEditViewController.m
//  HomeassistantHelper
//
//  Created by TozyZuo on 2017/7/16.
//  Copyright © 2017年 TozyZuo. All rights reserved.
//

#import "HAHEditViewController.h"
#import "HAHGroupModel.h"
#import "HAHPageModel.h"
#import "HAHModelConfigView.h"
#import "HAHPageCollectionViewItem.h"
#import "HAHTableColumn.h"
#import "HAHTableViewCell.h"
#import "NSString_HAH.h"

NSString * const HAHPageCollectionViewItemViewIdentifier = @"HAHPageCollectionViewItemViewIdentifier";
static CGFloat const TableHeaderCellTextMargin = 20;

@interface HAHEditViewController ()
<
    NSCollectionViewDelegate,
    NSCollectionViewDataSource,
    NSTableViewDelegate,
    NSTableViewDataSource
>
@property (weak) IBOutlet NSLayoutConstraint *configViewWidthConstraint;
@property (weak) IBOutlet HAHModelConfigView *configView;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) NSArray<HAHPageModel *> *pages;

@end

@implementation HAHEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView registerClass:[HAHPageCollectionViewItem class] forItemWithIdentifier:HAHPageCollectionViewItemViewIdentifier];
}

#pragma mark - Action

- (IBAction)separateButtonAction:(NSButton *)sender
{
    sender.image = [NSImage imageNamed:sender.state ? @"default_edit_separate_on" : @"default_edit_separate_off"];
    self.configViewWidthConstraint.constant = HAHModelConfigViewWidth - self.configViewWidthConstraint.constant;
}

- (void)clickCellAction:(NSClickGestureRecognizer *)click
{
    [self.configView reloadWithModel:((HAHTableViewCell *)click.view).entity];
}

- (IBAction)tableViewPanAction:(NSPanGestureRecognizer *)pan
{
    NSLog(@"%s(%d)", __PRETTY_FUNCTION__, __LINE__);
    NSPoint p = [pan locationInView:pan.view];

    NSLog(@"%d %d", [self.tableView columnAtPoint:p], [self.tableView rowAtPoint:p]);
    switch (pan.state) {
        case NSGestureRecognizerStateBegan:
        {
            NSPoint p = [pan locationInView:pan.view];

        }
            break;

        default:
            break;
    }
}

#pragma mark - Public

- (void)reloadWithPages:(NSArray<HAHPageModel *> *)pages ungroupedEntities:(NSArray<HAHEntityModel *> *)ungroupedEntities
{
    HAHGroupModel *ungroupedGroup = [[HAHGroupModel alloc] init];
    ungroupedGroup.name = @"未分组";
    ungroupedGroup.shortID = @"ungroupedGroup";
    ungroupedGroup.entities = ungroupedEntities.mutableCopy;

    HAHPageModel *ungroupedPage = [[HAHPageModel alloc] init];
    ungroupedPage.name = @"未分组";
    ungroupedPage.id = @"ungroupedPage";
    ungroupedPage.groups = [[NSMutableArray alloc] initWithObjects:ungroupedGroup, nil];

    NSMutableArray *finalPages = pages.mutableCopy;
    [finalPages insertObject:ungroupedPage atIndex:0];

    self.pages = finalPages;
    [self.collectionView reloadData];

    NSSet *selectionIndexPaths = [NSSet setWithObject:[NSIndexPath indexPathForItem:1 inSection:0]];

    self.collectionView.selectionIndexPaths = selectionIndexPaths;
    [self reloadTableView];
}

#pragma mark - Private

- (void)reloadTableView
{
    // TODO 复用NSTableColumn
    NSArray *columns = self.tableView.tableColumns.copy;
    for (NSTableColumn *column in columns) {
        [self.tableView removeTableColumn:column];
    }

    HAHPageModel *page = self.pages[self.collectionView.selectionIndexPaths.anyObject.item];

    // 算宽度，所有entities中最长
    CGFloat width = 0;
    NSFont *font = [NSFont systemFontOfSize:14];
    for (HAHGroupModel *group in page.groups) {
        width = MAX(width, [group.name ?: group.shortID sizeWithFont:font].width);
        for (HAHEntityModel *entity in group.entities) {
            width = MAX(width, [entity.name ?: entity.id sizeWithFont:font].width);
        }
    }

    width += TableHeaderCellTextMargin;

    for (HAHGroupModel *group in page.groups) {
        HAHTableColumn *column = [[HAHTableColumn alloc] initWithIdentifier:group.shortID];
        column.title = group.name ?: group.shortID;
        column.headerCell.font = font;
        column.group = group;
        column.width = width;
        column.maxWidth = width;
        column.minWidth = [group.name ?: group.shortID sizeWithFont:font].width + TableHeaderCellTextMargin;
        [self.tableView addTableColumn:column];
    }

    [self.tableView reloadData];
}

#pragma mark - NSCollectionViewDelegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    [self reloadTableView];
}

- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{

}

#pragma mark - NSCollectionViewDelegateFlowLayout

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static HAHPageCollectionViewItem *item;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        item = [[HAHPageCollectionViewItem alloc] init];
        [item view];
    });

    HAHPageModel *page = self.pages[indexPath.item];
    if (page.name.length) {
        return NSMakeSize([item widthWithText:page.name], collectionView.height);
    } else if (page.id) {
        return NSMakeSize([item widthWithText:page.id], collectionView.height);
    }
    return NSMakeSize(30, 30);
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - NSCollectionViewDataSource

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pages.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    HAHPageCollectionViewItem *item = [collectionView makeItemWithIdentifier:HAHPageCollectionViewItemViewIdentifier forIndexPath:indexPath];
    HAHPageModel *page = self.pages[indexPath.item];
    item.text = page.name ?: page.id;
    item.size = NSMakeSize([item widthWithText:item.text], collectionView.height);
    return item;
}

#pragma mark - NSTableViewDelegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 22;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(HAHTableColumn *)tableColumn row:(NSInteger)row
{
    if (!tableColumn) {
        return nil;
    }

    if (row < tableColumn.group.entities.count) {
        HAHTableViewCell *cell = [[HAHTableViewCell alloc] init];
        cell.entity = tableColumn.group.entities[row];
        cell.stringValue = cell.entity.name;
        [cell addGestureRecognizer:[[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(clickCellAction:)]];
        return cell;
    } else {
        return nil;
    }

    return nil;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(HAHTableColumn *)tableColumn
{
    [self.configView reloadWithModel:tableColumn.group];
}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forRowIndexes:(NSIndexSet *)rowIndexes
{

}

- (void)tableView:(NSTableView *)tableView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screen
{

}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    [tableView setDropRow: row
       dropOperation: dropOperation];

    NSDragOperation dragOp = NSDragOperationCopy;

    return (dragOp);
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    if (dropOperation == NSTableViewDropOn) {
        // 替换

    } else if (dropOperation == NSTableViewDropAbove) {
        // 插入

    } else {
        NSLog (@"unexpected operation (%d) in %s",
               dropOperation, __FUNCTION__);
    }

    return YES;
}


#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger row = 0;
    for (HAHGroupModel *group in self.pages[self.collectionView.selectionIndexPaths.anyObject.item].groups) {
        row = MAX(row, group.entities.count);
    }
    return row;
}

@end
