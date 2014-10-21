//
//  NSXMLParser.m
//  Foundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSXMLParser.h>

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSError.h>
#import <Foundation/NSMapTable.h>
#import <Foundation/NSStream.h>
#import <Foundation/NSURL.h>
#import <Foundation/NSDictionary.h>
#import <CoreFoundation/CFDictionary.h>

#import <libxml/parser.h>
#import <libxml/tree.h>
#import <libxml/xmlerror.h>

#define USE_MAPTABLE 1

NSString *const NSXMLParserErrorDomain = @"NSXMLParserErrorDomain";

typedef NS_OPTIONS(NSUInteger, _NSXMLParserFlags) {
    NSXMLParserShouldProcessNamespaces       = 1 << 0,
    NSXMLParserShouldReportNamespacePrefixes = 1 << 1,
    NSXMLParserShouldResolveExternalEntities = 1 << 2,

    NSXMLParserDelegateDidStartDocument = 1 << 3,
    NSXMLParserDelegateDidEndDocument = 1 << 4,
    NSXMLParserDelegateFoundNotationDeclarationWithNamePublicIDSystemID = 1 << 5,
    NSXMLParserDelegateFoundUnparsedEntityDeclarationWithNamePublicIDSystemIDNotationName = 1 << 6,
    NSXMLParserDelegateFoundAttributeDeclarationWithNameForElementTypeDefaultValue = 1 << 7,
    NSXMLParserDelegateFoundElementDeclarationWithNameModel = 1 << 8,
    NSXMLParserDelegateFoundInternalEntityDeclarationWithNameValue = 1 << 9,
    NSXMLParserDelegateFoundExternalEntityDeclarationWithNamePublicIDSystemID = 1 << 10,
    NSXMLParserDelegateDidStartElementNamespaceURIQualifiedNameAttributes = 1 << 11,
    NSXMLParserDelegateDidEndElementNamespaceURIQualifiedName = 1 << 12,
    NSXMLParserDelegateDidStartMappingPrefixToURI = 1 << 13,
    NSXMLParserDelegateDidEndMappingPrefix = 1 << 14,
    NSXMLParserDelegateFoundCharacters = 1 << 15,
    NSXMLParserDelegateFoundIgnorableWhitespace = 1 << 16,
    NSXMLParserDelegateFoundProcessingInstructionWithTargetData = 1 << 17,
    NSXMLParserDelegateFoundComment = 1 << 18,
    NSXMLParserDelegateFoundCDATA = 1 << 19,
    NSXMLParserDelegateResolveExternalEntityNameSystemID = 1 << 20,
    NSXMLParserDelegateParseErrorOccurred = 1 << 21,
    NSXMLParserDelegateValidationErrorOccurred = 1 << 22,
};

CF_PRIVATE
@interface _NSXMLParserInfo : NSObject {
@public
    xmlSAXHandlerPtr saxHandler;
    xmlParserCtxtPtr parserContext;
    _NSXMLParserFlags parserFlags;
    NSError *error;
    NSMutableArray *namespaces;
    CFMutableDictionaryRef slowStringmap;
    BOOL delegateAborted;
    BOOL haveDetectedEncoding;
    NSData *bomChunk;
    unsigned int nestingLevel;
}
@end


@implementation _NSXMLParserInfo

@end


@implementation NSXMLParser {
    id <NSXMLParserDelegate> _delegate;
    _NSXMLParserInfo *_info;
    NSData *_data;
    NSStream *_stream;
}

static inline Boolean cStringEqual(const void *value1, const void *value2)
{
    xmlChar *str1 = (xmlChar *)value1;
    xmlChar *str2 = (xmlChar *)value2;

    return xmlStrEqual(str1, str2);
}

static inline CFHashCode cStringHash(const void *value)
{
    xmlChar *str = (xmlChar *)value;
    CFHashCode hash = str[0];
    do {
        if (str[0] == '\0')
        {
            break;
        }

        hash |= (str[1] << 8);
        if (str[1] == '\0')
        {
            break;
        }

        hash |= (str[2] << 16);
        if (str[2] == '\0')
        {
            break;
        }

        hash |= (str[3] << 24);
    } while (0);

    return hash;
}

