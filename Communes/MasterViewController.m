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

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize aroundMe = _aroundMe;
@synthesize myProgressBar = _myProgressBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
							
- (void)dealloc
{
    [_detailViewController release];
    [_myProgressBar release];
    [_aroundMe release];
    [response release];
    [townArray release];
    [copyListOfTown release];
    [searchBar release];
    [connection release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
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
    self.tableView.tableHeaderView = searchBar;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searching = NO;
    letUserSelectRow = YES;
    copyListOfTown = [[NSMutableArray alloc] init];
    
    response = [[NSMutableString alloc] init];
    townArray = [[NSMutableArray alloc] init];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    //the Geolocation button
        _aroundMe = [[[UIBarButtonItem alloc] initWithTitle:@"Around Me" style:UIBarButtonItemStyleDone target:self action:@selector(aroundMe_Clicked:)] autorelease];
    
        self.navigationItem.rightBarButtonItem = _aroundMe;
    }
    
    //the connection
    //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://opium.openium.fr/ios/tp4/ville-light.csv"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:86400.0];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://opium.openium.fr/ios/tp4/ville-orig.csv"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:86400.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(connection)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        self.detailViewController.detailDescriptionLabel.text = @"Chargement..";
        [self.detailViewController refresh];
        
    }
    else
    {
        NSLog(@"Error during the connection");
    }
    [request release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark - Asynchronous connection
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)inResponse {
    totalFileSize = inResponse.expectedContentLength;
}

- (void)connection: (NSURLConnection *) connection didReceiveData:(NSData *)data
{
    //get the response from data
    if(data != nil)
    {
        receivedDataBytes += [data length];
        _myProgressBar.progress = receivedDataBytes / (float)totalFileSize;
        _detailViewController.myProgressBar.progress = receivedDataBytes / (float)totalFileSize;
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (text != nil) {
            [response appendString:text];
            [text release];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *) inConnection
{
    _myProgressBar.hidden = YES;
    _detailViewController.myProgressBar.hidden = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.detailViewController.detailDescriptionLabel.text = @"";
    self.detailViewController.detailDescriptionLabel.hidden = true;
    
    inConnection = nil;
    
    NSArray *array = [response componentsSeparatedByString: @"\n"];
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
            
            [townArray addObject:town];
            town = nil;
            [town release];
        }
        else
        {
            tempTownArray = nil;
            [tempTownArray release];
        }
        tempTownArray = nil;
        [tempTownArray release];
    }
    
    self.detailViewController.townArray = townArray;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    array = nil;
    [array release];
}

#pragma mark - Around Me
- (IBAction)aroundMe_Clicked:(id)sender
{
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    [self.detailViewController aroundMe_Clicked:self];
}

#pragma mark - Search Bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    searching = YES;
    letUserSelectRow = NO;
    self.tableView.scrollEnabled = NO;
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(letUserSelectRow)
    {
        return indexPath;
    }
    else
    {
        return nil;
    }
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [copyListOfTown removeAllObjects];
    
    if([searchText length] > 0) {
        
        searching = YES;
        letUserSelectRow = YES;
        self.tableView.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        
        searching = NO;
        letUserSelectRow = NO;
        self.tableView.scrollEnabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)thesearchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    letUserSelectRow = YES;
    searching = NO;
    self.navigationItem.rightBarButtonItem = nil;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self searchTableView];
}

- (void) searchTableView {
    
    NSString *searchText = searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    [searchArray addObjectsFromArray:townArray];
    
    for (Town *sTemp in searchArray)
    {
        NSRange titleResultsRange = [[sTemp name] rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0)
            [copyListOfTown addObject:sTemp];
    }
    
    [searchArray release];
    searchArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (searching) {
        return [copyListOfTown count];
    }
    else {
        if ([townArray count] > 0) {
            return [townArray count] -1;
        }
        else {
            return 1;
        }
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    NSString *text;
    
    if(searching && [copyListOfTown count] != 0)
        text = [[NSString alloc] initWithFormat:@"%@", [[copyListOfTown objectAtIndex:indexPath.row] name]];
    else {
        if ([townArray count] == 0) {
            text = @"Chargement...";
        }
        else if(townArray.count >=  indexPath.row+1)
        {
            text = [[NSString alloc] initWithFormat:@"%@", [[townArray objectAtIndex:indexPath.row+1] name]];
        }
    }

    // Configure the cell.
    cell.textLabel.text = NSLocalizedString(text, text);
    
    [text release];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!searching)
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (!self.detailViewController) {
                self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
            }
            self.detailViewController.detailTown = [townArray objectAtIndex:indexPath.row+1];
            self.detailViewController.townArray = townArray;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
            [self.detailViewController refresh];
        }
        else
        {
            self.detailViewController.detailTown = [townArray objectAtIndex:indexPath.row+1];
            self.detailViewController.townArray = townArray;
            [self.detailViewController refresh];
        }
    }
    else
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if (!self.detailViewController) {
                self.detailViewController = [[[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil] autorelease];
            }
            self.detailViewController.detailTown = [copyListOfTown objectAtIndex:indexPath.row];
            self.detailViewController.townArray = townArray;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
            [self.detailViewController refresh];
        }
        else
        {
            self.detailViewController.detailTown = [copyListOfTown objectAtIndex:indexPath.row];
            self.detailViewController.townArray = townArray;
            [self.detailViewController refresh];
        }
    }
}

@end
