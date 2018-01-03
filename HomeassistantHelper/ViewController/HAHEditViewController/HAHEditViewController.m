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
#import "NSObject_HAH.h"

NSString * const HAHPageCollectionViewItemViewIdentifier = @"HAHPageCollectionViewItemViewIdentifier";
static CGFloat const TableHeaderCellTextMargin = 20;

typedef struct HAHEditIndex {
    NSInteger pageIndex;
    NSInteger column;
    NSInteger row;
    NSInteger rowCount;
} HAHEditIndex;

@interface HAHEditViewController ()
<
    NSCollectionViewDelegate,
    NSCollectionViewDataSource,
    NSTableViewDelegate,
    NSTableViewDataSource,
    NSGestureRecognizerDelegate
>
@property (weak) IBOutlet NSLayoutConstraint    *configViewWidthConstraint;
@property (weak) IBOutlet HAHModelConfigView    *configView;
@property (weak) IBOutlet NSCollectionView      *collectionView;
@property (weak) IBOutlet NSTableView           *tableView;

@property (nonatomic, strong) HAHTableViewCell  *movingCell;
@property (nonatomic,  weak ) HAHTableViewCell  *selectedCell;
@property (nonatomic, strong) NSView            *groupIndicatorView;
@property (nonatomic, strong) NSArray<HAHPageModel *> *pages;
@property (nonatomic, assign) BOOL              isCommandKeyDown;

@property (nonatomic, readonly) NSInteger       pageIndex;

@end

@implementation HAHEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.groupIndicatorView = [[NSView alloc] init];
    self.groupIndicatorView.height = 1;
    self.groupIndicatorView.wantsLayer = YES;
    self.groupIndicatorView.layer.backgroundColor = [NSColor blueColor].CGColor;

    [self.collectionView registerClass:[HAHPageCollectionViewItem class] forItemWithIdentifier:HAHPageCollectionViewItemViewIdentifier];
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"HAHTableViewCell" bundle:nil] forIdentifier:[HAHTableViewCell identifier]];
}

#pragma mark - Property

- (NSInteger)pageIndex
{
    return self.collectionView.selectionIndexPaths.anyObject.item;
}

#pragma mark - Action

- (IBAction)separateButtonAction:(NSButton *)sender
{
    sender.image = [NSImage imageNamed:sender.state ? @"default_edit_separate_on" : @"default_edit_separate_off"];
    self.configViewWidthConstraint.constant = HAHModelConfigViewWidth - self.configViewWidthConstraint.constant;
}

- (void)clickCellAction:(NSClickGestureRecognizer *)click
{
    self.selectedCell.selected = NO;
    self.selectedCell = (HAHTableViewCell *)click.view;
    self.selectedCell.selected = YES;
    [self.configView reloadWithModel:((HAHTableViewCell *)click.view).entity];
}

- (IBAction)editPanAction:(NSPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case NSGestureRecognizerStateBegan:
        {
            NSPoint p = [pan locationInView:self.tableView];
            NSInteger column = [self.tableView columnAtPoint:p];
            NSInteger row = [self.tableView rowAtPoint:p];

            HAHTableViewCell *cell = [self.tableView viewAtColumn:column row:row makeIfNecessary:NO];

            // gestureRecognizerShouldBegin: 的时候有，但是StateBegan的时候可能没有
            if (!cell) {
                pan.state = NSGestureRecognizerStateFailed;
                return;
            }

            NSView *view = NSApp.keyWindow.contentView;
            HAHTableViewCell *movingCell = cell.copy;
            movingCell.frame = [cell.superview convertRect:cell.frame toView:view];
            [view addSubview:movingCell];
            movingCell.pageIndex = self.pageIndex;
            movingCell.groupIndex = column;
            movingCell.entityIndex = row;
            movingCell.startOrigin = movingCell.origin;
            movingCell.isCopied = self.isCommandKeyDown;
            cell.isCopied = self.isCommandKeyDown;
            self.movingCell = movingCell;
            self.groupIndicatorView.width = movingCell.width;
        }
            break;
        case NSGestureRecognizerStateChanged:
        {
            NSPoint p1 = self.movingCell.startOrigin;
            NSPoint p2 = [pan translationInView:pan.view];
            self.movingCell.origin = NSMakePoint(p1.x + p2.x, p1.y - p2.y);

            HAHEditIndex index = [self editingIndexWithGestureRecognizer:pan];

            if (index.pageIndex != self.pageIndex)
            {
                self.collectionView.selectionIndexPaths = [NSSet setWithObject:[NSIndexPath indexPathForItem:index.pageIndex inSection:0]];
                [self.configView clear];
                [self reloadTableView];
                [self.groupIndicatorView removeFromSuperview];
            }
            else if (index.column >= 0)
            {
                [self.tableView addSubview:self.groupIndicatorView];

                if (index.row == index.rowCount) {
                    NSRect cellFrame = [self.tableView frameOfCellAtColumn:index.column row:index.row - 1];
                    self.groupIndicatorView.top = CGRectGetMaxY(cellFrame) + .5;
                    self.groupIndicatorView.left = CGRectGetMinX(cellFrame);
                    self.groupIndicatorView.width = cellFrame.size.width;
                } else {
                    NSRect cellFrame = [self.tableView frameOfCellAtColumn:index.column row:index.row];
                    self.groupIndicatorView.bottom = CGRectGetMinY(cellFrame) - .5;
                    self.groupIndicatorView.left = CGRectGetMinX(cellFrame);
                    self.groupIndicatorView.width = cellFrame.size.width;
                }
            }
            else
            {
                [self.groupIndicatorView removeFromSuperview];
            }
        }
            break;
        case NSGestureRecognizerStateEnded:
        {
            // 一定要在清理先，要不index不对
            HAHEditIndex index = [self editingIndexWithGestureRecognizer:pan];

            if (index.column >= 0) {

                HAHPageModel *page = self.pages[self.movingCell.pageIndex];
                HAHGroupModel *srcGroup = page.groups[self.movingCell.groupIndex];

                if (!self.movingCell.isCopied) {
                    // 清理
                    [srcGroup.entities removeObjectAtIndex:self.movingCell.entityIndex];
                }

                // 添加
                page = self.pages[self.pageIndex];
                HAHGroupModel *dstGroup = page.groups[index.column];
                if (dstGroup == srcGroup &&
                    index.row > self.movingCell.entityIndex &&
                    !self.movingCell.isCopied)
                {
                    index.row--;
                }
                [dstGroup.entities insertObject:self.movingCell.entity atIndex:index.row];

            }

            [self reloadTableView];
            [self.groupIndicatorView removeFromSuperview];
            [self.movingCell removeFromSuperview];
            self.movingCell = nil;
        }
            break;
        case NSGestureRecognizerStateCancelled:
        {
            [self reloadTableView];
            [self.groupIndicatorView removeFromSuperview];
            [self.movingCell removeFromSuperview];
            self.movingCell = nil;
        }
            break;
        default:
            break;
    }
}