static inline NSString *NSStringFromXML(_NSXMLParserInfo *parserInfo, const xmlChar *str)
{
    if (str == NULL)
    {
        return nil;
    }
#if USE_MAPTABLE
    if (parserInfo->slowStringmap == NULL)
    {
        static const CFDictionaryKeyCallBacks keyCallbacks = {
            .version = 0,
            .hash = cStringHash,
            .equal = cStringEqual,
        };
        parserInfo->slowStringmap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallbacks, &kCFTypeDictionaryValueCallBacks);
    }
    
    NSString *string = CFDictionaryGetValue(parserInfo->slowStringmap, str);
    
    if (string == nil)
    {
        string = [[NSString alloc] initWithCString:(const char *)str encoding:NSUTF8StringEncoding];
        CFDictionarySetValue(parserInfo->slowStringmap, str, string);
        [string release];
    }

    return string;
#else
    return [[[NSString alloc] initWithCString:(const char *)str encoding:NSUTF8StringEncoding] autorelease];
#endif
}

static xmlParserInputPtr NSXMLParserResolveEntity(void *ctx, const xmlChar *publicId, const xmlChar *systemId)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    return xmlSAX2ResolveEntity(parser->_info->parserContext, publicId, systemId);
}

static void NSXMLParserEntityDecl(void *ctx, const xmlChar *name, int type, const xmlChar *publicId, const xmlChar *systemId, xmlChar *content)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;

    xmlSAX2EntityDecl(parser->_info->parserContext, name, type, publicId, systemId, content);
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundExternalEntityDeclarationWithNamePublicIDSystemID) != 0 ||
        (parser->_info->parserFlags & NSXMLParserDelegateFoundInternalEntityDeclarationWithNameValue) != 0)
    {
        NSString *contentStr = NSStringFromXML(parser->_info, content);
        NSString *nameStr = NSStringFromXML(parser->_info, name);

        if ([contentStr length] != 0)
        {
            if ((parser->_info->parserFlags & NSXMLParserDelegateFoundInternalEntityDeclarationWithNameValue) != 0)
            {
                [parser->_delegate parser:parser foundInternalEntityDeclarationWithName:nameStr value:contentStr];
            }
        }
        else if ([parser shouldResolveExternalEntities] && 
                 (parser->_info->parserFlags & NSXMLParserDelegateFoundExternalEntityDeclarationWithNamePublicIDSystemID) != 0)
        {
                NSString *publicIDStr = NSStringFromXML(parser->_info, publicId);
                NSString *systemIDStr = NSStringFromXML(parser->_info, systemId);

                [parser->_delegate parser:parser foundExternalEntityDeclarationWithName:nameStr publicID:publicIDStr systemID:systemIDStr];
        }
    }
}

static void NSXMLParserNotationDecl(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundNotationDeclarationWithNamePublicIDSystemID) != 0)
    {
        [parser->_delegate                           parser:parser
                           foundNotationDeclarationWithName:NSStringFromXML(parser->_info, name) 
                                                   publicID:NSStringFromXML(parser->_info, publicId)
                                                   systemID:NSStringFromXML(parser->_info, systemId)];
    }
}

static void NSXMLParserAttributeDecl(void *ctx, const xmlChar *elem, const xmlChar *fullname, int type, int def, const xmlChar *defaultValue, xmlEnumerationPtr tree)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundAttributeDeclarationWithNameForElementTypeDefaultValue) != 0)
    {
        NSString *typeName = nil;
        switch (type)
        {
            case XML_ATTRIBUTE_ENTITY:
                typeName = @"ENTITY";
                break;
            case XML_ATTRIBUTE_NOTATION:
                typeName = @"NOTATION";
                break;
            case XML_ATTRIBUTE_ID:
                typeName = @"ID";
                break;
            default:
                typeName = @""; // valid? or should this be nil
        }
        [parser->_delegate parser:parser foundAttributeDeclarationWithName:NSStringFromXML(parser->_info, fullname)
                                                                forElement:NSStringFromXML(parser->_info, elem) 
                                                                      type:typeName 
                                                              defaultValue:NSStringFromXML(parser->_info, defaultValue)];
    }
}

