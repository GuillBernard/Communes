//
//  MapPoint.m
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint

@synthesize title       = title_;
@synthesize subtitle    = subtitle_;
@synthesize coordinate  = coordinate_;

-(id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t {
  title_ = t;
  coordinate_ = c;
  
  return self;
}

@end