- (void)flagsChanged:(NSEvent *)event
{
    if (!self.pages.count) {
        return;
    }

    BOOL hasCommandKey = (event.modifierFlags & NSEventModifierFlagCommand) > 0;
    if (hasCommandKey && !self.isCommandKeyDown)
    {
        self.isCommandKeyDown = YES;
        if (self.movingCell) {
            self.movingCell.isCopied = YES;
            if (self.movingCell.pageIndex == self.pageIndex) {
                HAHTableViewCell *cell = [self.tableView viewAtColumn:self.movingCell.groupIndex row:self.movingCell.entityIndex makeIfNecessary:NO];
                cell.isCopied = YES;
            }
        }
    }
    else if (!hasCommandKey && self.isCommandKeyDown)
    {
        self.isCommandKeyDown = NO;
        if (self.movingCell) {
            self.movingCell.isCopied = NO;
            if (self.movingCell.pageIndex == self.pageIndex) {
                HAHTableViewCell *cell = [self.tableView viewAtColumn:self.movingCell.groupIndex row:self.movingCell.entityIndex makeIfNecessary:NO];
                cell.isCopied = NO;
            }
        }
    }
}

- (void)keyUp:(NSEvent *)event
{
    unichar key = [event.charactersIgnoringModifiers characterAtIndex:0];
    if (key == NSDeleteCharacter)
    {
        if (self.selectedCell && !self.configView.isEditing) {
            [self.pages[self.pageIndex].groups[[self.tableView columnForView:self.selectedCell]].entities removeObjectAtIndex:[self.tableView rowForView:self.selectedCell]];
            [self reloadTableView];
        }
    }
}

#pragma mark - Public

- (void)reset
{
    self.pages = nil;
    [self.collectionView reloadData];
    [self reloadTableView];
    [self.configView clear];
}

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
    for (HAHPageModel *page in pages) {
        [page removeObserver:self];
        __weak typeof(self) weakSelf = self;
        [page addObserver:self selector:@selector(setName:) postprocessor:^{
            NSInteger index = weakSelf.pageIndex;
            [weakSelf.collectionView reloadData];
            weakSelf.collectionView.selectionIndexPaths = [NSSet setWithObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }];
    }

    [self.collectionView reloadData];
    self.collectionView.selectionIndexPaths = [NSSet setWithObject:[NSIndexPath indexPathForItem:1 inSection:0]];

    [self reloadTableView];
}

#pragma mark - Private