static void NSXMLParserElementDecl(void *ctx, const xmlChar *name, int type, xmlElementContentPtr content)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundElementDeclarationWithNameModel) != 0)
    {
        // TODO: Fix the model reference?
        [parser->_delegate parser:parser foundElementDeclarationWithName:NSStringFromXML(parser->_info, name) model:@""];
    }
}

static void NSXMLParserUnparsedEntityDecl(void *ctx, const xmlChar *name, const xmlChar *publicId, const xmlChar *systemId, const xmlChar *notationName)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundUnparsedEntityDeclarationWithNamePublicIDSystemIDNotationName) != 0)
    {
        [parser->_delegate parser:parser foundUnparsedEntityDeclarationWithName:NSStringFromXML(parser->_info, name) 
                         publicID:NSStringFromXML(parser->_info, publicId) 
                         systemID:NSStringFromXML(parser->_info, systemId) 
                     notationName:NSStringFromXML(parser->_info, notationName)];
    }
}

static void NSXMLParserStartDocument(void *ctx)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateDidStartDocument) != 0)
    {
        [parser->_delegate parserDidStartDocument:parser];
    }
}

static void NSXMLParserEndDocument(void *ctx)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateDidEndDocument) != 0)
    {
        [parser->_delegate parserDidEndDocument:parser];
    }
}

static void NSXMLParserCharacters(void *ctx, const xmlChar *ch, int len)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundCharacters) != 0)
    {
        NSString *str = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
        [parser->_delegate parser:parser foundCharacters:str];
        [str release];
    }

}

static void NSXMLParserIgnorableWhitespace(void *ctx, const xmlChar *ch, int len)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundIgnorableWhitespace) != 0)
    {
        NSString *str = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
        [parser->_delegate parser:parser foundIgnorableWhitespace:str];
        [str release];
    }
}

static void NSXMLParserProcessingInstruction(void *ctx, const xmlChar *target, const xmlChar *data)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundProcessingInstructionWithTargetData) != 0)
    {
        [parser->_delegate parser:parser foundProcessingInstructionWithTarget:NSStringFromXML(parser->_info, target) data:NSStringFromXML(parser->_info, data)];
    }
}

static void NSXMLParserComment(void *ctx, const xmlChar *value)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundComment) != 0)
    {
        [parser->_delegate parser:parser foundComment:NSStringFromXML(parser->_info, value)];
    }
}

static void NSXMLParserCdataBlock(void *ctx, const xmlChar *value, int len)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateFoundCDATA) != 0)
    {
        NSData *data = [[NSData alloc] initWithBytesNoCopy:(void *)value length:len freeWhenDone:NO];
        [parser->_delegate parser:parser foundCDATA:data];
        [data release];
    }
}

