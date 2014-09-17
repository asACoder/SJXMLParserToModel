//
//  SJXMLParserToModel.m
//  SJXMLParserToModel
//
//  Created by fushijian on 14-9-16.
//
//

#import "SJXMLParserToModel.h"

#import <objc/runtime.h>
#import <objc/message.h>

@interface SJXMLParserToModel() <NSXMLParserDelegate>
{
    NSMutableArray*     _parserObjcsArr;
    NSMutableArray*     _typesArr;
    
    NSMutableString*    _elementValue;
    
    id                  _objc;
    id                  _parseringObjc;
    
    BOOL                _isRoot;
    BOOL                _isEndParseObjc;
    BOOL                _isSuccess; // YES parse success
}


@property(nonatomic,retain) NSXMLParser *parser;
@property(nonatomic,retain) NSDictionary *infoDict;
@property(nonatomic,retain) NSString *toCls;


@end


@implementation SJXMLParserToModel

/*
 * parser XML to custom class
 *
 *  @para:cls
 *        the name of custom class
 *
 *  @para:infoDict
 *          key:elementname in xml or property in custom class
 *          value: custom class name
 *
 */
-(id) SJXMLParserWithXMLData:(NSData*)xml toCls:(NSString*)cls infoDict:(NSDictionary *)infoDict
{
    
    if (!self.parser) {
        self.parser = [NSXMLParser alloc];
    }
    id suc = [self.parser initWithData:xml];
    if (suc == nil) return nil;
    self.toCls = cls;
    self.infoDict = infoDict;
    
    [self.parser setDelegate:self];
    [self.parser parse];
    
    return _isSuccess ? _objc : nil;
    
}

#pragma mark -NSXMLParserDelegate

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    _isSuccess = NO;
    _isRoot = YES;
    if (!_parserObjcsArr) {
        _parserObjcsArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    if (!_typesArr) {
        _typesArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    
    if (!_elementValue) {
        _elementValue = [[NSMutableString alloc] initWithCapacity:30];
    }
    
    _objc = [[NSClassFromString(self.toCls) alloc] init];
    _parseringObjc = _objc;
    [_parserObjcsArr addObject:_parseringObjc];
    [_typesArr addObject:self.toCls];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSAssert(_parserObjcsArr.count == 0, @"fail");
    NSAssert(_typesArr.count == 0, @"fail");
    
    _isSuccess = YES;
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    _isEndParseObjc = NO;
    
    if (_isRoot) {
        
        [self parserAttributeDict:attributeDict forObj:_parseringObjc];
        _isRoot = NO;
        
    }else{
        
        NSString *type = [self getTypeOfProperty:elementName inObjc:_parseringObjc];
        
        if (type == nil ){
            
            [_typesArr addObject:@""];
            
        }else if ([type isEqualToString:@"NSString"]){
            
            [_typesArr addObject:@"NSString"];
            [self parserAttributeDict:attributeDict forObj:_parseringObjc];

        }else if([type isEqualToString:@"NSMutableArray"]){
            
            NSMutableArray *objArr =(NSMutableArray*) objc_msgSend(_parseringObjc,NSSelectorFromString(elementName));
            
            if (objArr == nil) {
                
                objArr = [[NSMutableArray alloc] initWithCapacity:10];
                [_parseringObjc setValue:objArr forKeyPath:elementName];
            }
            
            NSString *objType = self.infoDict[elementName];
            id obj = [[NSClassFromString(objType) alloc] init];
            
            _parseringObjc = obj;
            [self parserAttributeDict:attributeDict forObj:_parseringObjc];
            [_parserObjcsArr addObject:_parseringObjc];
            [_typesArr addObject:@"NSMutableArray"];
            
            [objArr addObject:_parseringObjc];
            
        }else{ // custom class
            
            id obj = [[NSClassFromString(type) alloc] init];
            [_parseringObjc setValue:obj forKey:elementName];
            
            _parseringObjc = obj;
            [self parserAttributeDict:attributeDict forObj:_parseringObjc];
            
            [_parserObjcsArr addObject:_parseringObjc];
            [_typesArr addObject:type];
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_isEndParseObjc) {
        return;
    }
    
    NSString *type = [_typesArr lastObject];
    
    if ([type isEqualToString:@"NSString"] ) {
        [_elementValue appendString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    _isEndParseObjc = YES;
    
    NSString *type = [_typesArr lastObject];
    
    if ([type isEqualToString:@"NSString"]) {
        
        if ([_parseringObjc respondsToSelector:NSSelectorFromString(elementName)]) {
            [_parseringObjc setValue:[NSString stringWithString:_elementValue] forKey:elementName];
        }
        // clear the _elementValue
        [_elementValue deleteCharactersInRange:NSMakeRange(0, _elementValue.length)];
        
    }else if ([type isEqualToString:@"NSMutalbeArray"]) {
        
        [_parserObjcsArr removeLastObject];
        _parseringObjc = [_parserObjcsArr lastObject];
        
    }else if(![type isEqualToString:@""]){ // custom class
        
        [_parserObjcsArr removeLastObject];
        _parseringObjc = [_parserObjcsArr lastObject];
    }
    [_typesArr removeLastObject];
    
}


-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self recoverInitalState];
}

// 恢复初始状态，一遍下一次调用能够正确解析
-(void)recoverInitalState
{
    _isSuccess = NO;
    _isRoot = YES;
    [_parserObjcsArr removeAllObjects];
    [_typesArr removeAllObjects];
    if (_elementValue.length) {
        [_elementValue deleteCharactersInRange:NSMakeRange(0, _elementValue.length)];
    }
}


#pragma mark -
-(NSString*) getTypeOfProperty:(NSString*)property inObjc:(id)objc
{
    objc_property_t propert_t =  class_getProperty([objc class],[property cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!propert_t) return nil; //xml has,but Model not
    
    const char *pAttribute =  property_getAttributes(propert_t);
    
    NSString *attribute = [NSString stringWithUTF8String:pAttribute];
    
    NSArray *arr = [attribute componentsSeparatedByString:@"\""];
    
    return arr[1];
}


#pragma mark -解析节点属性
-(void) parserAttributeDict:(NSDictionary*)attributeDict forObj:(id)obj
{
    NSArray *allKeys = [attributeDict allKeys];
    
    for (NSString *key in allKeys) {
        
        if ([obj respondsToSelector:NSSelectorFromString(key)]) {
            
            [obj setValue:attributeDict[key] forKey:key];
        }
    }
}

@end
