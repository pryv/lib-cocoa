//
//  PYWebLoginViewController.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//


#import "PYClient.h"
#import "PYConstants.h"
#import "PYWebLoginViewController.h"

@interface PYWebLoginViewController () <UIWebViewDelegate>

@property (nonatomic, assign) UIWebView *webView;
@property (nonatomic, assign) UIActivityIndicatorView *loadingActivityIndicatorView;
@property (nonatomic, assign) UIBarButtonItem *refreshBarButtonItem;


@property (nonatomic, assign) NSUInteger iteration;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *token;

@property (nonatomic, retain) NSTimer *pollTimer;

@property (nonatomic, retain) NSArray *permissions;
@property (nonatomic, retain) NSString *appID;

@end


@implementation PYWebLoginViewController

UIBarButtonItem *loadingActivityIndicator;


+ (PYWebLoginViewController *)requesAccessWithAppId:(NSString *)appID andPermissions:(NSArray *)permissions delegate:(id ) delegate {
    PYWebLoginViewController *login = [PYWebLoginViewController alloc];
    login.permissions = permissions;
    login.appID = appID;
    login.delegate = delegate;
    [login openOn];
    
    return login;
}


- (PYWebLoginViewController* )openOn
{
    [self init];
    
    
    NSLog(@"PYWebLoginViewControlleriOs:Open on");
    
    // -- navigation bar -- //
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
    
    self.refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem;
    
    // -- loading Indicator --//
    self.loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    loadingActivityIndicator = [[UIBarButtonItem alloc] initWithCustomView:self.loadingActivityIndicatorView];
    
    [self startLoading];
    
    // -- webview -- //
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.webView = [[UIWebView alloc] initWithFrame:applicationFrame];
    [self.webView setDelegate:self];
    [self.webView setBackgroundColor:[UIColor grayColor]];
    [self.webView loadHTMLString:@"<html><center><h1>PrYv Signup</h1></center><hr><center>loading ...</center></html>" baseURL:nil];
    
    self.view = self.webView;
    
    // -- show on delegate's UIController -- //
    [[self.delegate pyWebLoginGetController] presentViewController:navigationController animated:YES completion:nil];

    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.webView release];
    [self.loadingActivityIndicatorView release];
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
    [self startLoading];
    NSLog(@"webViewDidStartLoad ");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoading];
    NSLog(@"webViewDidFinishLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoading];
    NSLog(@"didFailLoadWithError %@", [error localizedDescription]);    
}

#pragma mark - init


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

#pragma mark - Target Actions

- (IBAction)close:(id)sender
{
    [self.pollTimer invalidate];
    // TODO
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (IBAction)reload:(id)sender
{
    [self requestLoginView];
}

#pragma mark - Private

- (void)startLoading
{
    self.refreshBarButtonItem.enabled = NO;
    [self.loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = loadingActivityIndicator;
}

- (void)stopLoading
{
    self.refreshBarButtonItem.enabled = YES;
    [self.loadingActivityIndicatorView stopAnimating];
    self.navigationItem.rightBarButtonItem = self.refreshBarButtonItem;
}



// POST request to /access to obtain a login page URL and load the contents of the URL
//      (which is a login form) to a child webView
//      activate a timer loop

- (void)requestLoginView
{
    // TODO extract the url to a more meaningful place
    NSString *preferredLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
 
    NSDictionary *postData = @{
                             // TODO extract the app id some where to constants
                             @"requestingAppId": self.appID,
                             @"returnURL": @"false",
                             @"languageCode" : preferredLanguageCode,
                             @"requestedPermissions": self.permissions
                                 };

    
    NSString *fullPathString = [NSString stringWithFormat:@"%@://access%@/access", kPYAPIScheme, [PYClient defaultDomain]];

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
    [self.delegate pyWebLoginSuccess:[PYClient createAccessWithUsername:username andAccessToken:token]];
    [self close:nil];
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
