//
//  graBeaconManagerTableViewController.m
//  beaconReminderDemo
//
//  Created by li lin on 3/20/14.
//  Copyright (c) 2014 li lin. All rights reserved.
//

#import "graBeaconManagerTableViewController.h"
#import "updateNameViewController.h"
@interface graBeaconManagerTableViewController ()
@property (nonatomic, strong) iBeaconUser *myUser;
@property (nonatomic, strong) NSMutableArray *beaconArray;
@property (nonatomic, strong) CLBeacon *lastFoundBeacon;
@end

@implementation graBeaconManagerTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)beaconArray
{
    if (_beaconArray == Nil) {
        _beaconArray = [[NSMutableArray alloc] init];
    }
    return _beaconArray;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    iBeaconUser *user = [iBeaconUser sharedInstance];
    _myUser = user;
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.myUser startMonitorWithFoundNewBeacon:^(CLBeacon *foundOne){
            ;
        } withKnowBeacon:^(CLBeacon *foundOne){
            NSInteger len = 0;
            for (; len < [self.beaconArray count]; len++) {
                CLBeacon *eachBeacon = [self.beaconArray objectAtIndex:len];
                if ([eachBeacon.proximityUUID isEqual:foundOne.proximityUUID]) {
                    if([eachBeacon.major isEqualToNumber:foundOne.major]){
                        if([eachBeacon.minor isEqualToNumber:foundOne.minor]){
                            [self.beaconArray replaceObjectAtIndex:len withObject:foundOne];
                            [self.tableView reloadData];
                            break;
                        }
                    }
                }
            }
            if (len == [self.beaconArray count]) {
                [self.beaconArray addObject:foundOne];
                [self.tableView reloadData];
            }
        }];
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.beaconArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    CLBeacon *thisOne = self.beaconArray[indexPath.row];
    iBeaconUser *user = [iBeaconUser sharedInstance];
    NSString *uuid =[NSString stringWithFormat:@"%04x %04x", [thisOne.major integerValue], [thisOne.minor integerValue]];
    NSString *distance = nil;
    
    switch (thisOne.proximity) {
        case CLProximityFar:
            distance = @"                                远";
            break;
        case CLProximityNear:
            distance = @"               近";
            break;
        case CLProximityImmediate:
            distance = @" 贴住";
            break;
        default:
            break;
    }
    
    NSString *beaconLocaton = [user findNameByBeacon:thisOne];
    if (beaconLocaton) {
        cell.textLabel.text = beaconLocaton;
        cell.detailTextLabel.text = [uuid stringByAppendingString:distance];
    }else{
        cell.textLabel.text = @"起个名字吧";
        cell.detailTextLabel.text = [uuid stringByAppendingString:distance];
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLBeacon *selectedBeacon = self.beaconArray[indexPath.row];

    updateNameViewController *detailViewController = [[updateNameViewController alloc] initWithNibName:@"updateNameViewController" bundle:nil];
    detailViewController.myBeacon = selectedBeacon;
    [self.navigationController pushViewController:detailViewController animated:YES];
    return;
}


@end
