//
//  PYWebLoginViewController.m
//  PryvApiKit
//
//  Created by Nenad Jelic on 5/3/13.
//  Copyright (c) 2013 Pryv. All rights reserved.
//

#import "PYAsyncService.h"
#import "PYClient.h"
#import "PYClient+Utils.h"
#import "PYError.h"
#import "PYErrorUtility.h"
#import "PYAPIConstants.h"
#import "PYkNotifications.h"
#import "PYWebLoginViewController.h"
#import "PYJSONUtility.h"

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
@interface PYWebLoginViewController ()
#else
@interface PYWebLoginViewController () <UIWebViewDelegate> {
    UIBarButtonItem *loadingActivityIndicator;
    UIWebView *webView;
    UIActivityIndicatorView *loadingActivityIndicatorView;
    UIBarButtonItem *refreshBarButtonItem;
}
#endif
@property (nonatomic) BOOL closeReliesOnDelegate;
@property (nonatomic, retain) NSArray *permissions;
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, retain) NSTimer *pollTimer;
@property (nonatomic, retain) NSTimer *statusUrlTimer;
@property (nonatomic, copy) NSString *pollURL;
@property (nonatomic) BarStyleType barStyleType;
@property (nonatomic, assign) id  delegate;
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
@property (nonatomic, assign) WebView *webView;
#endif

+ (NSMutableURLRequest*) registrationRequest:(NSString *)fullURL
                                      method:(PYRequestMethod)method
                                    postData:(NSDictionary *)postData
                                     success:(PYClientSuccessBlockDict)successHandler
                                     failure:(PYClientFailureBlock)failureHandler;

@end


@implementation PYWebLoginViewController

@synthesize closeReliesOnDelegate;
@synthesize delegate;
@synthesize pollTimer;
@synthesize statusUrlTimer;
@synthesize pollURL;
@synthesize appID;
@synthesize permissions;
@synthesize barStyleType;

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
@synthesize webView;
#endif


NSUInteger iteration;

NSString *username;
NSString *token;

BOOL closing;

+ (PYWebLoginViewController *)requestConnectionWithAppId:(NSString *)appID andPermissions:(NSArray *)permissions delegate:(id ) delegate
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
                                             withWebView:(WebView **)webView
#endif
{
    return [PYWebLoginViewController requestConnectionWithAppId:appID andPermissions:permissions andBarStyle:BarStyleTypeCancel delegate:delegate
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
                                                    withWebView:webView
#endif
            
            
            ];
    
}


+ (PYWebLoginViewController *)requestConnectionWithAppId:(NSString *)appID andPermissions:(NSArray *)permissions
                                             andBarStyle:(BarStyleType)barStyleType delegate:(id ) delegate
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
                                             withWebView:(WebView **)webView
#endif
{
    PYWebLoginViewController *login = [[PYWebLoginViewController alloc] init];
    login.closeReliesOnDelegate = NO;
    login.permissions = permissions;
    login.appID = appID;
    login.delegate = delegate;
    login.barStyleType = barStyleType;
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
    login.webView = *(webView);
#endif
    
    [login openOn];
    
    return [login autorelease];
}

- (PYWebLoginViewController* )openOn
{
    //[self init];
    closing = NO;
    
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
    [self cleanURLCache];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewHidden:)
                                                 name:kPYWebViewLoginNotVisibleNotification object:nil];
    
    [[self.webView mainFrame] loadHTMLString:@"<html><head></head><body style=\"font-family: HelveticaNeue;position: absolute;top: 50%;left: 50%;text-align: center;margin-left: -64px;\"><div style=\"letter-spacing: 2px;\">Loading...<span style=\"font-size: 14px;color: #bebebe;letter-spacing: 1px;display: block;\">Please be patient</span></div></body></html>" baseURL:nil];
    [self requestLoginView];
