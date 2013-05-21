//
//  PYWebLoginViewController.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//


#import "PYClient.h"
#import "PYError.h"
#import "PYErrorUtility.h"
#import "PYConstants.h"
#import "PYWebLoginViewController.h"

@interface PYWebLoginViewController () <UIWebViewDelegate>

@property (nonatomic, retain) NSArray *permissions;
@property (nonatomic, retain) NSString *appID;

@property (nonatomic, retain) NSTimer *pollTimer;

@end


@implementation PYWebLoginViewController

UIBarButtonItem *loadingActivityIndicator;
UIWebView *webView;
UIActivityIndicatorView *loadingActivityIndicatorView;
UIBarButtonItem *refreshBarButtonItem;


NSUInteger iteration;

NSString *username;
NSString *token;

BOOL closing;

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
    closing = false;
    
    NSLog(@"PYWebLoginViewControlleriOs:Open on");
    
    // -- navigation bar -- //
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
    self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
    
    // -- loading Indicator --//
    loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    loadingActivityIndicator = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self startLoading];
    
    // -- webview -- //
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    webView = [[UIWebView alloc] initWithFrame:applicationFrame];
    [webView setDelegate:self];
    [webView setBackgroundColor:[UIColor grayColor]];
    [webView loadHTMLString:@"<html><center><h1>PrYv Signup</h1></center><hr><center>loading ...</center></html>" baseURL:nil];
    
    self.view = webView;
    
    // -- show on delegate's UIController -- //
    [[self.delegate pyWebLoginGetController] presentViewController:navigationController animated:YES completion:nil];
    
    [navigationController release];
    
    return self;
}

- (void)close
{
    if (closing) return;
    closing = true;
    [self.pollTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    self.pollTimer = nil;
    
    [webView release];
    [refreshBarButtonItem release];
    [loadingActivityIndicator release];
    [loadingActivityIndicatorView release];
    [super dealloc];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoading];
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



- (IBAction)cancel:(id)sender
{
    [self abordedWithReason:@"Canceled by user"];
}

- (IBAction)reload:(id)sender
{
    [self requestLoginView];
}

#pragma mark - Private

- (void)startLoading
{
    refreshBarButtonItem.enabled = NO;
    [loadingActivityIndicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = loadingActivityIndicator;
}

- (void)stopLoading
{
    refreshBarButtonItem.enabled = YES;
    [loadingActivityIndicatorView stopAnimating];
    self.navigationItem.rightBarButtonItem = refreshBarButtonItem;
}



// POST request to /access to obtain a login page URL and load the contents of the URL
//      (which is a login form) to a child webView
//      activate a timer loop

BOOL requestedLoginView = false;
- (void)requestLoginView
{
    requestedLoginView = true;
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
                 headers:nil
             requestType:PYRequestTypeAsync
                  method:PYRequestMethodPOST
                postData:postData
             attachments:nil
                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                     [self handlePollSuccess:JSON];
                 } failure:^(NSError *error) {
                     [self handleFailure:error];
                 }];
    
}

- (void)handleFailure:(NSError *)error
{
    NSLog(@"[HTTPClient Error]: %@", error);
    NSString *content = [NSString stringWithFormat:@"<html><center><h1>PrYv Signup</h1></center><hr><center>error: %@ ...</center></html>",[error localizedDescription]];
    [webView loadHTMLString:content baseURL:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self abordedWithError:error];
    });
    
}


- (void)pollURL:(NSString *)pollURLString withTimeInterval:(NSTimeInterval)pollTimeInterval
{
    //NSLog(@"create a poll request to %@ with interval: %f", pollURL, pollTimeInterval);
    NSLog(@"create a poll request with interval: %f", pollTimeInterval);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSLog(@"stop polling if app is in background");
        return;
    }
    
    
    // reset previous timer if one existed
    [self.pollTimer invalidate];
    
    // schedule a GET reqest in seconds amount stored in pollTimeInterval
    self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:pollTimeInterval
                                                      target:[NSBlockOperation blockOperationWithBlock:
                                                              ^{
                                                                  [PYClient apiRequest:pollURLString
                                                                                headers:nil
                                                                           requestType:PYRequestTypeAsync
                                                                                method:PYRequestMethodGET
                                                                              postData:nil
                                                                           attachments:nil
                                                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                   [self handlePollSuccess:JSON];
                                                                              } failure:^(NSError *error) {
                                                                                   [self handleFailure:error];
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
    NSString *statusString = [jsonDictionary objectForKey:@"status"];
    
    if ([@"NEED_SIGNIN" isEqualToString:statusString]) {
        if (requestedLoginView) {
            requestedLoginView = false;
            // -- open url only once !! -- //
            assert([JSON objectForKey:@"url"]);
            NSString *loginPageUrlString = [jsonDictionary objectForKey:@"url"];
            NSURL *loginPageURL = [NSURL URLWithString:loginPageUrlString];
            assert(loginPageURL);
            [webView loadRequest:[NSURLRequest requestWithURL:loginPageURL]];
        }
        
        NSString *pollUrlString = [jsonDictionary objectForKey:@"poll"];
        assert(pollUrlString);
        
        NSString *pollTimeIntervalString = [jsonDictionary objectForKey:@"poll_rate_ms"];
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
            NSString *username = [jsonDictionary objectForKey:@"username"];
            NSString *token = [jsonDictionary objectForKey:@"token"];
            
            [self successfullLoginWithUsername:username token:token];
            
        } else if ([@"REFUSED" isEqualToString:statusString]) {
            
            NSString *message = [jsonDictionary objectForKey:@"message"];
            [self abordedWithReason:message];
            
        } else if ([@"ERROR" isEqualToString:statusString]) {
           
            NSString *message = [jsonDictionary objectForKey:@"message"];
            assert(message);
            
            NSString *errorCode = nil;
            if ([jsonDictionary objectForKey:@"id"]) {
                errorCode = [jsonDictionary objectForKey:@"id"];
            }
            
            [self abordedWithError:[[[NSError alloc] initWithDomain:PryvSDKDomain code:0 userInfo:jsonDictionary] autorelease]];
            
            
        } else {
            
            NSLog(@"poll request unknown status: %@", statusString); 
            NSString *message = NSLocalizedString(@"Unknown Error",);
            if ([jsonDictionary objectForKey:@"message"]) {
                message = [jsonDictionary objectForKey:@"message"];
            }
            
            [self abordedWithError:[[[NSError alloc] initWithDomain:PryvSDKDomain code:0 userInfo:jsonDictionary] autorelease]];
            
        }
    }
    
}

-  (void)successfullLoginWithUsername:(NSString *)username token:(NSString *)token
{
    [self.delegate pyWebLoginSuccess:[PYClient createAccessWithUsername:username andAccessToken:token]];
    [self close];
}

-  (void)abordedWithReason:(NSString *)reason
{
    [self.delegate pyWebLoginAborded:reason];
    [self close];
}

-  (void)abordedWithError:(NSError *)error
{
    [self.delegate pyWebLoginError:error];
    [self close];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [super viewDidUnload];
}
@end
