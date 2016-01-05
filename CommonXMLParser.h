//
//  CommonXMLParser.h
//  CommonPay
//
//  Created by yangchenghu on 16/1/5.
//  Copyright © 2016年 yangchenghu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(BOOL bFinish, NSDictionary * dicResult);

typedef void(^FindKeyBlock)(NSString * strKey, NSArray * keysPath);

@interface CommonXMLParser : NSObject <NSXMLParserDelegate>

/**
 * @description 初始化
 * @param
 * @return
 */
+ (instancetype)paser;

/**
 * @description 将xml的string处理成对象
 * @param string xml的字符串
 * @param fliterkeyblock 关键词过滤器
 * @param completionblock 完成时的回调
 * @return
 */
- (void)parserString:(NSString *)string findkey:(FindKeyBlock)findkeyblock completion:(CompletionBlock)completionblock;

/**
 * @description 将对象序列化成xml字符串
 * @param
 * @return
 */
- (NSString *)GenStringFromObject:(NSDictionary *)dicObj;

@end
