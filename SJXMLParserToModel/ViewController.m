//
//  ViewController.m
//  SJXMLParserToModel
//
//  Created by fushijian on 14-9-16.
//
//

#import "ViewController.h"

#import "SJXMLParserToModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* str =  [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:str];
    
    SJXMLParserToModel *SJXMLParser = [[SJXMLParserToModel alloc] init];
    
    //断点打在此处，可以看到 已经成功解析
    id obj =  [SJXMLParser SJXMLParserWithXMLData:data toCls:@"AddressesModel" infoDict:@{@"person": @"Person",@"address":@"Address"}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
