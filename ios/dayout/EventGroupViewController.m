//
//  EventGroupViewController.m
//  dayout
//
//  Created by Fred Wu on 9/20/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import "EventGroupViewController.h"
#import "MessageCell.h"
#import "TwoButtonCell.h"




@interface EventGroupViewController (){
    NSMutableDictionary *event;
    NSMutableArray *participants;
    NSMutableArray *messages;
}

@end

@implementation EventGroupViewController



- (BOOL)loadEvents {
    
    
    
    
    NSString *filePath =[[NSBundle mainBundle] pathForResource:@"eventdiscuss" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    
    
    
//    NSString *requestedURL=[NSString stringWithFormat:@"http://ec2-52-26-60-242.us-west-2.compute.amazonaws.com/~wa/wuhack/placeList.php?lat=38.643144&lon=-90.300860"];
//    NSURL *url = [NSURL URLWithString:[requestedURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSData *data =[NSData dataWithContentsOfURL:url];
    
    
    

    NSError *error=nil;
    NSDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    
    
    
    if(error)
    {
        NSLog(@"Error reading file: %@",error.localizedDescription);
        return NO;
    }
    
    event = [returnedData objectForKey:@"data"];
    
    participants = [event objectForKey:@"participants"];
    
    messages = [event objectForKey:@"messages"];
    
    return YES;
    
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self loadEvents];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TwoButtonCell" bundle:nil] forCellReuseIdentifier:@"TwoButtonCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0){
        return 1;
    }else if (section == 1){
        return 5;
    }else if (section == 2){
        return [participants count];
    }else if (section == 3){
        return [messages count];
    }else{
        return  0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"";
            break;
        case 1:
            return @"Event Details";
            break;
        case 2:
            return @"Participants";
            break;
        case 3:
            return @"Messages";
            break;
        default:
            return @"";
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3){
        return 80;
    }else{
        return 40;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(indexPath.section == 0){
        TwoButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoButtonCell" forIndexPath:indexPath];
        [cell.leftButton setTitle: @"Invite a friend" forState:UIControlStateNormal];
        [cell.rightButton setTitle: @"Quit this event" forState:UIControlStateNormal];
        return cell;
    }else if(indexPath.section == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantCell" forIndexPath:indexPath];
        
        if(indexPath.row == 0){
            cell.textLabel.text = @"Starts";
            cell.detailTextLabel.text = event[@"start_time"];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"Ends";
            cell.detailTextLabel.text = event[@"end_time"];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"Address";
            cell.detailTextLabel.text = event[@"address"];
        }else if(indexPath.row == 3){
            cell.textLabel.text = @"Info";
            cell.detailTextLabel.text = event[@"description"];
        }else if(indexPath.row == 4){
            cell.textLabel.text = @"Total";
            cell.detailTextLabel.text = event[@"total"];
        }
        
        
        
        return cell;
    }else if (indexPath.section == 2){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantCell" forIndexPath:indexPath];
        NSDictionary *participant = [participants objectAtIndex:indexPath.row];
        cell.textLabel.text = participant[@"name"];
        cell.detailTextLabel.text = participant[@"join_time"];
        return cell;
    }else if (indexPath.section == 3){
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
        NSDictionary *message = [messages objectAtIndex:indexPath.row];
        cell.messageNameLabel.text = message[@"name"];
        cell.messageTimeLabel.text = message[@"time"];
        cell.messageContentTextView.text = message[@"content"];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParticipantCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Error";
        return cell;
    }

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

@end
