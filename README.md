SJXMLParserToModel
==================
SJXMLParserToModel can parse xml to custom class,can't parse xml to NSMutableArray.

as for xml below:

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE addresses SYSTEM "addresses.dtd">
<addresses owner="swilson">
    <person>
        <lastName>Doe</lastName>
        <firstName>John</firstName>
        <phone location="mobile">(201) 345-6789</phone>
        <email>jdoe@foo.com</email>
        <address>
            <street>100 Main Street</street>
            <city>Somewhere</city>
            <state>New Jersey</state>
            <zip>07670</zip>
        </address>
    </person>
</addresses>

we can define three class to express the xml, below

@class Person,Address;

@interface AddressesModel : NSObject

@property(nonatomic,retain) NSString *owner;

@property(nonatomic,retain) Person *person;
@end

@interface Person : NSObject

@property(nonatomic,retain) NSString *lastName;
@property(nonatomic,retain) NSString *firstName;
@property(nonatomic,retain) NSString *phone;
@property(nonatomic,retain) NSString *location;
@property(nonatomic,retain) NSString *email;
@property(nonatomic,retain) Address *address;


@end

@interface Address : NSObject

@property(nonatomic,retain) NSString *street;
@property(nonatomic,retain) NSString *city;
@property(nonatomic,retain) NSString *state;
@property(nonatomic,retain) NSString *zip;

@end

// an example for using  SJXMLParserToModel

  NSString* str =  [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
  NSData *data = [NSData dataWithContentsOfFile:str];
    
  SJXMLParserToModel *SJXMLParser = [[SJXMLParserToModel alloc] init];
  id obj =  [SJXMLParser SJXMLParserWithXMLData:data toCls:@"AddressesModel"];
