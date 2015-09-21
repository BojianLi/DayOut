//
//  AddEventViewController.m
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import "AddEventViewController.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController{
    BOOL hasInlineDatePicker;
    NSArray* content;
    NSDateFormatter* dateFormatter;
    NSMutableArray* dateCell;
    NSIndexPath* datePickerIndexPath;
    NSInteger pickerCellRowHeight;
    UIDatePicker *targetDatePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"Add Event";
    
    self.placeLabel.text = self.place[@"name"];
    self.placeImageView.image = self.place[@"image"];
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ mi", self.place[@"distance"]];
    
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
- (IBAction)totalStepperValueChanged:(UIStepper *)sender {
    double v = [sender value];
    [self.totalLabel setText:[NSString stringWithFormat:@"%d people", (int)v]];
}
- (IBAction)offlineStepperValueChanged:(UIStepper *)sender {
    double v = [sender value];
    [self.offlineLabel setText:[NSString stringWithFormat:@"%d people", (int)v]];
}

/*

 
 create_event.php
 POST['name'])
 POST['locid']
 POST['etime']
 POST['off_num']
 POST['on_num']
 POST['kind']
 POST['info']
 POST['cost']
 POST['lat']
 POST['lon']
 

 
*/


- (IBAction)postButtonTouched:(id)sender {
//    NSString *q = [NSString stringWithFormat: @"%@", mySearchBar.text];
    
    
    NSString *eventName = self.place[@"name"];
    NSString *locationID = self.place[@"locationID"];
    
    NSDate *startTime = [[NSDate alloc] init];
    NSDate *endTime = [[NSDate alloc] init];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startTimeString = [df stringFromDate: startTime];
    NSString *endTimeString = [df stringFromDate: endTime];
    
    NSString *offlineString =  [NSString stringWithFormat: @"%d", (int)self.offlineStepper.value];
    NSString *totalString =  [NSString stringWithFormat: @"%d", (int)self.offlineStepper.value];
    
    NSString *tagString = self.tagsTextField.text;
    
    NSString *infoString = self.descriptionTextView.text;
    
    NSString *costString = self.feeTextField.text;
    
    NSString *latString = @"32.2341";
    NSString *lonString = @"-71.4124";
    
    NSString *getString = [NSString stringWithFormat:@"uid=1&name=%@&locid=%@&stime=%@&etime=%@&off_num=%@&on_num=%@&kind=%@&info=%@&cost=%@&lat=%@&lon=%@&tags=%@", eventName,locationID,startTimeString,endTimeString, offlineString, totalString, @"a", infoString, costString, latString, lonString, tagString];
    
    NSString *requestedURL=[NSString stringWithFormat:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/create_event.php?%@", getString];
    
    
    NSLog(@"%@", requestedURL);
    
    NSURL *url = [NSURL URLWithString:[requestedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (error) {
        NSLog(@"Error:%@", error.localizedDescription);
    
    }
    else {
        NSLog(@"POST SUCCESS.");
//        [self loadPlacesWithData: data];
    }
    
    /*
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/create_event.php"]];
    //    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *postString = [NSString stringWithFormat:@"uid=1&name=%@&locid=%@&stime=%@&etime=%@&off_num=%@&on_num=%@&kind=%@&info=%@&cost=%@&lat=%@&lon=%@&tags=%@", eventName,locationID,startTimeString,endTimeString, offlineString, totalString, @"a", infoString, costString, latString, lonString, tagString];
    NSLog(@"%@", postString);
    [request setHTTPBody: [postString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    NSError *error = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"Error:%@", error.localizedDescription);
        //        return NO;
    }
    else {
        NSLog(@"%@",data);
        //        return YES;
    }
     */

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.tableView beginUpdates];
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
//    if([cell.reuseIdentifier isEqual: @"DateCell"]){
//        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//    }else{
//        
//    }
//    [self.tableView endUpdates];
    NSLog(@"fffww");
}


@end