static void NSXMLParserStartElementNs(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateDidStartElementNamespaceURIQualifiedNameAttributes) != 0)
    {
        BOOL shouldProcessNamespaces = [parser shouldProcessNamespaces];
        BOOL shouldReportNamespacePrefixes = [parser shouldReportNamespacePrefixes];

        NSString *prefixStr = NSStringFromXML(parser->_info, prefix);
        NSString *qualName = NSStringFromXML(parser->_info, localname);
        NSString *uriStr = nil;
        NSMutableDictionary *attributesDict = [[NSMutableDictionary alloc] initWithCapacity:nb_attributes + nb_namespaces];
        NSMutableDictionary *nsDict = [[NSMutableDictionary alloc] initWithCapacity:nb_namespaces];;

        NSString *fullName = nil;
        if ([prefixStr length] != 0)
        {
            fullName = [[NSString alloc] initWithFormat: @"%@:%@", prefixStr, qualName];
        }
        else
        {
            fullName = [qualName retain];
        }

        if (shouldProcessNamespaces)
        {
            uriStr = NSStringFromXML(parser->_info, URI);
        }

        for (NSUInteger idx = 0; idx < (nb_namespaces * 2); idx += 2)
        {
            NSString *namespaceStr = nil;
            NSString *qualifiedStr = nil;
            NSString *value = nil;

            if (namespaces[idx] == NULL)
            {
                qualifiedStr = [@"xmlns" retain]; // for visual balance
            }
            else
            {
                namespaceStr = NSStringFromXML(parser->_info, namespaces[idx]);
                qualifiedStr = [[NSString alloc] initWithFormat: @"xmlns:%@", namespaceStr];
            }

            if (namespaces[idx + 1] != NULL)
            {
                value = NSStringFromXML(parser->_info, namespaces[idx + 1]);
            }
            else
            {
                value = @"";
            }

            if (value != nil && fullName != nil && qualifiedStr != nil)
            {
                nsDict[fullName] = value;
                attributesDict[qualifiedStr] = value;
            }

            [qualifiedStr release];
        }

        if (shouldReportNamespacePrefixes)
        {
            [parser->_info->namespaces addObject:nsDict];
        }
        [nsDict release];

        for (NSUInteger idx = 0; idx < (nb_attributes * 5); idx += 5 )
        {
            if (attributes[idx] == NULL)
            {
                continue;
            }

            NSString *attrLocalName = NSStringFromXML(parser->_info, attributes[idx]);
            NSString *attrPrefix = nil;

            if (attributes[idx + 1] != NULL)
            {
                attrPrefix = NSStringFromXML(parser->_info, attributes[idx + 1]);
            }

            NSString *attrQualified = nil;
            if ([attrPrefix length] != 0)
            {
                attrQualified = [[NSString alloc] initWithFormat: @"%@:%@", attrPrefix, attrLocalName];
            }
            else
            {
                attrQualified = [attrLocalName retain];
            }

            NSString *attrValue = nil;
            if ((attributes[idx + 3] != NULL) && (attributes[idx + 4] != NULL))
            {
                NSUInteger length = attributes[idx + 4] - attributes[idx + 3];
                attrValue = [[NSString alloc] initWithBytes:attributes[idx + 3]
                                                     length:length
                                                   encoding:NSUTF8StringEncoding];
            }
            else
            {
                attrValue = [@"" retain]; // for visual balance
            }

            if (attrQualified != nil && attrValue != nil)
            {
                attributesDict[attrQualified] = attrValue;
            }

            [attrQualified release];
            [attrValue release];
        }

        [parser->_delegate parser:parser
                  didStartElement:fullName
                     namespaceURI:uriStr
                    qualifiedName:qualName
                       attributes:attributesDict];

        [fullName release];
        [attributesDict release];
    }
}

static void NSXMLParserEndElementNs(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;
    if ((parser->_info->parserFlags & NSXMLParserDelegateDidEndElementNamespaceURIQualifiedName) != 0)
    {
        NSString *prefixStr = nil;
        NSString *fullName = nil;
        NSString *qualName = NSStringFromXML(parser->_info, localname);
        NSString *uriStr = NSStringFromXML(parser->_info, URI);

        prefixStr = NSStringFromXML(parser->_info, prefix);

        if ([prefixStr length] != 0)
        {
            fullName = [[NSString alloc] initWithFormat: @"%@:%@", prefixStr, qualName];
        }
        else
        {
            fullName = [qualName retain];
        }
        
        if ([parser shouldProcessNamespaces])
        {
            if (uriStr == nil)
            {
                uriStr = @"";
            }

            [parser->_delegate parser:parser 
                        didEndElement:fullName
                         namespaceURI:uriStr
                        qualifiedName:qualName];
        }
        else
        {
            [parser->_delegate parser:parser 
                        didEndElement:fullName
                         namespaceURI:nil
                        qualifiedName:nil];
        }
        [fullName release];
    }
}

