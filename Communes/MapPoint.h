//
//  MapPoint.h
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject<MKAnnotation> {
  NSString                *title_; 
  NSString                *subtitle_; 
  CLLocationCoordinate2D  coordinate_; 
}

@property (nonatomic,readonly) CLLocationCoordinate2D   coordinate; 
@property (nonatomic,copy) NSString                     *title; 

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t; 

@end