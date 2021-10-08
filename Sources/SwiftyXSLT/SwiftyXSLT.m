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

- (NSData *)transformXML:(NSData *)xmlData withStyleSheet:(NSData *)styleData error:(NSError *__autoreleasing  _Nullable *)error {
    xmlDocPtr xmlPtr = xmlReadMemory(xmlData.bytes, (int)xmlData.length, NULL, NULL, 0);
    xmlDocPtr stylePtr = xmlReadMemory(styleData.bytes, (int)styleData.length, NULL, NULL, 0);
    
    if (xmlPtr == NULL || stylePtr == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to read input" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:missingInputString userInfo:errorDetail];

        if (xmlPtr != NULL) {
            xmlFreeDoc(xmlPtr);
        }
        if (stylePtr != NULL) {
            xmlFreeDoc(stylePtr);
        }

        return nil;
    }
    
    xsltStylesheetPtr stylesheet = xsltParseStylesheetDoc(stylePtr);

    if (stylesheet == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to parse stylesheet" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotParseStylesheet userInfo:errorDetail];

        xmlFreeDoc(xmlPtr);
        xmlFreeDoc(stylePtr);
        xsltCleanupGlobals();
        xmlCleanupParser();

        return nil;
    }

    if (stylesheet->forwards_compatible) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Incompatible XSL version. Only 1.1 features are supported." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotParseStylesheet userInfo:errorDetail];

        xmlFreeDoc(xmlPtr);
        xsltFreeStylesheet(stylesheet);
        xsltCleanupGlobals();
        xmlCleanupParser();

        return nil;
    }
    
    xmlDocPtr result = xsltApplyStylesheet(stylesheet, xmlPtr, NULL);
    
    if (result == NULL) {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to apply stylesheet" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotApplyStylesheet userInfo:errorDetail];

        xmlFreeDoc(xmlPtr);
        xsltFreeStylesheet(stylesheet);
        xsltCleanupGlobals();
        xmlCleanupParser();

        return nil;
    }
    
    xmlChar *xmlResultBuffer = NULL;
    int length = 0;
    xsltSaveResultToString(&xmlResultBuffer, &length, result, stylesheet);
    
    NSData *resultData = nil;
    
    if (xmlResultBuffer != NULL) {
        resultData = [NSData dataWithBytesNoCopy:xmlResultBuffer length:length freeWhenDone:YES];
    }
    else {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:@"Unable to convert result to string" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:SwiftyXSLTErrorDomain code:cannotConvertResultToString userInfo:errorDetail];
    }

    xmlFreeDoc(xmlPtr);
    xsltFreeStylesheet(stylesheet);
    xmlFreeDoc(result);
    xsltCleanupGlobals();
    xmlCleanupParser();

    return resultData;
}

@end
