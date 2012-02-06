//
//  MasterViewController.m
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "Town.h"

#define kUrlCsv @"http://opium.openium.fr/ios/tp4/ville-orig.csv"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize aroundMe             = _aroundMe;
@synthesize myProgressBar        = _myProgressBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Communes", @"Communes");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.clearsSelectionOnViewWillAppear = NO;
      self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
  }
  return self;
}

- (void)dealloc {
  [_detailViewController release];
  [_myProgressBar release];
  [_aroundMe release];
  [response_ release];
  [towns_ release];
  [copyListOfTown_ release];
  [searchBar_ release];
  [connection_ release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
  }
  
  if (!self.detailViewController) {
    self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
  }
  
  _myProgressBar.progress = 0.;
  _detailViewController.myProgressBar.progress = 0;
  
  //the searchBar
  self.tableView.tableHeaderView = searchBar_;
  searchBar_.autocorrectionType = UITextAutocorrectionTypeNo;
  searching_ = NO;
  letUserSelectRow_ = YES;
  copyListOfTown_ = [[NSMutableArray alloc] init];
  
  response_ = [[NSMutableString alloc] init];
  towns_ = [[NSMutableArray alloc] init];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //the Geolocation button
    _aroundMe = [[[UIBarButtonItem alloc] initWithTitle:@"Around Me" style:UIBarButtonItemStyleDone target:self action:@selector(aroundMe_Clicked:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = _aroundMe;
  }
  
  //the connection
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kUrlCsv] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:86400.0];
  connection_ = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  
  if (connection_) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    self.detailViewController.detailDescriptionLabel.text = @"Chargement..";
    [self.detailViewController refresh];
    
  } else {
    NSLog(@"Error during the connection");
  }
  
  [request release];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark - Asynchronous connection
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)inResponse {
  totalFileSize_ = inResponse.expectedContentLength;
}

