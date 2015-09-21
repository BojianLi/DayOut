//
//  MessageCell.h
//  dayout
//
//  Created by Fred Wu on 9/20/15.
//  Copyright © 2015 Fred. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *messageNameLabel;
@property (strong, nonatomic) IBOutlet UITextView *messageContentTextView;

@property (strong, nonatomic) IBOutlet UILabel *messageTimeLabel;
@end
