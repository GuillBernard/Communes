//
//  DetailViewController.m
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import "DetailViewController.h"
#import "InfosViewController.h"
#import "MapPoint.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize detailVille = _detailVille;
@synthesize mapView = _mapView;
@synthesize aroundMe = _aroundMe;
@synthesize villeAnnotation = _villeAnnotation;
@synthesize mapType = _mapType;
@synthesize townArray = _townArray;
@synthesize activityIndicator = _activityIndicator;

float latitude = 46.770204;
float longitude = 2.431755;
float delta = 8.;

- (void)dealloc
{
    [_detailItem release];
    [_masterPopoverController release];
    [_detailDescriptionLabel release];
    [_masterPopoverController release];
    [_detailVille release];
    [_mapView release];
    [_aroundMe release];
    [_villeAnnotation release];
    [_mapType release];  
    [_townArray release];
    [_activityIndicator release];
    [clController release];
    [aroundMeTownArray release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        [_detailItem release]; 
        _detailItem = [newDetailItem retain]; 

        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
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
    [self configureView];
    
    isAround = false;
    
    //set the map center on the France
    CLLocationDegrees CLLat = (CLLocationDegrees)latitude;    
    CLLocationDegrees CLLong = (CLLocationDegrees)longitude;
    
    CLLocationCoordinate2D newCoord = { CLLat, CLLong };
    
    MKCoordinateRegion region = self.mapView.region;
    region.center = newCoord;
    region.span.longitudeDelta = delta;
    region.span.latitudeDelta = delta;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        region.span.longitudeDelta = delta+2;
        region.span.latitudeDelta = delta+2;
    }
    [self.mapView setRegion:region animated:YES];
    
    //the Geolocation button
    _aroundMe = [[[UIBarButtonItem alloc] initWithTitle:@"Around Me" style:UIBarButtonItemStyleDone target:self action:@selector(aroundMe_Clicked:)] autorelease];
    
    self.navigationItem.rightBarButtonItem = _aroundMe;
    
    [_mapView setDelegate:self];
    
    _mapType.selectedSegmentIndex=0;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
    }
    return self;
}

#pragma mark - Set the informations

-(void) refresh{
    isAround = false;
    self.detailDescriptionLabel.text = @"";
    self.detailDescriptionLabel.hidden = true;
    self.title = [_detailVille name];
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    CLLocationDegrees CLLat = (CLLocationDegrees)_detailVille.latitude;    
    CLLocationDegrees CLLong = (CLLocationDegrees)_detailVille.longitude;
    
    CLLocationCoordinate2D newCoord = { CLLat, CLLong };
    
    MKCoordinateRegion region = self.mapView.region;
    region.center = newCoord;
    region.span.longitudeDelta = fabs([_detailVille eloignement]);
    region.span.latitudeDelta = fabs([_detailVille eloignement]);
    [self.mapView setRegion:region animated:YES]; 
    
    
     _villeAnnotation = [[MapPoint alloc] initWithCoordinate:newCoord title:[_detailVille name]]; 
    
    
    [_mapView addAnnotation:_villeAnnotation];
    
    [_mapView selectAnnotation:_villeAnnotation animated:false];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [_masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView_ viewForAnnotation: (id <MKAnnotation>) annotation_ {
    
    if(annotation_ == _mapView.userLocation)
    {
        return nil;
    }
    if(_villeAnnotation != nil || isAround)
    {
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationIdentifier"];
        if (pin == nil) {
            pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation_ reuseIdentifier: @"AnnotationIdentifier"] autorelease];
        }
        else {
            pin.annotation = annotation_;
        }
        [pin setCanShowCallout:YES];
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pin.rightCalloutAccessoryView = rightButton;
        pin.animatesDrop = YES;
        return pin;
    }
        
    return nil;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
	
	if(!isAround)
    {
        InfosViewController *infosController = [[InfosViewController alloc] init];
		infosController.detailVille=_detailVille;
		infosController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:infosController animated:YES];
    }
    else
    {
        Ville *choosen = [[Ville alloc] init];
        MapPoint *annotation = view.annotation;
		//to know which annotation I choose
		for (int i = 0 ; i < [aroundMeTownArray count] ; i++) {
			Ville *v = [aroundMeTownArray objectAtIndex:i];
            CLLocationDegrees CLLat = (CLLocationDegrees)[v latitude];    
            CLLocationDegrees CLLong = (CLLocationDegrees)[v longitude];
            
			if (annotation.coordinate.latitude==CLLat && annotation.coordinate.longitude==CLLong) {
				choosen=v;
                break;
			}
            
            [v release];
		}
        InfosViewController *infosController = [[InfosViewController alloc] init];
		infosController.detailVille=choosen;
		infosController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:infosController animated:YES];
        [choosen release];
    }
	
}

