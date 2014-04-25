//
//  RiseStyleMenuViewController.m
//  BounceButtonExample
//
//  Created by Agus Soedibjo on 28/3/14.
//  Copyright (c) 2014 Agus Soedibjo. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RiseStyleMenuViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "Reachability.h"
@interface RiseStyleMenuViewController(){
    BOOL canConnect;

}
@property (nonatomic) ASOAnimationStyle progressiveORConcurrentStyle;
@end

@implementation RiseStyleMenuViewController
@synthesize imgPicker,loadingView,siteView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Set the 'menu button
    [self.menuButton initAnimationWithFadeEffectEnabled:YES]; // Set to 'NO' to disable Fade effect between its two-state transition
    
    // Get the 'menu item view' from storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *menuItemsVC = (UIViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"ArchMenu"];
    self.menuItemView = (BounceButtonView *)menuItemsVC.view;
    
    NSArray *arrMenuItemButtons = [[NSArray alloc] initWithObjects:self.menuItemView.menuItem1,
                                   self.menuItemView.menuItem2,
                                   self.menuItemView.menuItem3,
                                   self.menuItemView.menuItem4,
                                   nil]; // Add all of the defined 'menu item button' to 'menu item view'
    [self.menuItemView addBounceButtons:arrMenuItemButtons];
    
    // Set the bouncing distance, speed and fade-out effect duration here. Refer to the ASOBounceButtonView public properties
    [self.menuItemView setSpeed:[NSNumber numberWithFloat:0.3f]];
    [self.menuItemView setBouncingDistance:[NSNumber numberWithFloat:0.3f]];
    
    [self.menuItemView setAnimationStyle:ASOAnimationStyleRiseProgressively];
   // [self.changeAnimationStyleButton setTitle:@"Progressively" forState:UIControlStateNormal];
    self.progressiveORConcurrentStyle = ASOAnimationStyleRiseProgressively;
    
    // Set as delegate of 'menu item view'
    [self.menuItemView setDelegate:self];
    //////////
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.delegate = self;
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    siteView.delegate = self;
    siteView.scalesPageToFit = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    // Tell 'menu button' position to 'menu item view'
    [self.menuItemView setAnimationStartFromHere:self.menuButton.frame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButtonAction:(id)sender
{
    if ([sender isOn]) {
        // Show 'menu item view' and expand its 'menu item button'
        [self.menuButton addCustomView:self.menuItemView];
        [self.menuItemView expandWithAnimationStyle:self.progressiveORConcurrentStyle];
    }
    else {
        // Collapse all 'menu item button' and remove 'menu item view'
        [self.menuItemView collapseWithAnimationStyle:self.progressiveORConcurrentStyle];
        [self.menuButton removeCustomView:self.menuItemView interval:[self.menuItemView.collapsedViewDuration doubleValue]];
    }
}

#pragma mark - Menu item view delegate method

- (void)didSelectBounceButtonAtIndex:(NSUInteger)index
{
    // Collapse all 'menu item button' and remove 'menu item view' once a menu item is selected
    [self.menuButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    // Set your custom action for each selected 'menu item button' here
    NSString *alertViewTitle = [NSString stringWithFormat:@"Menu Item %x is selected", (short)index];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertViewTitle message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)willAnimateRotationToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    // Update 'menu button' position to 'menu item view' everytime there is a change in device orientation
    [self.menuItemView setAnimationStartFromHere:self.menuButton.frame];
}



//////////
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    loadingView.hidden=NO;
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    __block NSDictionary *metaDataDict;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        metaDataDict = [representation metadata];
        NSLog(@"%@",[metaDataDict  objectForKey:@"GPS"]);
        NSDictionary*gpsDic= [metaDataDict  objectForKey:@"{GPS}"];
        // Build the url and loadRequest
        NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/?ie=UTF8&hq=&ll=%@,%@&z=13",[gpsDic objectForKey:@"Latitude"],[gpsDic objectForKey:@"Longitude"]];
        
        
        
  NSString*mapHtml=[self prepareTheHtmlFileWithLat:[gpsDic objectForKey:@"Latitude"] andLang:[gpsDic objectForKey:@"Longitude"]];
        //[siteView loadHTMLString:mapHtml baseURL:nil];

        [self checkBeforeLoadUrl];
        if (canConnect) {
            [siteView setHidden:NO];
            [siteView loadHTMLString:mapHtml baseURL:nil];
//            NSString *embedHTML = @"<html><head></head><body><p>Hello World</p></body></html>";
//            [siteView loadHTMLString: embedHTML baseURL: nil];
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",[error description]);
    }];
    
    
    [self dismissModalViewControllerAnimated:YES];

    
}
-(NSString*)prepareTheHtmlFileWithLat:(NSString*)lat andLang:(NSString*)lang{
    NSError * error;
    NSString * stringFromFile=@"";
    //NSString * stringFilepath = @"map.html";
    NSString *stringFilepath = [[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"];

    stringFromFile = [[NSString alloc] initWithContentsOfFile:stringFilepath
                                                     encoding:NSUTF8StringEncoding
                                                        error:&error];
    

    
    
  
    if (error)
        NSLog(@"Error reading file: %@", error.localizedDescription);
    
    // maybe for debugging...
    NSLog(@"contents: %@", stringFromFile);
//    latPreplace, lngPreplace)
    NSString *replacedString = [stringFromFile stringByReplacingOccurrencesOfString:@"latPreplace"
                                                                  withString:[NSString stringWithFormat:@"%@", lat]];
    
    
 replacedString=   [replacedString stringByReplacingOccurrencesOfString:@"lngPreplace"
                                                                         withString:[NSString stringWithFormat:@"%@", lang]];
    return replacedString;


}

- (IBAction)PickImage:(id)sender {
    imgPicker.delegate = self;
    imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentModalViewController:imgPicker animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    loadingView.hidden=YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    
    UIAlertView*Alert=[[UIAlertView alloc]initWithTitle:@"Connection" message:@"Check Internet Connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [Alert show];
    
    
}
//-(void)loadSite:(NSString*)urlString
//{
//    
//    // NSString* url = @"http://mobile.hemohj.gov.sa";
//    
//    //Load web view data
//    //NSString *strWebsiteUlr = [NSString stringWithFormat:@"http://mobile.hemohj.gov.sa"];
//    //NSString *strWebsiteUlr = [NSString stringWithFormat:urlString];
//    
//    // Load URL
//    
//    //Create a URL object.
//    NSURL *url = [NSURL URLWithString:urlString];
//    
//    //URL Requst Object
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    
//    //Load the request in the UIWebView.
//    [siteView loadRequest:requestObj];
//    
//    
//}
-(void)checkBeforeLoadUrl{
    Reachability* wifiReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
    NetworkStatus netStatus = [wifiReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"Access Not Available");
            UIAlertView*Alert=[[UIAlertView alloc]initWithTitle:@"Connection" message:@"Check Internet Connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [Alert show];
            canConnect=NO;
            
            break;
        }
            
        case ReachableViaWWAN:
        {
            NSLog(@"Reachable WWAN");
            //[self loadSite];
            canConnect=YES;
            
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Reachable WiFi");
            //[self loadSite];
            canConnect=YES;
            
            
            break;
        }
    }
    
}





@end
