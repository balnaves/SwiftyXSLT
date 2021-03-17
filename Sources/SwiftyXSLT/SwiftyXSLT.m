//
//  SwiftyXSLT.m
//  
//
//  Created by James Balnaves on 3/4/21.
//

#import <Foundation/Foundation.h>
#import "SwiftyXSLT.h"
#import "xsltInternals.h"

NSErrorDomain const SwiftyXSLTErrorDomain = @"SwiftyXSLTErrorDomain";

@implementation SwiftyXSLT

+ (SwiftyXSLT *)shared {
    static SwiftyXSLT *sharedSwiftyXSLT = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSwiftyXSLT = [[self alloc] init];
    });
    return sharedSwiftyXSLT;
}

- (NSString *)transformXML:(NSString *)xmlString withStyleSheet:(NSString *)styleString error:(NSError **)error {
    
    xmlDocPtr xmlPtr = xmlReadMemory(xmlString.UTF8String, (int)xmlString.length, NULL, NULL, 0);
    xmlDocPtr stylePtr = xmlReadMemory(styleString.UTF8String, (int)styleString.length, NULL, NULL, 0);
    
    if (xmlPtr == NULL || stylePtr == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to read input" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:missingInputString userInfo:errorDetail];
        return nil;
    }
    
    xsltStylesheetPtr stylesheet = xsltParseStylesheetDoc(stylePtr);
    
    if (stylesheet == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to parse stylesheet" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotParseStylesheet userInfo:errorDetail];
        return nil;
    }
    
    xmlDocPtr result = xsltApplyStylesheet(stylesheet, xmlPtr, NULL);
    
    if (result == nil) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to apply stylesheet" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotApplyStylesheet userInfo:errorDetail];
        xsltFreeStylesheet(stylesheet);
        xsltCleanupGlobals();
        xmlCleanupParser();
        return nil;
    }
    
    xmlChar* xmlResultBuffer = nil;
    int length = 0;
    xsltSaveResultToString(&xmlResultBuffer, &length, result, stylesheet);
    
    NSString* resultString = nil;
    
    if (xmlResultBuffer != nil) {
        resultString = [NSString stringWithCString: (char *)xmlResultBuffer encoding: NSUTF8StringEncoding];
        free(xmlResultBuffer);
    }
    else {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to convert result to string" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotConvertResultToString userInfo:errorDetail];
        xsltFreeStylesheet(stylesheet);
        xsltCleanupGlobals();
        xmlCleanupParser();
        return nil;
    }
    
    xsltFreeStylesheet(stylesheet);
    xsltCleanupGlobals();
    xmlCleanupParser();
    return resultString;
}

@end
