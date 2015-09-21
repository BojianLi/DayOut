//
//  EventSearchTableViewController.m
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import "EventSearchTableViewController.h"
#import "EventTableViewCell.h"

@interface EventSearchTableViewController (){
    NSCache *imageCache;
}

@end

@implementation EventSearchTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    imageCache = [[NSCache alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EventTableViewCell" bundle:nil] forCellReuseIdentifier:@"EventCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    
    
    NSDictionary *event = [self.filteredEvents objectAtIndex:indexPath.row];
    
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
    
    
    NSString *imageURLString = event[@"img"];
    
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
    
    
    return cell;
}
@end
