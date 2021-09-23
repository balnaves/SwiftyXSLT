//
//  SwiftyXSLT.m
//  
//
//  Created by James Balnaves on 3/4/21.
//

#import <Foundation/Foundation.h>
#import "SwiftyXSLT.h"

@import libxslt;

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

- (NSString *)transformXML:(NSData *)xmlData withStyleSheet:(NSData *)styleData error:(NSError *__autoreleasing  _Nullable *)error {
    xmlDocPtr xmlPtr = xmlReadMemory(xmlData.bytes, (int)xmlData.length, NULL, NULL, 0);
    xmlDocPtr stylePtr = xmlReadMemory(styleData.bytes, (int)styleData.length, NULL, NULL, 0);
    
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

    if (stylesheet->forwards_compatible) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Incompatible XSL version. Only 1.1 features are supported." forKey:NSLocalizedDescriptionKey];
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
