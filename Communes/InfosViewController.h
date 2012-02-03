//
//  InfosViewController.h
//  Communes
//
//  Created by Guillaume Bernard on 02/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ville.h"

@interface InfosViewController : UIViewController

@property (strong, nonatomic) Ville                     *detailVille;
@property (strong, nonatomic) IBOutlet UINavigationBar  *navigationBar;
@property (nonatomic,retain)  IBOutlet UINavigationItem *myNavigationItem;

- (IBAction)comeBack:(id)sender;

@end
