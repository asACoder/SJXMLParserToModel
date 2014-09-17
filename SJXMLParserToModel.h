//
//  SJXMLParserToModel.h
//  SJXMLParserToModel
//
//  Created by fushijian on 14-9-16.
//
//

#import <Foundation/Foundation.h>

@interface SJXMLParserToModel : NSObject

-(id) SJXMLParserWithXMLData:(NSData*)xml toCls:(NSString*)cls infoDict:(NSDictionary*)infoDict;

@end