#else
    NSLog(@"PYWebLoginViewControlleriOs:Open on");
    
    // -- navigation bar -- //
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.navigationBar.translucent = NO;
    
    if (self.barStyleType == BarStyleTypeHome) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo target:self action:@selector(reload:)] autorelease];
    } else {
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
        
        refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload:)];
        self.navigationItem.leftBarButtonItem = refreshBarButtonItem;
    }
    
    // -- loading Indicator --//
    loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    loadingActivityIndicator = [[UIBarButtonItem alloc] initWithCustomView:loadingActivityIndicatorView];
    
    [self startLoading];
    
    // -- webview -- //
    [self cleanURLCache];
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    webView = [[UIWebView alloc] initWithFrame:applicationFrame];
    [webView setDelegate:self];
    [webView setBackgroundColor:[UIColor grayColor]];
    [webView loadHTMLString:@"<html><head></head><body style=\"font-family: HelveticaNeue;position: absolute;top: 50%;left: 50%;text-align: center;margin-left: -64px;\"><div style=\"letter-spacing: 2px;\">Loading...<span style=\"font-size: 14px;color: #bebebe;letter-spacing: 1px;display: block;\">Please be patient</span></div></body></html>" baseURL:nil];
    
    self.view = webView;
    
    // -- show on delegate's UIController -- //
    if ([self.delegate pyWebLoginGetController]) {
        [[self.delegate pyWebLoginGetController] presentViewController:navigationController animated:YES completion:nil];
    } else {
        [self.delegate pyWebLoginShowUIViewController:navigationController];
        self.closeReliesOnDelegate = YES;
    }
    
    
    [navigationController release];
#endif
    return self;
}

- (void)close
{
    if (closing) return;
    closing = YES;
    [self.pollTimer invalidate];
    [self.statusUrlTimer invalidate];
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
#else
    if (! self.closeReliesOnDelegate) {
        [self dismissViewControllerAnimated:YES completion:^{ }];
    }
#endif
}

- (void)dealloc
{
    self.delegate = nil;
    [pollTimer invalidate];
    [pollTimer release];
    [statusUrlTimer invalidate];
    [statusUrlTimer release];
    [pollURL release];
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#else
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [webView release];
    [permissions release];
    [appID release];
    [refreshBarButtonItem release];
    [loadingActivityIndicatorView release];
    [loadingActivityIndicator release];
#endif
    [super dealloc];
}

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060

#pragma mark - NSViewDelegate



#else

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
#endif

#pragma mark - init


#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
- (void)viewHidden:(NSNotification *)notification{
    //NSLog(@"Notification received : %@",notification);
    [self abortedWithReason:@"Canceled by user"];
}

#else
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self requestLoginView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // kill the timer if one existed
    [self.pollTimer invalidate];
    [self.statusUrlTimer invalidate];
}

#pragma mark - Target Actions


- (IBAction)cancel:(id)sender
{
    [self abortedWithReason:@"Canceled by user"];
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
    self.navigationItem.leftBarButtonItem = loadingActivityIndicator;
}

- (void)stopLoading
{
    refreshBarButtonItem.enabled = YES;
    [loadingActivityIndicatorView stopAnimating];
    self.navigationItem.leftBarButtonItem = refreshBarButtonItem;
}

#endif

// POST request to /access to obtain a login page URL and load the contents of the URL
//      (which is a login form) to a child webView
//      activate a timer loop