- (void)connection: (NSURLConnection *) connection didReceiveData:(NSData *)data {
  //get the response from data
  if(data != nil) {
    receivedDataBytes_ += [data length];
    _myProgressBar.progress = receivedDataBytes_ / (float)totalFileSize_;
    _detailViewController.myProgressBar.progress = receivedDataBytes_ / (float)totalFileSize_;
    
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (text != nil) {
      [response_ appendString:text];
      [text release];
    }
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *) inConnection {
  _myProgressBar.hidden = YES;
  _detailViewController.myProgressBar.hidden = YES;
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  self.detailViewController.detailDescriptionLabel.text = @"";
  self.detailViewController.detailDescriptionLabel.hidden = true;
  
  inConnection = nil;
  
  NSArray *array = [response_ componentsSeparatedByString: @"\n"];
  for (int i = 1; i < array.count; i++) {   
    NSArray *tempTownArray = [[array objectAtIndex:i] componentsSeparatedByString: @";"];
    if ([[tempTownArray objectAtIndex:0] isEqualToString:@""]) {
      tempTownArray = nil;
      [tempTownArray release];
      continue;
    }
    
    if (tempTownArray.count == 8 ) {
      Town *town = [[Town alloc] init];
      
      town.name = [tempTownArray objectAtIndex:0];
      town.nameUP = [tempTownArray objectAtIndex:1];
      town.postalCode = [tempTownArray objectAtIndex:2];
      town.inseeCode = [tempTownArray objectAtIndex:3];
      town.regionCode = [tempTownArray objectAtIndex:4];
      
      town.latitude = [[[tempTownArray objectAtIndex:5] stringByReplacingOccurrencesOfString:@","
                                                                                  withString:@"."] floatValue];
      town.longitude = [[[tempTownArray objectAtIndex:6] stringByReplacingOccurrencesOfString:@","
                                                                                   withString:@"."] floatValue];
      town.distance = [[[tempTownArray objectAtIndex:7] stringByReplacingOccurrencesOfString:@","
                                                                                  withString:@"."] floatValue];
      
      [towns_ addObject:town];
      town = nil;
      [town release];
    } else {
      tempTownArray = nil;
      [tempTownArray release];
    }
    
    tempTownArray = nil;
    [tempTownArray release];
  }
  
  self.detailViewController.townArray = towns_;
  [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                   withObject:nil
                                waitUntilDone:NO];
  array = nil;
  [array release];
}

#pragma mark - Around Me
- (IBAction)aroundMe_Clicked:(id)sender {
  [self.navigationController pushViewController:self.detailViewController animated:YES];
  [self.detailViewController aroundMe_Clicked:self];
}

#pragma mark - Search Bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
  searching_ = YES;
  letUserSelectRow_ = NO;
  self.tableView.scrollEnabled = NO;
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if(letUserSelectRow_) {
    return indexPath;
  } else {
    return nil;
  }
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
  //Remove all objects first.
  [copyListOfTown_ removeAllObjects];
  
  if([searchText length] > 0) {
    searching_ = YES;
    letUserSelectRow_ = YES;
    self.tableView.scrollEnabled = YES;
    [self searchTableView];
  } else {
    searching_ = NO;
    letUserSelectRow_ = NO;
    self.tableView.scrollEnabled = NO;
  }
  
  [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)thesearchBar {
  searchBar_.text = @"";
  [searchBar_ resignFirstResponder];
  
  letUserSelectRow_ = YES;
  searching_ = NO;
  self.navigationItem.rightBarButtonItem = nil;
  self.tableView.scrollEnabled = YES;
  
  [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
  [self searchTableView];
}

- (void) searchTableView {
  NSString *searchText = searchBar_.text;
  NSMutableArray *searchArray = [[NSMutableArray alloc] init];
  
  [searchArray addObjectsFromArray:towns_];
  
  for (Town *sTemp in searchArray) {
    NSRange titleResultsRange = [[sTemp name] rangeOfString:searchText options:NSCaseInsensitiveSearch];
    
    if (titleResultsRange.length > 0) {
      [copyListOfTown_ addObject:sTemp];
    }
  }
  
  [searchArray release];
  searchArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (searching_) {
    return [copyListOfTown_ count];
  } else {
    if ([towns_ count] > 0) {
      return [towns_ count] -1;
    } else {
      return 1;
    }
  }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
  }
  
  NSString *text;
  
  if(searching_ && [copyListOfTown_ count] != 0) {
    text = [[NSString alloc] initWithFormat:@"%@", [[copyListOfTown_ objectAtIndex:indexPath.row] name]];
  } else {
    if ([towns_ count] == 0) {
      text = @"Chargement...";
    } else if(towns_.count >=  indexPath.row+1) {
      text = [[NSString alloc] initWithFormat:@"%@", [[towns_ objectAtIndex:indexPath.row+1] name]];
    }
  }
  
  // Configure the cell.
  cell.textLabel.text = NSLocalizedString(text, text);
  
  [text release];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if(!searching_) {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
      }
      self.detailViewController.detailTown = [towns_ objectAtIndex:indexPath.row+1];
      self.detailViewController.townArray = towns_;
      [self.navigationController pushViewController:self.detailViewController animated:YES];
      [self.detailViewController refresh];
    } else {
      self.detailViewController.detailTown = [towns_ objectAtIndex:indexPath.row+1];
      self.detailViewController.townArray = towns_;
      [self.detailViewController refresh];
    }
  } else {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
      if (!self.detailViewController) {
        self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
      }
      self.detailViewController.detailTown = [copyListOfTown_ objectAtIndex:indexPath.row];
      self.detailViewController.townArray = towns_;
      [self.navigationController pushViewController:self.detailViewController animated:YES];
      [self.detailViewController refresh];
    } else {
      self.detailViewController.detailTown = [copyListOfTown_ objectAtIndex:indexPath.row];
      self.detailViewController.townArray = towns_;
      [self.detailViewController refresh];
    }
  }
}

@end