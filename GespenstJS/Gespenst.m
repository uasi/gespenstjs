//
//  Gespenst.m
//  GespenstJS
//
//  Created by uasi on 11/03/11.
//  Copyright 2011 isdead.info. All rights reserved.
//

#import "Gespenst.h"


#define GespenstMajorVersion 1
#define GespenstMinorVersion 0
#define GespenstPatchVersion 0
#define GespenstVersionString @"1.0.0"


@interface Gespenst ()

- (void)inject;

@end


@implementation Gespenst

@synthesize window = window_;
@synthesize webView = webView_;
@synthesize args = args_;
@synthesize returnValue = returnValue_;
@synthesize loadStatus = loadStatus_;
@synthesize script = script_;
@synthesize state = state_;
@dynamic content;

- (id)init
{
    if ((self = [super init]) == nil) {
        return nil;
    }
    
    NSWindow *window = [[[NSWindow alloc]
                         initWithContentRect:[[NSScreen mainScreen] frame]
                         styleMask:NSResizableWindowMask
                         backing:NSBackingStoreBuffered
                         defer:NO] autorelease];
    [self setWindow:window];
    
    WebView *webView = [[[WebView alloc] init] autorelease];
    [self setWebView:webView];
    [[self window] setContentView:webView];
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSRange range = NSMakeRange(2, [arguments count] - 2);
    [self setArgs:[arguments subarrayWithRange:range]];
    [self setReturnValue:0];
    [self setLoadStatus:@""];
    [self setScript:@""];
    [self setState:@""];
    [[[self webView] windowScriptObject] evaluateWebScript:@"document.write('<body></body>')"];
    [[self webView] setFrameLoadDelegate:self];
    
    [self inject];

    return self;
}

- (void)inject
{
    [[[self webView] windowScriptObject] setValue:self forKey:@"phantom"];
}

- (void)finish:(BOOL)success
{
    [self setLoadStatus:(success ? @"success" : @"fail")];
    [[[self webView] windowScriptObject] evaluateWebScript:[self script]];
}

- (id)valueForKey:(NSString *)key
{
    if ([key isEqualToString:@"content_"])
        return [self content];
    
    return [super valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"content_"])
        [self setContent:value];
    
    return [super setValue:value forKey:key];
}

- (NSString *)content
{
    return [(DOMHTMLElement *)[[[[self webView] mainFrame] DOMDocument] documentElement] outerHTML];
}

- (void)setContent:(NSString *)content
{
    NSString *URLString = [[self webView] mainFrameURL];
    [[[self webView] mainFrame] loadHTMLString:content
                                       baseURL:[NSURL URLWithString:URLString]];
}

- (void)execute:(NSString *)fileName
{
    NSString *script = [NSString stringWithContentsOfFile:fileName
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    if (script == nil) {
        fprintf(stderr, "Can't open %s", [fileName cStringUsingEncoding:NSUTF8StringEncoding]);
        exit(1);
    }
    [self setScript:script];
    [[[self webView] windowScriptObject] evaluateWebScript:script];
}

- (void)exit:(NSInteger)code
{
    [self setReturnValue:code];
    [NSApp terminate:self];
}

- (void)open:(NSString *)address
{
    [[[self webView] mainFrame] stopLoading];
    [self setLoadStatus:@"loading"];
    NSURL *URL = [NSURL URLWithString:address];
    [[[self webView] mainFrame] loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (BOOL)render:(NSString *)fileName
{
    [[self webView] setMediaStyle:@"screen"];
    NSView *view = [[[[self webView] mainFrame] frameView] documentView];
    NSRect rect = [view bounds];
    
    if ([[[fileName pathExtension] lowercaseString] isEqualToString:@".pdf"]) {
        NSData *data = [view dataWithPDFInsideRect:rect];
        [data writeToFile:fileName atomically:NO];
        return YES;
    }
    
    // TODO
    NSLog(@"PNG rendering is not implemented yet");
    
    return NO;
}

- (void)sleep:(NSInteger)msecs
{
    NSTimeInterval interval = msecs / 1000.0;
    NSDate *startDate = [NSDate date];
    NSDate *limitDate = [NSDate dateWithTimeIntervalSinceNow:0.025];
    while (1) {
        [[NSRunLoop currentRunLoop] runUntilDate:limitDate];
        if ([[NSDate date] timeIntervalSinceDate:startDate] > interval) {
            break;
        }
    }
}

- (NSString *)userAgent
{
    return [[self webView] customUserAgent];
}

- (void)setUserAgent:(NSString *)userAgent
{
    [[self webView] setCustomUserAgent:userAgent];
}

- (NSDictionary *)version
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:GespenstMajorVersion], @"major",
            [NSNumber numberWithInt:GespenstMinorVersion], @"minor",
            [NSNumber numberWithInt:GespenstPatchVersion], @"patch",
            nil];
}

