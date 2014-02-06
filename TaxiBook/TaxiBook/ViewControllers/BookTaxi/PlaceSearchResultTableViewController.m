//
//  PlaceSearchResultTableViewController.m
//  TaxiBook
//
//  Created by Chan Ho Pan on 23/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "PlaceSearchResultTableViewController.h"

@interface PlaceSearchResultTableViewController ()

@property (strong, nonatomic) NSArray *resultArray;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *bestLocation;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation PlaceSearchResultTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([CLLocationManager locationServicesEnabled] != NO) {
        
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        [self.locationManager setDistanceFilter:500];
        
        [self.locationManager startUpdatingLocation];
        
    } else {
        NSLog(@"not available");
        
        // load up images to tell user
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    // download the auto complete again
    [self downloadAutoComplete];
}

- (void)downloadAutoComplete
{
    if (self.searchString.length > 0 && self.bestLocation) {
        [GoogleMapPlaceSearchService autoCompleteWithKeyword:self.searchString gpsEnable:YES location:self.bestLocation withDelegate:self];
    } else if (self.searchString.length > 0) {
        [GoogleMapPlaceSearchService autoCompleteWithKeyword:self.searchString gpsEnable:NO location:nil withDelegate:self];
    } else {
        // clear data maybe
    }
}


#pragma mark - GMPlaceSearchServiceDelegate

- (void)finishDownloadPlaceSearch:(NSArray *)places searchType:(PlaceSearchType)searchType
{
    if (searchType == PlaceSearchTypeDetailSearch) {
        // notify the delegate
        if ([places count] > 0) {
            GMPlace *place = [places objectAtIndex:0];
            if (self.delegate && [self.delegate conformsToProtocol:@protocol(PlaceSearchResultDelegate)]) {
                [self.delegate downloadTheExactPlace:place];
            }
        } else {
            [self.delegate downloadTheExactPlace:nil]; // temp solution
        }
    } else if (searchType == PlaceSearchTypeAutoComplete) {
        self.resultArray = places;
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.resultArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    GMPlace *place = [self.resultArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = place.placeDescription;
    cell.detailTextLabel.text = place.placeSecondaryDescription;
    
    return cell;
}



#pragma mark - CLLocationManager
#pragma mark - CLLocationManagerDelegate method

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power
    
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        [self setBestLocation:location];
    }
    
    // Schedule location manager to run again in 10 seconds
    [self.locationManager stopUpdatingLocation];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(turnOnLocationManager)  userInfo:nil repeats:NO];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied) {
        NSLog(@"user denied");
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        NSLog(@"location unknown");
    } else {
        NSLog(@"error: %@", error);
    }
}

- (void)turnOnLocationManager {
    [self.locationManager startUpdatingLocation];
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMPlace *place = [self.resultArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(PlaceSearchResultDelegate)]) {
        [self.delegate userDidSelectThePlaceName:place];
    }
    [GoogleMapPlaceSearchService placeDetail:place.placeReference withDelegate:self];
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
