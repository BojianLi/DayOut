//
//  EventDetailViewController.m
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import "EventDetailViewController.h"

@interface EventDetailViewController (){
//    NSDictionary *thisEvent;
    BOOL isSendButton;
}

@end

@implementation EventDetailViewController


//- (instancetype)initWithEvent:(NSDictionary *)event{
////    self = [super init];
//    UIStoryboard*  sb = [UIStoryboard storyboardWithName:@"Main"
//                                                  bundle:nil];
//    self = [sb instantiateViewControllerWithIdentifier:@"EventDetailVC"];
////    self.eventNameLabel.text = thisEvent;
//    thisEvent = event;
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    isSendButton = NO;
    self.title = @"Event Details";
    self.requestTextField.hidden = YES;
    self.eventNameLabel.text = self.event[@"name"];
    self.eventImageView.image = self.eventImage;
//    self.ratingImageView.image = self.event[@"rating_img"];
    self.startsCell.detailTextLabel.text = self.event[@"start_time"];
    self.endsCell.detailTextLabel.text = self.event[@"end_time"];
    
//    NSDate *startTime = NSDate
    
    NSString *startTimeStr = self.event[@"start_time"];
    NSString *endTimeStr = self.event[@"end_time"];
    NSDateFormatter *df4Init = [[NSDateFormatter alloc] init];
    [df4Init setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *startTime = [df4Init dateFromString:startTimeStr];
    NSDate *endTime = [df4Init dateFromString:endTimeStr];
    
    NSTimeInterval secondsBetween = [endTime timeIntervalSinceDate:startTime];
    
    int numberOfHours = secondsBetween / 3600;
    
    NSString *eventDurationString;
    
    if (numberOfHours < 4){
        eventDurationString = [NSString stringWithFormat:@"%d hours", numberOfHours];
    }else if (numberOfHours < 8){
        eventDurationString = @"half day";
    }else if (numberOfHours < 20){
        eventDurationString = @"a day";
    }else{
        eventDurationString = [NSString stringWithFormat:@"%d days", ((numberOfHours+4)/24 + 1)];
    }
    
//    NSLog(startTime);
    
    NSString *distanceString = self.event[@"distance"];
    int total = [self.event[@"total"] intValue];
    
    NSString *eventSummaryString = [NSString stringWithFormat:@"%@ mi, %d people for %@", distanceString, total, eventDurationString];
    
    self.eventSummaryLabel.text = eventSummaryString;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
- (IBAction)joinButtonTouched:(id)sender {
    if(isSendButton){
        isSendButton = NO;
        
        
        /*
         
         join_event.php
         POST['uid']
         POST['eid']
         
         */
        
        
        
        //NSString *eid = self.event[@"id"];
        
        NSString *eid = self.event[@"locid"];
        
        
        NSString *requestedURL=[NSString stringWithFormat:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/join_event.php?uid=1&eid=%@", eid];
        
        NSURL *url = [NSURL URLWithString:[requestedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *data =[NSData dataWithContentsOfURL:url];
        
        NSError *error=nil;
        NSDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        
        
        if(error)
        {
            NSLog(@"Error reading file: %@",error.localizedDescription);
            
        }else {
            self.joinButton.enabled = NO;
            self.requestTextField.hidden = YES;
            [self.joinButton setTitle:@"Applied" forState: UIControlStateNormal];
        }
    }else{
        self.requestTextField.hidden = NO;
        [self.joinButton setTitle:@"Send" forState:UIControlStateNormal];
        isSendButton = YES;
    }
    
}

@end