static BOOL s_requestedLoginView = NO;
- (void)requestLoginView
{
    s_requestedLoginView = YES;
    // TODO extract the url to a more meaningful place
    NSString *preferredLanguageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    //    NSDictionary *postData = @{
    //                               // TODO extract the app id some where to constants
    //                               @"requestingAppId": self.appID,
    //                               @"returnURL": @"false",
    //                               @"languageCode" : preferredLanguageCode,
    //                               @"requestedPermissions": self.permissions
    //                               };
    NSArray *objects = [NSArray arrayWithObjects:self.appID, @"false", preferredLanguageCode, self.permissions, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"requestingAppId", @"returnURL", @"languageCode", @"requestedPermissions", nil];
    NSDictionary *postData = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    
    NSString *fullPathString = [NSString stringWithFormat:@"%@://access%@/access", kPYAPIScheme, [PYClient defaultDomain]];
    
    //block typeof trick doesn't work on Mac OS X, but using self does not create memory leak
    //__block __typeof__(self) bself = self;
    
    [PYWebLoginViewController registrationRequest:fullPathString
                                           method:PYRequestMethodPOST
                                         postData:postData
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *responseDict) {
                                              if (!self) return;
                                              [self handlePollSuccess:responseDict];
                                              [self checkStatusInURL:nil];
                                          } failure:^(NSError *error) {
                                              if (!self) return;
                                              [self handleFailure:error];
                                          }];
    
}

- (void)handleFailure:(NSError *)error
{
    NSLog(@"[HTTPClient Error]: %@", error);
    NSString *content = [NSString stringWithFormat:@"<html><head></head><body style=\"font-family: HelveticaNeue;position: absolute;top: 50%%;left: 50%%;text-align: center;margin-left: -64px;\"><div style=\"letter-spacing: 2px;\">Signup Error... %@<span style=\"font-size: 14px;color: #bebebe;letter-spacing: 1px;display: block;\">Please be patient</span></div></body></html>",[error localizedDescription]];
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
    [[webView mainFrame] loadHTMLString:content baseURL:nil];
#else
    [webView loadHTMLString:content baseURL:nil];
#endif
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        [self abortedWithError:error];
    });
    
}


- (void)pollURL:(NSString *)pollURLString withTimeInterval:(NSTimeInterval)pollTimeInterval
{
   
    
    //NSLog(@"create a poll request to %@ with interval: %f", pollURL, pollTimeInterval);
    NSLog(@"create a poll request with interval: %f", pollTimeInterval);
    
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
#else
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSLog(@"stop polling if app is in background");
        return;
    }
#endif
    
    
    // reset previous timer if one existed
    [self.pollTimer invalidate];
    
    if (closing) return;
    
    //update url to poll
    self.pollURL = pollURLString;
    
    // schedule a GET reqest in seconds amount stored in pollTimeInterval
    //__block __typeof__(self) bself = self;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.pollTimer = [NSTimer scheduledTimerWithTimeInterval:pollTimeInterval
                                                          target:self
                                                        selector:@selector(timerBlock:)
                                                        userInfo:nil
                                                         repeats:NO
                          ];
    });
    
}


- (void)checkStatusInURL:(NSTimer *)timer
{
    NSString* currentUrl = nil;
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
    // Not working
   // currentUrl = [[webView mainFrame] stringByEvaluatingJavaScriptFromString:@"window.location.href"];
#else
    currentUrl = [webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
#endif
    
    
    NSLog(@"Current URL: %@",currentUrl);
    
    if (currentUrl) {
        
        NSArray* foo = [currentUrl componentsSeparatedByString: @"#"];
        if (foo.count > 1) {
            NSString* status = [foo lastObject];
            
            NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
            NSArray *urlComponents = [status componentsSeparatedByString:@"&"];
            
            
            for (NSString *keyValuePair in urlComponents)
            {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
                NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
                
                [queryStringDictionary setObject:value forKey:key];
            }
            if ([queryStringDictionary objectForKey:@"status"]) {
                return [self handlePollSuccess:queryStringDictionary];
            }
        }
        
    }
    
    // reset previous timer if one existed
    [self.statusUrlTimer invalidate];
    
    if (closing) return;
    
    // schedule a GET reqest in seconds amount stored in pollTimeInterval
    //__block __typeof__(self) bself = self;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusUrlTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                               target:self
                                                             selector:@selector(checkStatusInURL:)
                                                             userInfo:nil
                                                              repeats:NO
                               ];
    });
    
    
}