- (void)reloadTableView
{
    self.selectedCell.selected = NO;
    self.selectedCell = nil;

    // TODO 复用NSTableColumn
    NSArray *columns = self.tableView.tableColumns.copy;
    for (NSTableColumn *column in columns) {
        [self.tableView removeTableColumn:column];
    }

    HAHPageModel *page = self.pages[self.pageIndex];

    __weak typeof(self) weakSelf = self;
    for (HAHGroupModel *group in page.groups) {

        [group removeObserver:self];
        [group addObserver:self selector:@selector(setName:) postprocessor:^{
            [weakSelf reloadTableView];
        }];

        // 算宽度，所有entities & group中最长
        NSFont *font = [NSFont systemFontOfSize:14];
        CGFloat width = [group.name sizeWithFont:font].width;
        for (HAHEntityModel *entity in group.entities) {
            width = MAX(width, [entity.name sizeWithFont:font].width);
            [entity removeObserver:self];
            [entity addObserver:self selector:@selector(setName:) postprocessor:^(id info, NSString *name)
             {
                 [weakSelf reloadTableView];
             }];
        }
        width += TableHeaderCellTextMargin;

        HAHTableColumn *column = [[HAHTableColumn alloc] initWithIdentifier:group.shortID];
        column.title = group.name ?: group.shortID;
        column.headerCell.font = font;
        column.group = group;
        column.width = width;
        column.minWidth = width;
        [self.tableView addTableColumn:column];
    }

    [self.tableView reloadData];
}

- (HAHEditIndex)editingIndexWithGestureRecognizer:(NSPanGestureRecognizer *)pan
{
    HAHEditIndex index = (HAHEditIndex){.pageIndex = -1, .column = -1, .row = -1, .rowCount = -1};

    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[pan locationInView:self.collectionView]];
    index.pageIndex = indexPath ? indexPath.item : self.pageIndex;

    // 中心点位置
    NSPoint p = [pan locationInView:self.tableView];

    NSInteger column = [self.tableView columnAtPoint:p];
    if (column >= 0)
    {
        index.column = column;
        NSInteger row = [self.tableView rowAtPoint:p];
        NSInteger rowCount = self.pages[self.pageIndex].groups[column].entities.count;
        index.rowCount = rowCount;
        if (row >= 0 && row < rowCount)
        {
            NSRect cellFrame = [self.tableView frameOfCellAtColumn:column row:row];
            CGFloat cellCenterY = CGRectGetMidY(cellFrame);

            if (p.y < cellCenterY) {
                index.row = row;
            } else {
                index.row = row + 1;
            }
        }
        else
        {
            index.row = rowCount;
        }
    }

    return index;
}

#pragma mark - NSCollectionViewDelegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    NSInteger item = indexPaths.anyObject.item;
    if (item) {
        [self.configView reloadWithModel:self.pages[indexPaths.anyObject.item]];
    } else {
        [self.configView clear];
    }
    [self reloadTableView];
}

- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{

}

#pragma mark - NSCollectionViewDelegateFlowLayout

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HAHPageModel *page = self.pages[indexPath.item];
    if (page.name.length) {
        return NSMakeSize([HAHPageCollectionViewItem widthWithText:page.name], collectionView.height);
    } else if (page.id.length) {
        return NSMakeSize([HAHPageCollectionViewItem widthWithText:page.id], collectionView.height);
    }
    return NSMakeSize(30, 30);
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
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
    [item bindPageModel:page];
    item.size = NSMakeSize([HAHPageCollectionViewItem widthWithText:page.name], collectionView.height);
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
        HAHEntityModel *entity = tableColumn.group.entities[row];
        HAHTableViewCell *cell = [tableView makeViewWithIdentifier:[HAHTableViewCell identifier] owner:nil];
        [cell bindEntityModel:entity];
        [cell addGestureRecognizer:[[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(clickCellAction:)]];

        if (self.movingCell &&
            self.movingCell.entityIndex == row &&
            self.movingCell.pageIndex == self.pageIndex &&
            self.movingCell.groupIndex == [tableView.tableColumns indexOfObject:tableColumn])
        {
            cell.isCopied = self.movingCell.isCopied;
        }

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

- (void)tableView:(NSTableView *)tableView didDragTableColumn:(HAHTableColumn *)tableColumn
{
    HAHPageModel *page = self.pages[self.pageIndex];
    NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
    NSUInteger modelIndex = [page.groups indexOfObject:tableColumn.group];
    if (columnIndex != modelIndex) { // 减少一次save的io
        [page.groups removeObjectAtIndex:modelIndex];
        [page.groups insertObject:tableColumn.group atIndex:columnIndex];
    };
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger row = 0;
    for (HAHGroupModel *group in self.pages[self.pageIndex].groups) {
        row = MAX(row, group.entities.count);
    }
    return row;
}

#pragma mark - NSGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(NSGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[NSPanGestureRecognizer class]]) {

        NSPoint p = [gestureRecognizer locationInView:self.tableView];

        if (CGRectContainsPoint(self.tableView.bounds, p)) {

            NSInteger column = [self.tableView columnAtPoint:p];
            NSInteger row = [self.tableView rowAtPoint:p];

            if (column >= 0 && row >= 0) {
                HAHTableViewCell *cell = [self.tableView viewAtColumn:column row:row makeIfNecessary:NO];
                if (cell) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
