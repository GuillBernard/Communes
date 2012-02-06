//
//  Town.m
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import "Town.h"

@implementation Town

@synthesize name        = _name;
@synthesize nameUP      = _nameUP;
@synthesize postalCode  = _postalCode;
@synthesize inseeCode   = _inseeCode;
@synthesize regionCode  = _regionCode;
@synthesize distance    = _distance;
@synthesize latitude    = _latitude;
@synthesize longitude   = _longitude;

- (NSString *) print {
  printVille_ = [[NSString alloc] initWithFormat:@"%@\n\ncode postal : %@\n", _name, _postalCode];
  
  return printVille_;
}

- (void)dealloc {
  [printVille_ release];
  [_name release];
  [_nameUP release];
  [_postalCode release];
  [_inseeCode release];
  [_regionCode release];
}

@end