static void NSXMLParserXmlStructuredError(void *ctx, xmlErrorPtr error)
{
    NSXMLParser *parser = (NSXMLParser *)ctx;

    if ((parser->_info->parserFlags & NSXMLParserDelegateParseErrorOccurred) != 0)
    {
        int errorCode = parser->_info->delegateAborted ? 0x200 : error->code;
        NSError *err = [NSError errorWithDomain:NSXMLParserErrorDomain code:errorCode userInfo:@{
            NSLocalizedDescriptionKey:[NSString stringWithUTF8String:error->message],
            @"line":@(error->line)
        }];
        [parser->_delegate parser:parser parseErrorOccurred:err];
    }
}

- (_NSXMLParserInfo *)_info
{
    return _info;
}

- (xmlParserCtxtPtr)_parserContext
{
    return _info->parserContext;
}

- (id <NSXMLParserDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id <NSXMLParserDelegate>)delegate
{
    if (_delegate != delegate)
    {
        if ([delegate respondsToSelector:@selector(parserDidStartDocument:)])
        {
            _info->parserFlags |= NSXMLParserDelegateDidStartDocument; 
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateDidStartDocument);
        }

        if ([delegate respondsToSelector:@selector(parserDidEndDocument:)])
        {
            _info->parserFlags |= NSXMLParserDelegateDidEndDocument;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateDidEndDocument);
        }

        if ([delegate respondsToSelector:@selector(parser:foundNotationDeclarationWithName:publicID:systemID:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundNotationDeclarationWithNamePublicIDSystemID; 
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundNotationDeclarationWithNamePublicIDSystemID);
        }

        if ([delegate respondsToSelector:@selector(parser:foundUnparsedEntityDeclarationWithName:publicID:systemID:notationName:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundUnparsedEntityDeclarationWithNamePublicIDSystemIDNotationName;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundUnparsedEntityDeclarationWithNamePublicIDSystemIDNotationName);
        }

        if ([delegate respondsToSelector:@selector(parser:foundAttributeDeclarationWithName:forElement:type:defaultValue:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundAttributeDeclarationWithNameForElementTypeDefaultValue;  
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundAttributeDeclarationWithNameForElementTypeDefaultValue);
        }

        if ([delegate respondsToSelector:@selector(parser:foundElementDeclarationWithName:model:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundElementDeclarationWithNameModel; 
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundElementDeclarationWithNameModel);
        }

        if ([delegate respondsToSelector:@selector(parser:foundInternalEntityDeclarationWithName:value:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundInternalEntityDeclarationWithNameValue;  
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundInternalEntityDeclarationWithNameValue);
        }

        if ([delegate respondsToSelector:@selector(parser:foundExternalEntityDeclarationWithName:publicID:systemID:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundExternalEntityDeclarationWithNamePublicIDSystemID;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundExternalEntityDeclarationWithNamePublicIDSystemID);
        }

        if ([delegate respondsToSelector:@selector(parser:didStartElement:namespaceURI:qualifiedName:attributes:)])
        {
            _info->parserFlags |= NSXMLParserDelegateDidStartElementNamespaceURIQualifiedNameAttributes;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateDidStartElementNamespaceURIQualifiedNameAttributes);
        }

        if ([delegate respondsToSelector:@selector(parser:didEndElement:namespaceURI:qualifiedName:)])
        {
            _info->parserFlags |= NSXMLParserDelegateDidEndElementNamespaceURIQualifiedName;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateDidEndElementNamespaceURIQualifiedName);
        }

        if ([delegate respondsToSelector:@selector(parser:didStartMappingPrefix:toURI:)])
        {
            _info->parserFlags |= NSXMLParserDelegateDidStartMappingPrefixToURI;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateDidStartMappingPrefixToURI);
        }

        if ([delegate respondsToSelector:@selector(parser:didEndMappingPrefix:)])
        {
            _info->parserFlags |= NSXMLParserDelegateDidEndMappingPrefix;  
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateDidEndMappingPrefix);
        }

        if ([delegate respondsToSelector:@selector(parser:foundCharacters:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundCharacters;  
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundCharacters);
        }

        if ([delegate respondsToSelector:@selector(parser:foundIgnorableWhitespace:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundIgnorableWhitespace; 
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundIgnorableWhitespace);
        }

        if ([delegate respondsToSelector:@selector(parser:foundProcessingInstructionWithTarget:data:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundProcessingInstructionWithTargetData; 
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundProcessingInstructionWithTargetData);
        }

        if ([delegate respondsToSelector:@selector(parser:foundComment:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundComment; 
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundComment);
        }

        if ([delegate respondsToSelector:@selector(parser:foundCDATA:)])
        {
            _info->parserFlags |= NSXMLParserDelegateFoundCDATA;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateFoundCDATA);
        }

        if ([delegate respondsToSelector:@selector(parser:resolveExternalEntityName:systemID:)])
        {
            _info->parserFlags |= NSXMLParserDelegateResolveExternalEntityNameSystemID;    
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateResolveExternalEntityNameSystemID);
        }

        if ([delegate respondsToSelector:@selector(parser:parseErrorOccurred:)])
        {
            _info->parserFlags |= NSXMLParserDelegateParseErrorOccurred;   
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateParseErrorOccurred);
        }

        if ([delegate respondsToSelector:@selector(parser:validationErrorOccurred:)])
        {
            _info->parserFlags |= NSXMLParserDelegateValidationErrorOccurred;  
        }
        else
        {
            _info->parserFlags &= ~(NSXMLParserDelegateValidationErrorOccurred);
        }
        _delegate = delegate;
    }
}

- (void)setShouldProcessNamespaces:(BOOL)shouldProcessNamespaces
{
    if ([self _parserContext] == nil && shouldProcessNamespaces)
    {
        _info->parserFlags |= NSXMLParserShouldProcessNamespaces;
    }
}

- (void)setShouldReportNamespacePrefixes:(BOOL)shouldReportNamespacePrefixes
{
    if ([self _parserContext] == nil && shouldReportNamespacePrefixes)
    {
        _info->parserFlags |= NSXMLParserShouldReportNamespacePrefixes;
    }
}

- (void)setShouldResolveExternalEntities:(BOOL)shouldResolveExternalEntities
{
    if ([self _parserContext] == nil && shouldResolveExternalEntities)
    {
        _info->parserFlags |= NSXMLParserShouldResolveExternalEntities;
    }
}

- (BOOL)shouldProcessNamespaces
{
    return _info->parserFlags & NSXMLParserShouldProcessNamespaces;
}

- (BOOL)shouldReportNamespacePrefixes
{
    return _info->parserFlags & NSXMLParserShouldReportNamespacePrefixes;
}

- (BOOL)shouldResolveExternalEntities
{
    return _info->parserFlags & NSXMLParserShouldResolveExternalEntities;
}

- (NSError *)parserError
{
    return [[_info->error retain] autorelease];
}

- (void)_setParserError:(int)errorCode
{
    if (_info->error == nil)
    {
        [_info->error autorelease];
    }

    _info->error = [[NSError alloc] initWithDomain:NSXMLParserErrorDomain code:errorCode userInfo:nil];
}

- (void)dealloc
{
    if (_info->parserContext->myDoc != NULL)
    {
        xmlFreeDoc(_info->parserContext->myDoc);
    }
    xmlFreeParserCtxt(_info->parserContext);
    free(_info->saxHandler);

    [_info->error release];
    [_info->bomChunk release];
    [_info->namespaces release];
    [_data release];
    [_stream release];

    if (_info->slowStringmap != NULL)
    {
        CFRelease(_info->slowStringmap);
    }

    [super dealloc];
}

- (id)initWithContentsOfURL:(NSURL *)url
{
    if ([self isMemberOfClass:[NSXMLParser class]] && [url isFileURL])
    {
        self = [self initWithData:[NSData dataWithContentsOfURL:url]];
    }
    else
    {
        self = [self initWithStream:[NSInputStream inputStreamWithURL:url]];
    }

    return self;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];

    if (self != nil)
    {
        _data = [data retain];
        _info = [[_NSXMLParserInfo alloc] init];
        _info->saxHandler = calloc(sizeof(xmlSAXHandler), 1);
        _info->saxHandler->startDocument = &NSXMLParserStartDocument;
        _info->saxHandler->endDocument = &NSXMLParserEndDocument;
        _info->saxHandler->notationDecl = &NSXMLParserNotationDecl;
        _info->saxHandler->unparsedEntityDecl = &NSXMLParserUnparsedEntityDecl;
        _info->saxHandler->attributeDecl = &NSXMLParserAttributeDecl;
        _info->saxHandler->elementDecl = &NSXMLParserElementDecl;
        _info->saxHandler->entityDecl = &NSXMLParserEntityDecl;
        _info->saxHandler->startElementNs = &NSXMLParserStartElementNs;
        _info->saxHandler->endElementNs = &NSXMLParserEndElementNs;
        _info->saxHandler->characters = &NSXMLParserCharacters;
        _info->saxHandler->ignorableWhitespace = &NSXMLParserIgnorableWhitespace;
        _info->saxHandler->processingInstruction = &NSXMLParserProcessingInstruction;
        _info->saxHandler->comment = &NSXMLParserComment;
        _info->saxHandler->cdataBlock = &NSXMLParserCdataBlock;
        _info->saxHandler->resolveEntity = &NSXMLParserResolveEntity;
        _info->saxHandler->serror = &NSXMLParserXmlStructuredError;
        _info->saxHandler->_private = self;
        _info->saxHandler->initialized = XML_SAX2_MAGIC;
    }

    return self;
}

