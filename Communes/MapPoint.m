//
//  MapPoint.m
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize coordinate = _coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D) c title:(NSString *) t {
  _title = t;
  _coordinate = c;
  
  return self;
}

@end
