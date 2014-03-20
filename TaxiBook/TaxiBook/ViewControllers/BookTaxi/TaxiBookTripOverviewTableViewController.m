//
//  TaxiBookTripOverviewTableViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 28/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TaxiBookTripOverviewTableViewController.h"
#import "BookingDetailViewController.h"
#import "TaxiBookBookingSummaryTableViewCell.h"

@interface TaxiBookTripOverviewTableViewController ()

@property (strong, nonatomic) OrderModel *orderModel;

@end

@implementation TaxiBookTripOverviewTableViewController

static NSString *bookingDetailSegueIdentifer = @"viewDetail";

- (OrderModel *)orderModel
{
    if (!_orderModel) {
        // lazy init
        _orderModel = [OrderModel newInstanceWithIdentifier:self.description delegate:self];
    }
    
    return _orderModel;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLoadOrderNotification:) name:TaxiBookNotificationUserLoadOrderData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedLogoutNotification:) name:TaxiBookNotificationUserLoggedOut object:nil];


   // [self.orderModel downloadActiveOrders];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)receivedLoadOrderNotification:(NSNotification *)notification
{
    NSLog(@"in load order data notification");
    //every time login refresh the order list, other occasions, use refresh by scrolling down or trigger by other notification
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadActiveOrders];
}

- (void)receivedLogoutNotification:(NSNotification *)notification
{
    NSLog(@"in logout notification");
    [self.orderModel clearData];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.orderModel count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if ([cell isKindOfClass:[TaxiBookBookingSummaryTableViewCell class]]) {
        TaxiBookBookingSummaryTableViewCell *summaryCell = (TaxiBookBookingSummaryTableViewCell *)cell;
        
        Order *order = [self.orderModel objectAtIndex:indexPath.row];
        [summaryCell.fromLabel setText:order.fromGPS.streetDescription];
        [summaryCell.toLabel setText:order.toGPS.streetDescription];
        [summaryCell.statusLabel setText:[NSString stringWithFormat:@"Status: %@", [Order orderStatusToString:order.orderStatus]]];
        
        return summaryCell;
        
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Order *order = [self.orderModel objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:bookingDetailSegueIdentifer sender:order];
}

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


- (IBAction)pullToRefresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [self.orderModel downloadActiveOrders];
}

#pragma mark - OrderModelDelegate

- (void)finishDownloadOrders:(OrderModel *)orderModel
{
    self.orderModel = orderModel;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)failDownloadOrders:(OrderModel *)orderModel
{
    [self.refreshControl endRefreshing];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([bookingDetailSegueIdentifer isEqualToString:segue.identifier]) {
        
        // sender is the order
        BookingDetailViewController *bookingVC = (BookingDetailViewController *)segue.destinationViewController;
        
        bookingVC.displayOrder = sender;
        
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}



@end
