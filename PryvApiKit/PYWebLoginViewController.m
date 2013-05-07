//
//  PYWebLoginViewController.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYWebLoginViewController.h"
#import "PYClient.h"

@interface PYWebLoginViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) NSTimer *pollTimer;

@property (assign, nonatomic) NSUInteger iteration;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *token;


@end


@implementation PYWebLoginViewController

@synthesize webView = _webView;

- (void)loadView
{
    [super loadView];
    UIWebView *tmpWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.webView = tmpWebView;
    [tmpWebView release];
    [self.view addSubview:_webView];
    
    self.webView.delegate = self;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
    [self.webView release];
    [super dealloc];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"shouldStartLoadWithRequest ");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{    
    NSLog(@"webViewDidStartLoad ");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // TODO create an alert to notify a user of an error
    NSLog(@"didFailLoadWithError %@", [error localizedDescription]);    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSomething
{
    self = [super initWithNibName:@"PYWebLoginViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestLoginView)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self requestLoginView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // kill the timer if one existed
    [self.pollTimer invalidate];
}


#pragma mark - Private

// POST request to /access to obtain a login page URL and load the contents of the URL
//      (which is a login form) to a child webView
//      activate a timer loop

- (void)requestLoginView
{
    // TODO extract the url to a more meaningful place
    NSString *preferredLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *applicationChannelId = @"position";
    NSString *channelName = @"Position";

    NSDictionary *postData = @{
                             // TODO extract the app id some where to constants
                             @"requestingAppId": @"pryv-mobile-position-ios",
                             @"returnURL": @"false",
                             @"languageCode" : preferredLanguageCode,
                             @"requestedPermissions": @[
                                     // channel for position events
                                     @{
                                         @"channelId" : applicationChannelId,
                                         @"defaultName" : channelName,
                                         @"level" : @"shared"
                                         }
                                     ]
                             };

    
    NSString *fullPathString = [NSString stringWithFormat:@"%@/access", [PYClient apiBaseUrl]];

    [PYClient apiRequest:fullPathString
                  access:nil
             requestType:PYRequestTypeAsync
                  method:PYRequestMethodPOST
                postData:postData
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     
                     [self handleSuccess:JSON];
                     
                 } failure:^(NSError *error) {
                     
                     [self handleFailure:error];
                 }];

}

- (void)handleSuccess:(id)JSON
{
    assert(JSON);
    NSLog(@"Request Successful, response '%@'", JSON);
    
    assert([JSON isKindOfClass:[NSDictionary class]]);
    NSDictionary *jsonDictionary = (NSDictionary *)JSON;
    
    assert([JSON objectForKey:@"url"]);
    NSString *loginPageUrlString = jsonDictionary[@"url"];
    
    NSURL *loginPageURL = [NSURL URLWithString:loginPageUrlString];
    assert(loginPageURL);
    
    NSString *pollUrlString = jsonDictionary[@"poll"];
    assert(pollUrlString);
        
    NSTimeInterval pollTimeInterval = [jsonDictionary[@"poll_rate_ms"] doubleValue] /1000;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:loginPageURL]];

    [self pollURL:pollUrlString withTimeInterval:pollTimeInterval];
    
    
}

- (void)handleFailure:(NSError *)error
{
    NSLog(@"[HTTPClient Error]: %@", error);
}


- (void)pollURL:(NSString *)pollURLString withTimeInterval:(NSTimeInterval)pollTimeInterval
{
    //NSLog(@"create a poll request to %@ with interval: %f", pollURL, pollTimeInterval);
    NSLog(@"create a poll request with interval: %f", pollTimeInterval);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSLog(@"stop polling if app is in backround");
        return;
    }
    
    
    // reset previous timer if one existed
    [self.pollTimer invalidate];
    
    // schedule a GET reqest in seconds amount stored in pollTimeInterval
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:pollTimeInterval
                                                      target:[NSBlockOperation blockOperationWithBlock:
                                                              ^{
                                                                  [PYClient apiRequest:pollURLString
                                                                                access:nil
                                                                           requestType:PYRequestTypeAsync
                                                                                method:PYRequestMethodGET
                                                                              postData:nil
                                                                           attachments:nil
                                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                   
                                                                                   [self handlePollSuccess:JSON];
                                                                                   
                                                                               } failure:^(NSError *error) {
                                                                                   NSLog(@"error is %@",error);
                                                                               }];

                                                              }]
                                                    selector:@selector(main) // send message main to NSBLockOperation
                                                    userInfo:nil
                                                     repeats:NO
                      ];



}

- (void)handlePollSuccess:(id)JSON
{
    NSDictionary *jsonDictionary = (NSDictionary *)JSON;
    
    // check status
    NSString *statusString = jsonDictionary[@"status"];
    
    if ([@"NEED_SIGNIN" isEqualToString:statusString]) {
        
        NSString *pollUrlString = jsonDictionary[@"poll"];
        assert(pollUrlString);
                
        NSString *pollTimeIntervalString = jsonDictionary[@"poll_rate_ms"];
        assert(pollTimeIntervalString);
        
        NSTimeInterval pollTimeInterval = [pollTimeIntervalString doubleValue] / 1000;
        
        // recursive call
        
        // TODO weakself
        [self pollURL:pollUrlString withTimeInterval:pollTimeInterval];
    } else {
        NSLog(@"status changed to %@", statusString);
        
        // process the different statuses
        
        if ([@"ACCEPTED" isEqualToString:statusString]) {
            
            // if status ACCEPTED proceed with username and token
            NSString *username = jsonDictionary[@"username"];
            NSString *token = jsonDictionary[@"token"];
            
            [self successfulLoginWithUsername:username token:token];
            
        } else if ([@"REFUSED" isEqualToString:statusString]) {
            
            NSString *message = jsonDictionary[@"message"];
            assert(message);
            
            
        } else if ([@"ERROR" isEqualToString:statusString]) {
            
            NSString *message = jsonDictionary[@"message"];
            assert(message);
            
            NSString *errorCode = nil;
            if ([jsonDictionary objectForKey:@"id"]) {
                errorCode = jsonDictionary[@"id"];
            }
            
            
        } else {
            
            NSLog(@"poll request unknown status: %@", statusString);
            
            NSString *message = NSLocalizedString(@"Unknown Error",);
            if ([jsonDictionary objectForKey:@"message"]) {
                message = [jsonDictionary objectForKey:@"message"];
            }
            
        }
    }

}

-  (void)successfulLoginWithUsername:(NSString *)username token:(NSString *)token
{
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
