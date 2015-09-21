//
//  EventTableViewCell.h
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *availableLabel;
@property (strong, nonatomic) IBOutlet UILabel *organizerLabel;
@property (strong, nonatomic) IBOutlet UILabel *organizerDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *organizerGenderLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventTag1Label;
@property (strong, nonatomic) IBOutlet UILabel *eventTag2Label;

@end
