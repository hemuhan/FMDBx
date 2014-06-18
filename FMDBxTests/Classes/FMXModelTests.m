//
//  FMXModelTests.m
//  FMDBx
//
//  Created by KohkiMakimoto on 5/25/14.
//  Copyright (c) 2014 KohkiMakimoto. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FMDB.h>
#import "FMDBx.h"
#import "FMXTestMigration.h"
#import "FMXUser.h"

@interface FMXModelTests : XCTestCase

@end

@implementation FMXModelTests

- (void)setUp
{
    [super setUp];
    [[FMXDatabaseManager sharedInstance] registerDefaultDatabaseWithPath:@"default.sqlite"
                                                               migration:[[FMXTestMigration alloc] init]];
}

- (void)tearDown
{
    [[FMXDatabaseManager sharedInstance] destroyDefaultDatabase];
    [super tearDown];
}

- (void)testSaveAndFind
{
    FMXUser *user = [[FMXUser alloc] init];
    user.name = @"kohki makimoto";
    user.age = @(33);
    user.createdAt = [NSDate date];
    user.updatedAt = [NSDate date];
    
    FMXUser *retUser = (FMXUser *)[FMXUser modelByPrimaryKey:@(1)];
    XCTAssertNil(retUser);

    // insert
    [user save];

    FMXUser *retUser2 =(FMXUser *)[FMXUser modelByPrimaryKey:@(1)];
    XCTAssertEqualObjects(user.name, retUser2.name);
    XCTAssertEqualObjects(user.age, retUser2.age);

    FMXUser *retUser3 =(FMXUser *)[FMXUser modelByPrimaryKey:@(1)];
    XCTAssertEqualObjects(user.name, retUser3.name);
    XCTAssertEqualObjects(user.age, retUser3.age);

    FMXUser *retUser4 =(FMXUser *)[FMXUser modelWhere:@"name = :name" parameters:@{@"name": @"kohki makimoto"} orderBy:@"age desc"];
    XCTAssertEqualObjects(user.name, retUser4.name);
    XCTAssertEqualObjects(user.age, retUser4.age);
    
    // update
    user.age = @(44);
    [user save];
    
    FMXUser *retUser5 =(FMXUser *)[FMXUser modelByPrimaryKey:@(1)];
    XCTAssertEqualObjects(@(44), retUser5.age);
    
    // count
    NSInteger count1 = [FMXUser count];
    XCTAssertEqual(1, count1);
    
    NSInteger count2 = [FMXUser countWhere:@"name = :name" parameters:@{@"name": @"kohki makimoto"}];
    XCTAssertEqual(1, count2);

    NSInteger count3 = [FMXUser countWhere:@"name = :name" parameters:@{@"name": @"AAAAAAA"}];
    XCTAssertEqual(0, count3);

    // delete
    [user delete];
    FMXUser *retUser6 = (FMXUser *)[FMXUser modelByPrimaryKey:@(1)];
    XCTAssertNil(retUser6);
}

@end
