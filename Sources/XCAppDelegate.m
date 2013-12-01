
#import "XCAppDelegate.h"


@implementation XCAppDelegate

#pragma mark Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)options {
    [self setupLibraries];
    
    [self setupComponents];
    
    [self setupWindow];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark Libraries

- (void)setupLibraries {
}

#pragma mark Components

- (void)setupComponents {
}

#pragma mark UI

- (void)setupWindow {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [self createInitialViewController];
    [self.window makeKeyAndVisible];
}

- (UIViewController *)createInitialViewController {
    UITableViewController *table = [UITableViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:table];
    
    table.navigationItem.title = @"Hello World!";
    
    return nav;
}

@end