// TODO: setViewportSize

// for debugging

- (void)log:(id)object
{
    NSString *string = [NSString stringWithFormat:@"%@", object];
    NSLog(@"%@", string);
}

- (void)say:(id)object
{
    NSString *string = [NSString stringWithFormat:@"%@", object];
    printf("%s\n", [string cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end


@implementation Gespenst (WebFrameLoadDelegate)

- (void)webView:(WebView *)sender
didClearWindowObject:(WebScriptObject *)windowObject
       forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame]) {
        [self inject];
    }
}

- (void)webView:(WebView *)sender
didFailProvisionalLoadWithError:(NSError *)error
       forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame]) {
        [self finish:NO];
    }
}

- (void)webView:(WebView *)sender
didFailLoadWithError:(NSError *)error
       forFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame]) {
        [self finish:NO];
    }
}

- (void)webView:(WebView *)sender
didFinishLoadForFrame:(WebFrame *)frame
{
    if (frame == [sender mainFrame]) {
        [self finish:YES];
    }
}

@end


@implementation Gespenst (WebScripting)

+ (BOOL)isKeyExcludedFromWebScript:(const char *)key
{
    if (   !strcmp(key, "args_")
        || !strcmp(key, "loadStatus_")
        || !strcmp(key, "state_")
        || !strcmp(key, "userAgent_")
        || !strcmp(key, "version_")
        || !strcmp(key, "content_")
        ) {
        return NO;
    }
    return YES;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)selector
{
    if (
           selector == @selector(execute:)
        || selector == @selector(exit:)
        || selector == @selector(open:)
        || selector == @selector(render:)
        || selector == @selector(sleep:)
        || selector == @selector(log:)
        || selector == @selector(say:)
        ) {
        return NO;
    }
    return YES;
}

+ (NSString *)webScriptNameForKey:(const char *)key
{
    if (!strcmp(key, "args_"))
        return @"args";
    if (!strcmp(key, "loadStatus_"))
        return @"loadStatus";
    if (!strcmp(key, "state_"))
        return @"state";
    if (!strcmp(key, "userAgent_"))
        return @"userAgent";
    if (!strcmp(key, "version_"))
        return @"version";
    if (!strcmp(key, "content_"))
        return @"content";
    
    return [NSString stringWithCString:key
                              encoding:NSUTF8StringEncoding];
}

+ (NSString *)webScriptNameForSelector:(SEL)selector
{
    if (selector == @selector(execute:))
        return @"execute";
    if (selector == @selector(exit:))
        return @"exit";
    if (selector == @selector(open:))
        return @"open";
    if (selector == @selector(render:))
        return @"render";
    if (selector == @selector(sleep:))
        return @"sleep";
    if (selector == @selector(log:))
        return @"log";
    if (selector == @selector(say:))
        return @"say";
    
    return nil;
}

- (id)objectForWebScript
{
    return self;
}

@end