- (IBAction)changeMapType:(id)sender{ 
	if(_mapType.selectedSegmentIndex==0){
		_mapView.mapType=MKMapTypeStandard;
	}
	else if (_mapType.selectedSegmentIndex==1){
		_mapView.mapType=MKMapTypeSatellite;
	}
	else if (_mapType.selectedSegmentIndex==2){
		_mapView.mapType=MKMapTypeHybrid;
	}
}

#pragma mark - Around Me
- (IBAction) aroundMe_Clicked:(id)sender
{
    isAround = true;
    first = true;
    aroundMeTownArray = [[NSMutableArray alloc] init];
    [_mapView removeAnnotations:_mapView.annotations];
    _detailDescriptionLabel.text = @"Around Me - Searching...";
    self.title = @"Around Me";
    
    _detailDescriptionLabel.hidden = false;
    
    //start the ActivityIndicator
    _activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease]; 
    [_activityIndicator setColor:[UIColor blackColor]];
    // we put our spinning "thing" right in the center of the current view
    CGPoint newCenter = (CGPoint) [self.view center];
    _activityIndicator.center = newCenter;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
    
    //Get the Geolocation
    clController = [[CLLocationManager alloc] init];
	clController.delegate = self;
	[clController startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{    
    [clController stopUpdatingLocation];
    if(first)
    {
        first = false;
        
        _mapView.showsUserLocation = YES;
        MKCoordinateRegion region = self.mapView.region;
        region.center = newLocation.coordinate;
        region.span.longitudeDelta = 0.09;
        region.span.latitudeDelta = 0.09;
        [self.mapView setRegion:region animated:YES];
        
        NSLog(@"search");
        //search the locations around me
        for (int i = 0; i < [_townArray count]; i++) {
            Ville *v = [_townArray objectAtIndex:i];
        
            CLLocationDegrees CLLat = (CLLocationDegrees)v.latitude;    
            CLLocationDegrees CLLong = (CLLocationDegrees)v.longitude;
            
            CLLocation * villeLocation = [[CLLocation alloc] initWithLatitude:CLLat longitude:CLLong];

            CLLocationDistance dist = [newLocation distanceFromLocation:villeLocation];
            
            if (dist < 10000.) {
                [aroundMeTownArray addObject:v];
            }

            [villeLocation release];
            [v release];
        }
    
        //add the pins
        self.detailDescriptionLabel.text = @"";
        self.detailDescriptionLabel.hidden = true;
        for (int i = 0; i < [aroundMeTownArray count]; i++) {
            _detailVille = [aroundMeTownArray objectAtIndex:i];
            
            CLLocationDegrees CLLat = _detailVille.latitude;    
            CLLocationDegrees CLLong = _detailVille.longitude;
        
            CLLocationCoordinate2D newCoord = { CLLat, CLLong };
            
            MapPoint *point = [[MapPoint alloc] initWithCoordinate:newCoord title:[_detailVille name]]; 
        
        
            [_mapView addAnnotation:point];
        
            [point release];
        }
        [_activityIndicator stopAnimating];
        [_activityIndicator removeFromSuperview];
        _activityIndicator = nil;
        
        first = false;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Communes", @"Communes");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
