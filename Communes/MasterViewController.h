//
//  MasterViewController.h
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController {
  NSMutableString       *response_;
  NSURLConnection       *connection_;
  NSMutableArray        *towns_;
  NSMutableArray        *copyListOfTown_;
  IBOutlet UISearchBar  *searchBar_;
  BOOL                  searching_;
  BOOL                  letUserSelectRow_;
  long                  totalFileSize_;
  float                 receivedDataBytes_;
}

@property (strong, nonatomic) DetailViewController      *detailViewController;
@property (nonatomic,retain) UIBarButtonItem            *aroundMe;
@property (nonatomic,retain) IBOutlet UIProgressView    *myProgressBar;

- (void)searchTableView;
- (IBAction)aroundMe_Clicked:(id)sender;

@end
