//
//  WrapperXSLT.m
//  
//
//  Created by James Balnaves on 3/4/21.
//

#import <Foundation/Foundation.h>
#import "WrapperXSLT.h"
#import "xsltInternals.h"

@implementation WrapperXSLT

+(NSString *) transformXML:(NSString *)xmlString withStyleSheet:(NSString *)styleString {
    
    xmlDocPtr xmlPtr = xmlReadMemory(xmlString.UTF8String, (int)xmlString.length, NULL, NULL, 0);
    xmlDocPtr stylePtr = xmlReadMemory(styleString.UTF8String, (int)styleString.length, NULL, NULL, 0);
    
    if (xmlPtr == NULL || stylePtr == NULL) {
        NSLog(@"Unable to read input");
        return nil;
    }
    
    xsltStylesheetPtr stylesheet = xsltParseStylesheetDoc(stylePtr);
    
    if (stylesheet == NULL) {
        NSLog(@"Unable to parse stylesheet");
        return nil;
    }
    
    xmlDocPtr result = xsltApplyStylesheet(stylesheet, xmlPtr, NULL);
    
    if (stylesheet == NULL) {
        NSLog(@"Unable to apply stylesheet");
        return nil;
    }
    
    xmlChar* xmlResultBuffer = NULL;
    int length = 0;
    xsltSaveResultToString(&xmlResultBuffer, &length, result, stylesheet);
    
    NSString* resultString = [NSString stringWithCString: (char *)xmlResultBuffer encoding: NSUTF8StringEncoding];
    
    free(xmlResultBuffer);
    xsltFreeStylesheet(stylesheet);
    xsltCleanupGlobals();
    xmlCleanupParser();
    
    return resultString;
}

@end
