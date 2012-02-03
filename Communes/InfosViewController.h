//
//  InfosViewController.h
//  Communes
//
//  Created by Guillaume Bernard on 02/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Town.h"

@interface InfosViewController : UIViewController

@property (strong, nonatomic) Town                      *detailTown;
@property (strong, nonatomic) IBOutlet UINavigationBar  *navigationBar;
@property (nonatomic,retain)  IBOutlet UINavigationItem *myNavigationItem;
@property (nonatomic,retain)  IBOutlet UILabel          *postalCodeLabel;
@property (nonatomic,retain)  IBOutlet UILabel          *inseeCodeLabel;
@property (nonatomic,retain)  IBOutlet UILabel          *regionCodeLabel;

- (IBAction)comeBack:(id)sender;

@end
