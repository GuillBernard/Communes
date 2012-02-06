//
//  Town.h
//  Communes
//
//  Created by Guillaume Bernard on 01/02/12.
//  Copyright (c) 2012 Bazinga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Town : NSObject {
  NSString *printVille_;
}

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *nameUP;
@property (strong, nonatomic) NSString *postalCode;
@property (strong, nonatomic) NSString *inseeCode;
@property (strong, nonatomic) NSString *regionCode;
@property float latitude;
@property float longitude;
@property float distance;

- (NSString *)print;

@end
