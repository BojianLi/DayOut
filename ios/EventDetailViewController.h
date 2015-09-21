//
//  EventDetailViewController.h
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailViewController : UITableViewController


- (instancetype)initWithEvent:(NSDictionary *)event;

@property (strong, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventSummaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventRatingImage;

@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UITextField *requestTextField;

@property (strong, nonatomic) UIImage *eventImage;
@property (strong, nonatomic) NSMutableDictionary *event;
@property (strong, nonatomic) IBOutlet UITableViewCell *startsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *endsCell;

@end
