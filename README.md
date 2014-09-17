SJXMLParserToModel
====
can parse xml to a custom class
-----

some classes can repress a xml, for example

<root>
    <status>suc</status>
    <person>
        <name>abc</name>
        <age>12</age>
    </person>
</root>

we can use two class to repress the xml 

@interface Person
@property(retain) NSString *name; // the name of property should be the same AS the name of the element in xml
@property(retain) NSString *age;
@end
 
@interface Example
@property(retain) NSString *status;
@property(retain) Person   *person;
@end


so we can parse the xml like this:
  
//assume the data is a instance of NSData reperss the xml

SJXMLParserToModel *SJXMLParser = [[SJXMLParserToModel alloc] init];
id obj =  [SJXMLParser SJXMLParserWithXML:data toCls:@"Example" infoDict:nil];
