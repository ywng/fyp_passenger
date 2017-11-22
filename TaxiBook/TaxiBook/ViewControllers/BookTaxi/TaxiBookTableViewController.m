//
//  TaxiBookTableViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TaxiBookTableViewController.h"
#import "SubView.h"

@interface TaxiBookTableViewController ()

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (nonatomic) BOOL originExpand;
@property (nonatomic) BOOL destExpand;
@property (nonatomic)BOOL timeExpand;
@property (strong, nonatomic) NSString *dateTimeString;

@end

@implementation TaxiBookTableViewController


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
    self.originExpand= NO;
    self.destExpand= NO;
    self.timeExpand= NO;
    
    // label text is set to current time
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"yyyy-MM-dd    HH:mm";
    self.dateTimeString = [self.formatter stringFromDate:[NSDate date]];
    self.dateTimeLbl.text= self.dateTimeString;
    

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

- (IBAction)expandOrigin:(id)sender {
    [self resignAllResponder];
    [self toggleOriginMap:sender];
}

-(void)toggleOriginMap:(UIButton *)sender{
    if (self.originExpand) {
        [sender setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"collapse"] forState:UIControlStateNormal];
    }
    self.originExpand = !self.originExpand;
    [sender setNeedsDisplay];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)expandDest:(id)sender {
    [self resignAllResponder];
    [self toggleDestMap:sender];
}

-(void)toggleDestMap:(UIButton *)sender{
    if (self.destExpand) {
        [sender setImage:[UIImage imageNamed:@"expand"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"collapse"] forState:UIControlStateNormal];
    }
    self.destExpand= !self.destExpand;
    [sender setNeedsDisplay];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if (self.originExpand) {
            return 364; //expand the cell
        } else {
            return 0; // Hide the cell
        }
        
    }
    if (indexPath.row == 3) {
        if (self.destExpand) {
            return 364; //expand the cell
        } else {
            return 0; // Hide the cell
        }
    }
    if (indexPath.row == 5) {
        if (self.timeExpand) {
            return 162; //expand the cell
        } else {
            return 0; // Hide the cell
        }
    }
    return 44;//default height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self resignAllResponder];
    
    if (indexPath.row==0) {
        //in case the user select the row instead of pressing the btn
        [self toggleOriginMap:self.originExpandBtn];

    } else if(indexPath.row==2) {
        [self toggleDestMap:self.destExpandBtn];
        
    } else if(indexPath.row==4) {
        [self.view bringSubviewToFront:self.timePicker];
        NSLog(@"super view of self.timePicker %@ %@ %@",  NSStringFromCGRect(self.timePicker.bounds),self.timePicker.superview, NSStringFromCGRect(self.timePicker.superview.bounds));
        self.timeExpand = !self.timeExpand;
        [self.tableView reloadInputViews];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)resignAllResponder
{
    [self.originTextField resignFirstResponder];
    [self.destTextField resignFirstResponder];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
