//
//  TaxiBookTableViewController.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "TaxiBookTableViewController.h"

@interface TaxiBookTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *originExpandBtn;
@property (weak, nonatomic) IBOutlet UIButton *destExpandBtn;


@end

@implementation TaxiBookTableViewController
BOOL originExpand;
BOOL destExpand;
BOOL timeExpand;

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
    originExpand=false;
    destExpand=false;
    timeExpand=false;
    [self.originExpandBtn setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
    [self.destExpandBtn setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];

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
    [self toggleOriginMap:sender];
}

-(void)toggleOriginMap:(id)sender{
    [sender setContentMode:UIViewContentModeScaleAspectFill];
    if(originExpand){
        originExpand=false;
        [sender clearsContextBeforeDrawing];
        [sender setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
    }else{
        originExpand=true;
        [sender clearsContextBeforeDrawing];
        [sender setBackgroundImage:[UIImage imageNamed:@"collapse.png"] forState:UIControlStateNormal];
    }
    [self.tableView reloadData];

}

- (IBAction)expandDest:(id)sender {
    [self toggleDestMap:sender];
}

-(void)toggleDestMap:(id)sender{
    [sender setContentMode:UIViewContentModeScaleAspectFill];
    if(destExpand){
        destExpand=false;
        [sender clearsContextBeforeDrawing];
        [sender setBackgroundImage:[UIImage imageNamed:@"expand.png"] forState:UIControlStateNormal];
    }else{
        destExpand=true;
        [sender clearsContextBeforeDrawing];
        [sender setBackgroundImage:[UIImage imageNamed:@"collapse.png"] forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if (originExpand) {
            return 364; //expand the cell
        } else {
            return 0; // Hide the cell
        }
        
    }
    if (indexPath.row == 3) {
        if (destExpand) {
            return 364; //expand the cell
        } else {
            return 0; // Hide the cell
        }
    }
    if (indexPath.row == 5) {
        if (timeExpand) {
            return 162; //expand the cell
        } else {
            return 0; // Hide the cell
        }
    }
    return 44;//default height
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select %@", indexPath);
    if(indexPath.row==0){
        //in case the user select the row instead of pressing the btn
        [self toggleOriginMap:self.originExpandBtn];
        
    }else if(indexPath.row==2){
        [self toggleDestMap:self.originExpandBtn];
        
    }else if(indexPath.row==4){
        if(timeExpand){
            timeExpand=false;
        }else{
            timeExpand=true;
        }
        [self.tableView reloadData];
    }
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
