//
//  DetailViewController.h
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "Town.h"
#import "MapPoint.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate> {
  bool                isAround_;
  CLLocationManager   *clController_;
  NSMutableArray      *aroundMeTownArray_;
  bool                first_;
}

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) IBOutlet UILabel              *detailDescriptionLabel;
@property (strong, nonatomic) Town                          *detailTown;
@property (nonatomic,retain)  IBOutlet MKMapView            *mapView;
@property (nonatomic,retain)  IBOutlet UIBarButtonItem      *aroundMe;
@property (nonatomic,retain)  IBOutlet UISegmentedControl   *mapType;
@property (nonatomic,retain)  NSMutableArray                *townArray;
@property (nonatomic, retain) UIActivityIndicatorView       *activityIndicator;
@property (nonatomic,retain) IBOutlet UIProgressView        *myProgressBar;

- (IBAction)aroundMe_Clicked:(id)sender;
- (void)refresh;
- (IBAction)changeMapType:(id)sender;

@end