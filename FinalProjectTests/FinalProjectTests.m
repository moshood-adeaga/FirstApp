//
//  FinalProjectTests.m
//  FinalProjectTests
//
//  Created by Moshood Adeaga on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

@interface FinalProjectTests : XCTestCase
@property (strong, nonatomic) NSURLSession *sessionUnderTest;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation FinalProjectTests

- (void)setUp {
    [super setUp];
    [self setSessionUnderTest:[NSURLSession sharedSession]];
    [self setManager:[AFHTTPRequestOperationManager manager]];
}

- (void)tearDown {
    [self setSessionUnderTest:nil];
    [super tearDown];
}
-(void)testThatCheckIfAPIisWorking
{
    NSURL *url = [NSURL URLWithString:@"https://www.eventbriteapi.com/v3/events/search/?q=london&token=XU4CJHOK4JHP4VB3XY4B"];
    
    XCTestExpectation *promise = [self expectationWithDescription:@"Status Code: 200"];
    
    NSURLSessionDataTask *dataTask = [self.sessionUnderTest dataTaskWithURL:url completionHandler:^(NSData  *_Nullable data, NSURLResponse * _Nullable response, NSError* _Nullable error) {
        
        
        if (error)
        {
            XCTFail(@"Error: %@",[error localizedDescription]);
        }
        else if([(NSHTTPURLResponse*)response statusCode] ==200)
        {
            [promise fulfill];
        }
        else
        {
            XCTFail(@"Status Code: %ld", (long)[(NSHTTPURLResponse*)response statusCode]);
        }
        
        
    }];
    
    [dataTask resume];
    [self waitForExpectationsWithTimeout:60.0 handler:nil];
}
-(void)testcheckIfRegesterServerIsWorking
{
   NSString *databasePath= @"https://moshoodschatapp.000webhostapp.com/MyWebservice/MyWebservice/v1/register.php";
    XCTestExpectation *promise = [self expectationWithDescription:@"Status Code: 200"];
    //Registering a New user to the system with the Details the Enter to textfields in the View.
    NSDictionary *databaseParameter= @{@"username":@"moshood",
                                       @"password":@"ytrewq147",
                                       @"email":@"moshoodadeaga@Gmail.com",
                                       @"firstname":@"moshood",
                                       @"lastname":@"adeaga",
                                       @"phone":@"07944775611"
                                       };
    
    //Making a Post Request to the Database Path for Registration, the Path is shown In the View Did Load Fuction Above.
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [self.manager POST:databasePath parameters:databaseParameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [promise fulfill];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        XCTFail(@"Error: %@",[error localizedDescription]);
    }];
}


@end
