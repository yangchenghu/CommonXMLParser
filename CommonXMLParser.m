//
//  CommonXMLParser.m
//  CommonPay
//
//  Created by yangchenghu on 16/1/5.
//  Copyright © 2016年 yangchenghu. All rights reserved.
//

#import "CommonXMLParser.h"

@interface CommonXMLParser ()
{
    NSXMLParser * _xmlParser;
    
    NSString * _strItemKey;
    
    NSMutableDictionary * _muDicReslut;
    
    NSMutableArray * _muArrContainerStack;//堆栈，找到父节点
    
    NSMutableDictionary * _mDicPointer;//指针
    
    NSMutableArray * _muArrKeysStack;
    
    FindKeyBlock _findKey;
    
    CompletionBlock _completion;
}

@end

@implementation CommonXMLParser

+ (instancetype)paser
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)GenStringFromObject:(NSDictionary *)dicObj
{
    NSMutableString * mString = [NSMutableString string];
    
    for (NSString * strKey in [dicObj allKeys]) {
        
        if ([dicObj[strKey] isKindOfClass:[NSDictionary class]]) {
            [mString appendFormat:@"\n<%@>\n%@\n</%@>", strKey, [self GenStringFromObject:dicObj[strKey]], strKey];
        }
        else {
            [mString appendFormat:@"<%@>%@</%@>", strKey, dicObj[strKey], strKey];
        }
    }
    
    return mString;
}


- (void)parserString:(NSString *)string findkey:(FindKeyBlock)findkeyblock completion:(CompletionBlock)completionblock
{
    if (nil == _muDicReslut) {
        _muDicReslut = [NSMutableDictionary dictionary];
    }
    
    if (nil == _muArrContainerStack) {
        _muArrContainerStack = [NSMutableArray array];
    }
    
    if (nil == _muArrKeysStack) {
        _muArrKeysStack = [NSMutableArray array];
    }
    
    if (nil != _xmlParser) {
        _xmlParser = nil;
    }
    
    _xmlParser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_xmlParser setDelegate:self];
    
    _findKey = [findkeyblock copy];
    
    _completion = [completionblock copy];
    
    [_xmlParser parse];
}


#pragma mark - NSXMLParserDelegate

//解析文档开始
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    [_muDicReslut removeAllObjects];
    [_muArrContainerStack removeAllObjects];
    [_muArrKeysStack removeAllObjects];

    _mDicPointer = _muDicReslut;
    
    [_muArrContainerStack addObject:_mDicPointer];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    _strItemKey = [elementName copy];

    if (0 !=  _muArrKeysStack.count) {
        if (nil == _mDicPointer[_muArrKeysStack.lastObject]) {
            NSMutableDictionary * muDicTemp = [NSMutableDictionary dictionary];
            _mDicPointer[_muArrKeysStack.lastObject] = muDicTemp;
            _mDicPointer = muDicTemp;
            [_muArrContainerStack addObject:_mDicPointer];
        }
        else {
            [_muArrContainerStack addObject:_mDicPointer];
            _mDicPointer = _mDicPointer[_muArrKeysStack.lastObject];
        }
    }
    
    [_muArrKeysStack addObject:_strItemKey];
    
    if (_findKey) {
        _findKey(_strItemKey, [_muArrKeysStack copy]);
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSInteger iSpaceCout = 0;
    for (NSInteger i = 0 ; i < string.length ; i ++) {
        NSString * strChart = [string substringWithRange:NSMakeRange(i, 1)];
        
        if (![@" " isEqualToString:strChart]) {
            string = [string substringFromIndex:i];
            break;
        }
        
        iSpaceCout++;
    }
    if (iSpaceCout != string.length) {
        [_mDicPointer setObject:string forKey:_strItemKey];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    [_muArrContainerStack removeLastObject];
    _mDicPointer = [_muArrContainerStack lastObject];
    
    [_muArrKeysStack removeLastObject];

}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    if (0 != _muDicReslut.count) {
        _completion(YES, [_muDicReslut copy]);
    }
    else {
        _completion(NO, nil);
    }
    
    [_muDicReslut removeAllObjects];
    [_muArrContainerStack removeAllObjects];
    [_muArrKeysStack removeAllObjects];
}




@end
