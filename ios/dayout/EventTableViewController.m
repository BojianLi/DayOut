//
//  EventTableViewController.m
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import "EventTableViewController.h"
#import "EventTableViewCell.h"
#import "EventDetailViewController.h"
#import "EventSearchTableViewController.h"

@interface EventTableViewController (){
    NSMutableArray *events;
    unsigned eventsCount;
    NSCache *imageCache;
}


@property (nonatomic, strong) UISearchController *searchController;

// our secondary search results table view
@property (nonatomic, strong) EventSearchTableViewController *resultsTableController;

// for state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;



@end

@implementation EventTableViewController


- (BOOL)loadEvents {
    
    
    
    
//    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"eventslist" ofType:@"json"];
    
    
    
    NSString *requestedURL=[NSString stringWithFormat:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/get_events.php?uid=1&lat=38.643144&lon=-90.300860"];
    
    
    
    NSURL *url = [NSURL URLWithString:[requestedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSData *data =[NSData dataWithContentsOfURL:url];
    
    
    
//    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
//    NSURL *url=[NSURL URLWithString:str];
//    NSData *data=[NSData dataWithContentsOfURL:url];
    NSError *error=nil;
    NSDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSDictionary *wrapdata = [returnedData objectForKey:@"data"];
    
    events = [wrapdata objectForKey:@"events"];
    
    eventsCount = (unsigned)[events count];
    
    
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
    [self loadEvents];
    imageCache = [[NSCache alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"EventTableViewCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
    
    
    // ---- search bar -----
    
    _resultsTableController = [[EventSearchTableViewController alloc] init];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
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
    return eventsCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSLog(@"1");
    
    NSDictionary *event = [events objectAtIndex:indexPath.row];
    
    cell.eventNameLabel.text = event[@"name"];
    cell.eventDistanceLabel.text = [NSString stringWithFormat:@"%@ mi",event[@"distance"]];
    cell.availableLabel.text = [NSString stringWithFormat: @"%@ / %@ available", event[@"available"], event[@"total"]];
    NSDictionary *organizer = event[@"organizer"];
    cell.organizerLabel.text = organizer[@"name"];
    if([organizer[@"gender"] isEqualToString:@"M"]){
        cell.organizerGenderLabel.text = @"♂";
        cell.organizerGenderLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.3 blue:1 alpha:1];
    }else{
        cell.organizerGenderLabel.text = @"♀";
        cell.organizerGenderLabel.backgroundColor = [UIColor colorWithRed:1 green:0.3 blue:0.2 alpha:1];
    }
    cell.organizerDistanceLabel.text = [NSString stringWithFormat:@""];
    
    
    NSString *imageURLString = event[@"img"];
    
    if([imageURLString isEqual: @""]){
        cell.eventImageView.image = [UIImage imageNamed:@"placeholder"];
    }else{
    
        NSURL *imageURL = [NSURL URLWithString: imageURLString];
        UIImage *image = [imageCache objectForKey:imageURL];
        
        if(image){
            cell.eventImageView.image = image;
        }else{
            cell.eventImageView.image = nil;
            dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
            dispatch_async(downloadQueue, ^{
                
                NSData *data = [NSData dataWithContentsOfURL:imageURL];
                UIImage *aimage = [UIImage imageWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.eventImageView.image = aimage;
                });
                [imageCache setObject:aimage forKey:imageURL];
            });
        }
    }
    
    
    
    NSString *startTimeStr = event[@"start_time"];
    NSString *endTimeStr = event[@"end_time"];
    NSDateFormatter *df4Init = [[NSDateFormatter alloc] init];
    [df4Init setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *startTime = [df4Init dateFromString:startTimeStr];
    NSDate *endTime = [df4Init dateFromString:endTimeStr];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM d HH:mm"];
    NSDateFormatter *df2 = [[NSDateFormatter alloc] init];
    [df2 setDateFormat:@"HH:mm"];
    NSString *startTimeString = [df stringFromDate: startTime];
    NSString *endTimeString = [df2 stringFromDate: endTime];
    
    cell.eventTimeLabel.text = [NSString stringWithFormat: @"%@ %@", startTimeString, endTimeString];
    
    NSArray *tags = event[@"tags"];
    
    if([tags count] >= 2){
        NSDictionary *tag1 = [tags objectAtIndex:0];
        cell.eventTag1Label.text = tag1[@"name"];
        NSDictionary *tag2 = [tags objectAtIndex:0];
        cell.eventTag2Label.text = tag2[@"name"];
    }else if([tags count] == 1){
        NSDictionary *tag1 = [tags objectAtIndex:0];
        cell.eventTag1Label.text = tag1[@"name"];
        cell.eventTag2Label.text = @"";
    }else{
        cell.eventTag1Label.text = @"";
        cell.eventTag2Label.text = @"";
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
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






#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}



#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [events mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
        //
        // example if searchItems contains "iphone 599 2007":
        //      name CONTAINS[c] "iphone"
        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
        //
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // Below we use NSExpression represent expressions in our predicates.
        // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        
        lhs = [NSExpression expressionForKeyPath:@"tags"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
        //        NSExpression *lhs2 = [NSExpression expressionForKeyPath:@"text_content"];
        //        NSExpression *rhs2 = [NSExpression expressionForConstantValue:searchString];
        
    }
    
    // match up the fields of the Product object
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    // hand over the filtered results to our search results table
    EventSearchTableViewController *tableController = (EventSearchTableViewController *)self.searchController.searchResultsController;
    tableController.filteredEvents = searchResults;
    [tableController.tableView reloadData];
}


#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}



/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Selected");
    //    if(indexPath.section == 0){
    //        note = [self.recentNotes objectAtIndex:indexPath.row];
    //    }else{
    //        note = [self.notes objectAtIndex:indexPath.row];
    //    }
    
    //        NSData *jsonData = note.content;
    
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    EventDetailViewController *eventDetailVC = segue.destinationViewController;
    
    NSDictionary *event = [events objectAtIndex:path.row];
    
    NSString *imageURLString = event[@"img"];
    NSURL *imageURL = [NSURL URLWithString: imageURLString];
    UIImage *image = [imageCache objectForKey:imageURL];
    
    if(image){
        eventDetailVC.eventImageView.image = image;
    }else{
        eventDetailVC.eventImageView.image = nil;
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:imageURL];
            UIImage *aimage = [UIImage imageWithData:data];
            //            UIImage *aimage = [UIImage imageNamed:@"lake"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                eventDetailVC.eventImageView.image = aimage;
            });
            [imageCache setObject:aimage forKey:imageURL];
        });
    }
    
    eventDetailVC.eventNameLabel = event[@"name"];
    
    
    [self.navigationController pushViewController:eventDetailVC animated:YES];
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
    
    EventDetailViewController *eventDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailVC"];
    
    
    
    NSDictionary *event = [events objectAtIndex:indexPath.row];
//    EventDetailViewController *eventDetailVC = [[EventDetailViewController alloc] initWithEvent: event];
    
    
    NSString *imageURLString = event[@"img"];
    NSURL *imageURL = [NSURL URLWithString: imageURLString];
    UIImage *image = [imageCache objectForKey:imageURL];
    
    if(image){
        eventDetailVC.eventImage = image;
    }else{
        eventDetailVC.eventImage = nil;
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:imageURL];
            UIImage *aimage = [UIImage imageWithData:data];
            //            UIImage *aimage = [UIImage imageNamed:@"lake"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                eventDetailVC.eventImage = aimage;
            });
            [imageCache setObject:aimage forKey:imageURL];
        });
    }
    
    eventDetailVC.event = [NSMutableDictionary dictionaryWithDictionary:event];
    eventDetailVC.eventImage = image;
    
    

    [self.navigationController pushViewController:eventDetailVC animated:YES];
}




@end
