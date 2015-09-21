//
//  AddEventViewController.h
//  dayout
//
//  Created by Fred Wu on 9/19/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEventViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UIStepper *totalStepper;
@property (strong, nonatomic) IBOutlet UIStepper *offlineStepper;
@property (strong, nonatomic) IBOutlet UITextField *feeTextField;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) IBOutlet UITextField *costTextField;
@property (strong, nonatomic) IBOutlet UILabel *offlineLabel;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) IBOutlet UIImageView *placeImageView;
@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) IBOutlet UILabel *placeLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@property (strong, nonatomic) NSMutableDictionary *place;


@end