- (id)initWithStream:(NSInputStream *)stream
{
    NSMutableData *data = [[NSMutableData alloc] init];
        
    while ([stream hasBytesAvailable])
    {
        uint8_t *buffer = NULL;
        NSUInteger len = 0;
        BOOL needsFree = NO;
        if (![stream getBuffer:&buffer length:&len])
        {
            len = 1024;
            buffer = malloc(len);
            needsFree = YES;
            len = [stream read:buffer maxLength:len];
        }

        [data appendBytes:buffer length:len];

        if (needsFree)
        {
            free(buffer);
        }
    }

    NSStreamStatus status = [stream streamStatus];
    if (status == NSStreamStatusError)
    {
        [self release];
        [data release];
        return nil;
    }

    self = [self initWithData:data];
    [data release];
    
    if (self != nil)
    {
        _stream = stream;
    }

    return self;
}

- (BOOL)parse
{
    int ret = -1;

    xmlSetStructuredErrorFunc(self, &NSXMLParserXmlStructuredError);
    const void *bytes = [_data bytes];

    _info->parserContext = xmlCreatePushParserCtxt(_info->saxHandler, self, bytes, [_data length], NULL);
        
    int options = XML_PARSE_RECOVER | XML_PARSE_NOENT | XML_PARSE_DTDLOAD;

    xmlCtxtUseOptions(_info->parserContext, options);
    ret = xmlParseChunk(_info->parserContext, bytes, 0, 1);
    return ret == 0;
}

- (void)abortParsing
{
    if (_info->parserContext != nil)
    {
        xmlStopParser(_info->parserContext);
    }
}

@end


@implementation NSXMLParser (NSXMLParserLocatorAdditions)

- (NSString *)publicID
{
    return nil;
}

- (NSString *)systemID
{
    return nil;
}

- (NSInteger)lineNumber
{
    if (_info->parserContext != nil)
    {
        return xmlSAX2GetLineNumber(_info->parserContext);
    }
    else
    {
        return 0;
    }
}

- (NSInteger)columnNumber
{
    if (_info->parserContext != nil)
    {
        return xmlSAX2GetColumnNumber(_info->parserContext);
    }
    else
    {
        return 0;
    }
}

@end
