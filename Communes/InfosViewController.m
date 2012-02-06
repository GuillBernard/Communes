//
//  InfosViewController.m
//  Communes
//
//  Created by Guillaume Bernard on 02/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import "InfosViewController.h"

@implementation InfosViewController

@synthesize detailTown        = _detailTown;
@synthesize navigationBar     = _navigationBar;
@synthesize myNavigationItem  = _myNavigationItem;
@synthesize postalCodeLabel   = _postalCodeLabel;
@synthesize inseeCodeLabel    = _inseeCodeLabel;
@synthesize regionCodeLabel   = _regionCodeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  
  return self;
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc {
  [_detailTown release];
  [_navigationBar release];
  [_myNavigationItem release];
  [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
	_myNavigationItem.title = _detailTown.name;
  _postalCodeLabel.text   = _detailTown.postalCode;
  _inseeCodeLabel.text    = _detailTown.inseeCode;
  _regionCodeLabel.text   = _detailTown.regionCode;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
	return YES;
}

- (IBAction)comeBack:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

@end