//
//  PersonsViewController.m
//  Workdays
//
//  Created by Andrey Fedorov on 09.02.14.
//  Copyright (c) 2014 Andrey Fedorov. All rights reserved.
//

#import "PersonsViewController.h"
#import "NSIndexPath+Unsigned.h"
#import "PersonsStorage.h"


@implementation PersonsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    // disable swipe left as back action
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshPersonsList];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)applicationWillEnterForeground
{
    [self refreshPersonsList];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)refreshPersonsList
{
    if ([PersonsStorage shouldRefreshDisplayedData]) {
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [PersonsStorage size] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.u_row < [PersonsStorage size]) {
        [PersonsStorage selectPersonAtIndex:indexPath.u_row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell"
                                               forIndexPath:indexPath];
        cell.textLabel.text = [PersonsStorage personName];
        cell.detailTextLabel.text = [PersonsStorage personDetails];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddPersonCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"AddPersonCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessibilityLabel = NSLocalizedString(@"ADD_PERSON_ACCESSBILITY_LABEL", @"Add new person cell");
        }
    }
    return cell;
}


- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [PersonsStorage removePersonAtIndex:indexPath.u_row];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self performSegueWithIdentifier:@"AddPerson"
                                  sender:self];
    }
}


- (NSIndexPath *)              tableView:(UITableView *)tableView
targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                     toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.u_row < [PersonsStorage size]) {
        return proposedDestinationIndexPath;
    } else {
        NSInteger newIndex = [PersonsStorage size] ? [PersonsStorage size] - 1 : 0;
        return [NSIndexPath indexPathForRow:newIndex inSection:proposedDestinationIndexPath.section];
    }
}


- (void) tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
       toIndexPath:(NSIndexPath *)toIndexPath
{
    [PersonsStorage swap:fromIndexPath.u_row
                     and:toIndexPath.u_row];
}


- (BOOL)    tableView:(UITableView *)tableView
canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.u_row < [PersonsStorage size];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEditing]) {
        if (indexPath.u_row == [PersonsStorage size]) {
            return UITableViewCellEditingStyleInsert;
        }
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}


- (IBAction)savePerson:(UIStoryboardSegue *)segue
{
    [PersonsStorage saveCurrentPerson:^(NSUInteger index, BOOL isNew)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                    inSection:0];
        if (isNew) {
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    self.navigationItem.backBarButtonItem.accessibilityLabel = NSLocalizedString(@"BACK_BUTTON", @"Back");
    if ([segue.identifier isEqualToString:@"AddPerson"]) {
        [PersonsStorage selectNewPerson];
    } else if ([segue.identifier isEqualToString:@"ViewPerson"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        [PersonsStorage selectPersonAtIndex:indexPath.u_row];
    }
}


@end
