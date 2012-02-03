//
//  MasterViewController.h
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController
{
    NSMutableString         *response;
    NSURLConnection         *connection;
    NSMutableArray          *townArray;
    NSMutableArray          *copyListOfTown;
    IBOutlet UISearchBar    *searchBar;
    BOOL                     searching;
    BOOL                     letUserSelectRow;
    long                     totalFileSize;
    float                    receivedDataBytes;
}

- (void) searchTableView;
- (IBAction) aroundMe_Clicked:(id)sender;

@property (strong, nonatomic) DetailViewController      *detailViewController;
@property (nonatomic,retain) UIBarButtonItem            *aroundMe;
@property (nonatomic,retain) IBOutlet UIProgressView    *myProgressBar;

@end
