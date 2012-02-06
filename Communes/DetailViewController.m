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

@synthesize detailItem              = _detailItem;
@synthesize detailDescriptionLabel  = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize detailTown              = _detailTown;
@synthesize mapView                 = _mapView;
@synthesize aroundMe                = _aroundMe;
@synthesize mapType                 = _mapType;
@synthesize townArray               = _townArray;
@synthesize activityIndicator       = _activityIndicator;
@synthesize myProgressBar           = _myProgressBar;

float latitude = 46.770204;
float longitude = 2.431755;
float delta = 8.;

- (void)dealloc {
  [_detailItem release];
  [_masterPopoverController release];
  [_detailDescriptionLabel release];
  [_masterPopoverController release];
  [_detailTown release];
  [_mapView release];
  [_aroundMe release];
  [_mapType release];  
  [_townArray release];
  [_activityIndicator release];
  [_myProgressBar release];
  [clController_ release];
  [aroundMeTownArray_ release];
  [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
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

- (void)configureView {
  // Update the user interface for the detail item.
  if (self.detailItem) {
    self.detailDescriptionLabel.text = [self.detailItem description];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
  
  isAround_ = false;
  
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

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSLocalizedString(@"Map", @"Map");
  }
  
  return self;
}

#pragma mark - Set the informations

- (void)refresh {
  isAround_ = false;
  self.detailDescriptionLabel.text = @"";
  self.detailDescriptionLabel.hidden = true;
  self.title = [_detailTown name];
  
  [_mapView removeAnnotations:_mapView.annotations];
  
  CLLocationDegrees CLLat = (CLLocationDegrees)_detailTown.latitude;    
  CLLocationDegrees CLLong = (CLLocationDegrees)_detailTown.longitude;
  
  CLLocationCoordinate2D newCoord = { CLLat, CLLong };
  
  MKCoordinateRegion region = self.mapView.region;
  region.center = newCoord;
  region.span.longitudeDelta = fabs([_detailTown distance]);
  region.span.latitudeDelta = fabs([_detailTown distance]);
  [self.mapView setRegion:region animated:YES]; 
  
  
  MapPoint *townAnnotation = [[MapPoint alloc] initWithCoordinate:newCoord title:[_detailTown name]]; 
  [_mapView addAnnotation:townAnnotation];
  [_mapView selectAnnotation:townAnnotation animated:false];
  
  [townAnnotation release];
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [_masterPopoverController dismissPopoverAnimated:YES];
  }
}

- (MKAnnotationView *) mapView: (MKMapView *) mapView_ viewForAnnotation: (id <MKAnnotation>) annotation_ {
  if(annotation_ == _mapView.userLocation) {
    return nil;
  }
  
  MKPinAnnotationView *pin = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"AnnotationIdentifier"];
  if (pin == nil) {
    pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation_ reuseIdentifier: @"AnnotationIdentifier"] autorelease];
  } else {
    pin.annotation = annotation_;
  }
  
  [pin setCanShowCallout:YES];
  UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  pin.rightCalloutAccessoryView = rightButton;
  pin.animatesDrop = YES;
  
  return pin;
}

- (void)mapView:(MKMapView *)mapView 
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control {    
	if(!isAround_) {
    InfosViewController *infosController = [[InfosViewController alloc] init];
		infosController.detailTown=_detailTown;
		infosController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:infosController animated:YES];
  } else {
    Town *choosen = [[Town alloc] init];
    MapPoint *annotation = view.annotation;
		//to know which annotation I choose
		for (int i = 0 ; i < [aroundMeTownArray_ count] ; i++) {
			Town *town = [aroundMeTownArray_ objectAtIndex:i];
      CLLocationDegrees CLLat = (CLLocationDegrees)[town latitude];    
      CLLocationDegrees CLLong = (CLLocationDegrees)[town longitude];
      
			if (annotation.coordinate.latitude==CLLat && annotation.coordinate.longitude==CLLong) {
				choosen=town;
        break;
			}
      
      [town release];
		}
    
    InfosViewController *infosController = [[InfosViewController alloc] init];
		infosController.detailTown=choosen;
		infosController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:infosController animated:YES];
    [choosen release];
    [annotation release];
  }
}

- (IBAction)changeMapType:(id)sender { 
	if(_mapType.selectedSegmentIndex==0) {
		_mapView.mapType=MKMapTypeStandard;
	} else if (_mapType.selectedSegmentIndex==1) {
		_mapView.mapType=MKMapTypeSatellite;
	} else if (_mapType.selectedSegmentIndex==2) {
		_mapView.mapType=MKMapTypeHybrid;
	}
}

#pragma mark - Around Me
- (IBAction) aroundMe_Clicked:(id)sender {
  isAround_ = true;
  first_ = true;
  
  aroundMeTownArray_ = [[NSMutableArray alloc] init];
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
  clController_ = [[CLLocationManager alloc] init];
	clController_.delegate = self;
	[clController_ startUpdatingLocation];
}


- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
           fromLocation:(CLLocation *)oldLocation {    
  [clController_ stopUpdatingLocation];
  
  if(first_) {
    first_ = false;
    
    _mapView.showsUserLocation = YES;
    MKCoordinateRegion region = self.mapView.region;
    region.center = newLocation.coordinate;
    region.span.longitudeDelta = 0.163426;
    region.span.latitudeDelta = 0.139721;
    [self.mapView setRegion:region animated:YES];
    
    //search the locations around me
    for (int i = 0; i < [_townArray count]; i++) {
      Town *town = [_townArray objectAtIndex:i];
      
      CLLocationDegrees CLLat = (CLLocationDegrees)town.latitude;    
      CLLocationDegrees CLLong = (CLLocationDegrees)town.longitude;
      
      CLLocation * townLocation = [[CLLocation alloc] initWithLatitude:CLLat longitude:CLLong];
      
      CLLocationDistance dist = [newLocation distanceFromLocation:townLocation];
      
      if (dist < 10000.) {
        [aroundMeTownArray_ addObject:town];
      }
      
      [townLocation release];
      [town release];
    }
    
    //add the pins
    self.detailDescriptionLabel.text = @"";
    self.detailDescriptionLabel.hidden = true;
    for (int i = 0; i < [aroundMeTownArray_ count]; i++) {
      _detailTown = [aroundMeTownArray_ objectAtIndex:i];
      
      CLLocationDegrees CLLat = _detailTown.latitude;    
      CLLocationDegrees CLLong = _detailTown.longitude;
      
      CLLocationCoordinate2D newCoord = { CLLat, CLLong };
      
      MapPoint *point = [[MapPoint alloc] initWithCoordinate:newCoord title:[_detailTown name]]; 
      
      
      [_mapView addAnnotation:point];
      
      [point release];
    }
    
    [_activityIndicator stopAnimating];
    [_activityIndicator removeFromSuperview];
    _activityIndicator = nil;
    
    first_ = false;
  }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController 
     willHideViewController:(UIViewController *)viewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)popoverController {
  barButtonItem.title = NSLocalizedString(@"Communes", @"Communes");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController 
     willShowViewController:(UIViewController *)viewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
  // Called when the view is shown again in the split view, invalidating the button and popover controller.
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

@end