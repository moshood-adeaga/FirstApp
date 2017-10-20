//
//  FinalProjectUITests.m
//  FinalProjectUITests
//
//  Created by Moshood Adeaga on 2017/10/03.
//  Copyright © 2017 moshood. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface FinalProjectUITests : XCTestCase

@end

@implementation FinalProjectUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEventsTab
{
    XCUIApplication *app2;
    XCUIApplication *app = app2;
    XCUIElement *eventsButton = app.tabBars.buttons[@"EVENTS"];
    [eventsButton tap];
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeLeft;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationLandscapeRight;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortraitUpsideDown;
    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    [eventsButton tap];
    [app.navigationBars[@"EVENTS"].buttons[@"info"] tap];
    [app/*@START_MENU_TOKEN@*/.otherElements[@"PopoverDismissRegion"]/*[[".otherElements[@\"dismiss popup\"]",".otherElements[@\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    
    XCUIElementQuery *collectionViewsQuery2 = app.collectionViews;
    XCUIElement *enterTopicForEventsSearchField = collectionViewsQuery2.searchFields[@"Enter Topic for Events"];
    [enterTopicForEventsSearchField tap];
    [enterTopicForEventsSearchField typeText:@"Me"];
    
    XCUIApplication *app21 = app;
    [app2/*@START_MENU_TOKEN@*/.buttons[@"Search"]/*[[".keyboards.buttons[@\"Search\"]",".buttons[@\"Search\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/ tap];
    [app typeText:@"\n"];
    [[[collectionViewsQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:0].buttons[@"myShare"] tap];
    
    XCUIElementQuery *collectionViewsQuery = app21.collectionViews/*@START_MENU_TOKEN@*/.collectionViews/*[[".cells.collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/;
    [collectionViewsQuery.buttons[@"Add to Notes"] tap];
    [collectionViewsQuery.buttons[@"Facebook"] tap];
    [app.navigationBars[@"Facebook"].buttons[@"Post"] tap];
    [[[[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeCollectionView].element tap];
    
    XCUIElement *aboutScrollView = /*@START_MENU_TOKEN@*/[app.scrollViews containingType:XCUIElementTypeStaticText identifier:@"About:"].element/*[["app","[",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Event Location:\"].element",".scrollViews containingType:XCUIElementTypeOther identifier:@\"https:\/\/www.eventbrite.com\/e\/you-me-tickets-38247874422?aff=ebap\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Get Tickets:\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"$35.00\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Ticket Price:\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Not Available\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Venue:\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"2017-11-03\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Date:\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"22:30:00\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"End Time:\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"19:30:00\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"Start Time:\"].element",".scrollViews containingType:XCUIElementTypeStaticText identifier:@\"About:\"].element"],[[[-1,0,1]],[[1,15],[1,14],[1,13],[1,12],[1,11],[1,10],[1,9],[1,8],[1,7],[1,6],[1,5],[1,4],[1,3],[1,2]]],[0,0]]@END_MENU_TOKEN@*/;
    [aboutScrollView swipeUp];
    [aboutScrollView tap];
    
    XCUIElementQuery *navigationBarsQuery = app.navigationBars;
    XCUIElement *barbuttonButton = navigationBarsQuery.buttons[@"barButton"];
    [barbuttonButton tap];
    
    XCUIElement *selectActionSheet = app.sheets[@"Select Action"];
    [selectActionSheet.buttons[@"Add To Events Consideration List "] tap];
    [app.alerts[@"EVENT BOOKMARKED"].buttons[@"OK"] tap];
    [barbuttonButton tap];
    [selectActionSheet.buttons[@"Set Reminder"] tap];
    [app.alerts[@"EVENT"].buttons[@"OK"] tap];
    [navigationBarsQuery.buttons[@"EVENTS"] tap];
    
}
-(void)testCameraTab
{

}
-(void)testChatTab
{
    
}

-(void)testProfileTab
{
    
}

@end
