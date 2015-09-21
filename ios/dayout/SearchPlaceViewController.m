//
//  SearchPlaceViewController.m
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import "SearchPlaceViewController.h"
#import "SearchPlaceResultViewController.h"
#import "SearchCell.h"
#import "PlaceCell.h"
#import "AddEventViewController.h"



@interface SearchPlaceViewController (){
    UISearchBar *mySearchBar;
    NSMutableArray *places;
    unsigned *placesCount;
    NSCache *imageCache;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}


@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) SearchPlaceResultViewController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;




@end




@implementation SearchPlaceViewController



- (BOOL)loadPlacesWithData: (NSData *)data {
    
//    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"placelist" ofType:@"json"];
//    NSData *data2 = [[NSData alloc] initWithContentsOfFile:filePath];
    
    //    NSURL *url=[NSURL URLWithString:str];
    //    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    NSDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSDictionary *wrapdata = [returnedData objectForKey:@"data"];
    
    places = [wrapdata objectForKey:@"places"];
    placesCount = (unsigned)[places count];
    [self.tableView reloadData];
    NSLog(@"OK");
    if(error)
    {
        NSLog(@"Error reading file: %@",error.localizedDescription);
        return NO;
    }else {
        return YES;
    }
    
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationManager requestWhenInUseAuthorization];
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    imageCache = [[NSCache alloc] init];
    
    
//    
//    NSString *latString = [NSString stringWithFormat: @"%f", currentLocation.coordinate.latitude];
//    NSString *lonString = [NSString stringWithFormat: @"%f", currentLocation.coordinate.longitude];
    
    
    NSString *latString = @"38.643144";
    
    NSString *lonString = @"-90.300860";
    
    NSString *getString = [NSString stringWithFormat:@"lat=%@&lon=%@", latString, lonString];
    
    NSString *requestedURL=[NSString stringWithFormat:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/placeList.php?%@", getString];
    
    NSURL *url = [NSURL URLWithString:[requestedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", requestedURL);
    NSError *error = nil;
    //    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (error) {
        NSLog(@"Error:%@", error.localizedDescription);
    }
    else {
        [self loadPlacesWithData: data];
    }
    
    
    

    
    
    
//    [self.tableView registerNib:[UINib nibWithNibName:@"SearchCell" bundle:nil] forCellReuseIdentifier:@"SearchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PlaceCell" bundle:nil] forCellReuseIdentifier:@"PlaceCell"];
    
    
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTap)];
    tapRecon.numberOfTapsRequired = 1;
    
    mySearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-150, 30)];
    mySearchBar.placeholder = @"Search a place!";
//    titleLabel.text = self.titleText;
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.navigationItem.titleView = mySearchBar;
    mySearchBar.delegate = self;
    
    
    [self.navigationItem.titleView setUserInteractionEnabled:YES];
    [self.navigationItem.titleView addGestureRecognizer:tapRecon];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Fail to get your location." preferredStyle:UIAlertControllerStyleAlert];
//    [self presentViewController:alert animated:YES completion:nil];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    currentLocation = [locations firstObject];
    NSLog(@"longitude %f", currentLocation.coordinate.longitude);
    NSLog(@"latitude %f", currentLocation.coordinate.latitude);
    
    if(currentLocation){
        NSString *latString = [NSString stringWithFormat: @"%f", currentLocation.coordinate.latitude];
        NSString *lonString = [NSString stringWithFormat: @"%f", currentLocation.coordinate.longitude];
        
        
    }
    
    [manager stopUpdatingLocation];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return placesCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    UITableViewCell *cell;
//    if (indexPath.row == 0){
//        cell = (SearchCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
//    }else{
    
//    }
    PlaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
    
    NSDictionary *place = [places objectAtIndex:indexPath.row];
    
    cell.placeNameLabel.text = place[@"name"];
    cell.placeDistanceLabel.text = [NSString stringWithFormat:@"%@ mi", place[@"distance"]];
    
    
    NSString *imageURLString = place[@"img"];
    if ([imageURLString isEqual:@""]){
        NSLog(@"None");
        UIImage *image = [UIImage imageNamed: @"placeholder"];
        cell.placeImageView.image = image;
    }else{
        NSURL *imageURL = [NSURL URLWithString: imageURLString];
        UIImage *image = [imageCache objectForKey:imageURL];
        
        if(image){
            cell.placeImageView.image = image;
        }else{
            cell.placeImageView.image = nil;
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                UIImage *aimage = [UIImage imageWithData:data];
                //            UIImage *aimage = [UIImage imageNamed:@"lake"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.placeImageView.image = aimage;
                });
                [imageCache setObject:aimage forKey:imageURL];
            });
        }
        NSLog(@"YES");
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSString *q = [NSString stringWithFormat: @"%@", mySearchBar.text];
    NSString *latString = [NSString stringWithFormat: @"%f", currentLocation.coordinate.latitude];
    NSString *lonString = [NSString stringWithFormat: @"%f", currentLocation.coordinate.longitude];
    
    NSString *getString = [NSString stringWithFormat:@"location=%@&lat=%@&lon=%@",q, latString, lonString];
    
    NSString *requestedURL=[NSString stringWithFormat:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/searchPlace.php?%@", getString];
    
    NSURL *url = [NSURL URLWithString:[requestedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/searchPlace.php"]];
//    //    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
//    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPBody:[[NSString stringWithFormat:@"location=%@&lat=%@&lon=%@",q, latString, lonString] dataUsingEncoding:NSUTF8StringEncoding]];
//    [request setHTTPMethod:@"POST"];
    NSError *error = nil;
    NSURLResponse *response = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (error) {
        NSLog(@"Error:%@", error.localizedDescription);
//        return NO;
    }
    else {
//        NSLog(@"%@",data);
        [self loadPlacesWithData: data];

//        return YES;
    }
    [searchBar resignFirstResponder];
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected");
    //    if(indexPath.section == 0){
    //        note = [self.recentNotes objectAtIndex:indexPath.row];
    //    }else{
    //        note = [self.notes objectAtIndex:indexPath.row];
    //    }
    
    //        NSData *jsonData = note.content;
    
    AddEventViewController *addEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddEventVC"];
    

    NSMutableDictionary *place = [places objectAtIndex:indexPath.row];
    
    
    
    
    
    NSString *imageURLString = place[@"img"];
    if ([imageURLString isEqual:@""]){
        NSLog(@"None");
        UIImage *image = [UIImage imageNamed: @"placeholder"];
        [place setObject:image forKeyedSubscript:@"image"];
    }else{
        NSURL *imageURL = [NSURL URLWithString: imageURLString];
        UIImage *image = [imageCache objectForKey:imageURL];
        
        if(image){
            [place setObject:image forKeyedSubscript:@"image"];
        }else{
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                UIImage *aimage = [UIImage imageWithData:data];
                //            UIImage *aimage = [UIImage imageNamed:@"lake"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [place setObject:aimage forKeyedSubscript:@"image"];
                });
                [imageCache setObject:aimage forKey:imageURL];
            });
        }
        NSLog(@"YES");
    }
    
    addEventVC.place = [NSMutableDictionary dictionaryWithDictionary:place];
    

    
    [self.navigationController pushViewController:addEventVC animated:YES];
}

@end