- (void)timerBlock:(NSTimer *)timer {
    
    [PYWebLoginViewController registrationRequest:pollURL
                                           method:PYRequestMethodGET
                                         postData:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                              if (!self) return;
                                              [self handlePollSuccess:JSON];
                                          } failure:^(NSError *error) {
                                              if (!self) return;
                                              [self handleFailure:error];
                                          }];
}



- (void)handlePollSuccess:(NSDictionary*) jsonDictionary
{
    
    
    // check status
    NSString *statusString = [jsonDictionary objectForKey:@"status"];
    
    if ([@"NEED_SIGNIN" isEqualToString:statusString]) {
        if (s_requestedLoginView) {
            s_requestedLoginView = NO;
            // -- open url only once !! -- //
            assert([jsonDictionary objectForKey:@"url"]);
            NSString *loginPageUrlString = [jsonDictionary objectForKey:@"url"];
            NSURL *loginPageURL = [NSURL URLWithString:loginPageUrlString];
            assert(loginPageURL);
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
            [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:loginPageURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]];
#else
            [webView loadRequest:[NSURLRequest requestWithURL:loginPageURL]];
#endif
            
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
            [self abortedWithReason:message];
            
        } else if ([@"ERROR" isEqualToString:statusString]) {
            
            NSString *message = [jsonDictionary objectForKey:@"message"];
            assert(message);
            
            NSString *errorCode = nil;
            if ([jsonDictionary objectForKey:@"id"]) {
                errorCode = [jsonDictionary objectForKey:@"id"];
            }
            
            [self abortedWithError:[[[NSError alloc] initWithDomain:PryvSDKDomain code:0 userInfo:jsonDictionary] autorelease]];
            
            
        } else {
            
            NSLog(@"poll request unknown status: %@", statusString);
            NSString *message = NSLocalizedString(@"Unknown Error",);
            if ([jsonDictionary objectForKey:@"message"]) {
                message = [jsonDictionary objectForKey:@"message"];
            }
            
            [self abortedWithError:[[[NSError alloc] initWithDomain:PryvSDKDomain code:0 userInfo:jsonDictionary] autorelease]];
            
        }
    }
    
}

-  (void)successfullLoginWithUsername:(NSString *)username token:(NSString *)token
{
    [self.delegate pyWebLoginSuccess:[PYClient createConnectionWithUsername:username andAccessToken:token]];
    [self close];
}

-  (void)abortedWithReason:(NSString *)reason
{
    [self.delegate pyWebLoginAborted:reason];
    [self close];
}

-  (void)abortedWithError:(NSError *)error
{
    [self.delegate pyWebLoginError:error];
    [self close];
}

- (void)cleanURLCache
{
    // remove all cached responses
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

/**
 * Prepare the request for the API
 */
+ (NSMutableURLRequest*) registrationRequest:(NSString *)fullURL
                                      method:(PYRequestMethod)method
                                    postData:(NSDictionary *)postData
                                     success:(PYClientSuccessBlockDict)successHandler
                                     failure:(PYClientFailureBlock)failureHandler {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSURL *url;
    
    if (!fullURL) {
        [NSException raise:@"There is no fullURL string" format:@"fullURL can't be nil"];
    }
    
    url = [NSURL URLWithString:fullURL];
    
    
    [request setURL:url];
    NSDictionary *postDataa = postData;
    
    if ( (method == PYRequestMethodGET  && postDataa != nil))
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"postData must be nil for GET method or DELETE method" ];
    }
    
    if (method == PYRequestMethodPOST) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSString *httpMethod = [PYClient getMethodName:method];
    request.HTTPMethod = httpMethod;
    request.timeoutInterval = 60.0f;
    
    if (postDataa) {
        request.HTTPBody = [PYJSONUtility getDataFromJSONObject:postDataa];
    }
    [PYAsyncService JSONRequestServiceWithRequest:request success:successHandler
                                          failure:^(NSURLRequest *req, NSHTTPURLResponse *resp, NSError *error, NSMutableData *responseData)
     {
         
         if (failureHandler) failureHandler(error);
     }];
    return request;
}


#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
#else
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}
#endif
@end
