
#import <SenTestingKit/SenTestingKit.h>


@interface TestDummy : SenTestCase

@end


@implementation TestDummy

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDummy {
    STFail(@"Dummy test failed!");
}

@end
