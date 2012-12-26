/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/*
 This plugin is created accroding CocosBuilder export example.
 The ccbx file (which is exactly the same with ccbi format) and other 3 source code will be generated for cocos2d-x c++ code
 
 Author: Bowie Xu
 */

#import "CCBX_Export_Plugin.h"

@implementation CCBX_Export_Plugin

- (NSString*) extension
{
    return @"ccbx";
}

- (NSData*) exportDocument:(NSDictionary*)doc flattenPaths:(BOOL)flattenPaths
{
    //1. check if CCBExport exist
    NSFileManager* filemanager = [NSFileManager defaultManager];
    NSString* exportpath = [NSString stringWithFormat:@"%@/CCBXExport/", NSHomeDirectory()];
    
    //create CCBExport folder if it is not exist.
    
    NSError* error;
    if(![filemanager fileExistsAtPath:exportpath])
        [filemanager createDirectoryAtPath:exportpath withIntermediateDirectories:NO attributes:nil error:&error];
    
    //2.parse ccb dictionary
    NSDictionary* parsedDic = [self ParseFromCCBDoc:doc];
    NSString* filename = [[parsedDic objectForKey:@"File"] objectForKey:@"customClass"];
    NSString* exportplist = [NSString stringWithFormat:@"%@%@.plist", exportpath, filename];
    [parsedDic writeToFile:exportplist atomically:YES];
    
    //3.deal with xxxxxLoader.h file
    [self ProcessLoader_H_File:parsedDic];
    
    //4.deal with xxxxxLayer.h file
    [self ProcessLayer_H_File:parsedDic];
    
    return [NSPropertyListSerialization dataFromPropertyList:doc format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
}

-(NSDictionary*) ParseFromCCBDoc:(NSDictionary*)doc
{
    NSMutableDictionary* infodic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSDictionary* nodeDic = [doc objectForKey:@"nodeGraph"];
    if(nodeDic != nil)
    {
        NSString* customClassString = [nodeDic objectForKey:@"customClass"];
        if(customClassString != nil && ![customClassString isEqualToString:@""])
        {
            NSMutableDictionary* filedic = [NSMutableDictionary dictionaryWithCapacity:0];
            [filedic setObject:customClassString forKey:@"customClass"];
            [filedic setObject:[nodeDic objectForKey:@"baseClass"] forKey:@"baseClass"];
            [infodic setObject:filedic forKey:@"File"];
            NSMutableArray* vararray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray* funcarray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray* ccbarray = [NSMutableArray arrayWithCapacity:0];
            
            [self ParseChildernFromDic:nodeDic Vars:vararray Funcs:funcarray Ccbs:ccbarray];
            
            [infodic setObject:vararray forKey:@"Var"];
            [infodic setObject:funcarray forKey:@"Func"];
            [infodic setObject:ccbarray forKey:@"Ccb"];
            
            return infodic;
            
        }
    }
    
    return nil;
}

-(void) ParseChildernFromDic:(NSDictionary*)doc Vars:(NSMutableArray*)vararray Funcs:(NSMutableArray*)funcarray Ccbs:(NSMutableArray*)ccbarray
{
    NSArray* array = [doc objectForKey:@"children"];
    if(array != nil)
    {
        for (int i=0; i<[array count]; i++)
        {
            NSDictionary* childdic = [array objectAtIndex:i];
            NSDictionary* vardic = [self ParseVarFromDic:childdic];
            NSDictionary* funcdic = [self ParsePropertiesFromDic:childdic];
            if(vardic != nil)
                [vararray addObject:vardic];
            if(funcdic != nil)
            {
                if([[funcdic objectForKey:@"type"] isEqualToString:@"CCBFile"])
                    [ccbarray addObject:funcdic];
                else
                    [funcarray addObject:funcdic];
            }
            
            //check children recursively
            [self ParseChildernFromDic:childdic Vars:vararray Funcs:funcarray Ccbs:ccbarray];
        }
    }
}

-(NSDictionary*) ParseVarFromDic:(NSDictionary*)doc
{
    NSString* varname = [doc objectForKey:@"memberVarAssignmentName"];
    NSString* baseclass = [doc objectForKey:@"baseClass"];
    int typenumber = [[doc objectForKey:@"memberVarAssignmentType"] intValue];
    
    if(varname != nil && baseclass != nil && typenumber == 1)
    {
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:varname forKey:@"varName"];
        [dic setObject:baseclass forKey:@"baseClass"];
        NSString* customclass = [doc objectForKey:@"customClass"];
        if(customclass != nil)
            [dic setObject:customclass forKey:@"customClass"];
        
        return dic;
    }
    
    return nil;
}


-(NSDictionary*) ParsePropertiesFromDic:(NSDictionary*)doc
{
    NSArray* propertiesarray = [doc objectForKey:@"properties"];
    
    for(int i=0; i<[propertiesarray count]; i++)
    {
        NSDictionary* dic = [propertiesarray objectAtIndex:i];
        NSMutableDictionary* funcdic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString* name = [dic objectForKey:@"name"];
        NSString* type = [dic objectForKey:@"type"];
        NSArray* array = [dic objectForKey:@"value"];
        if(name!= nil && [name isEqualToString:@"ccControl"] &&
           type != nil && [type isEqualToString:@"BlockCCControl"] && [[array objectAtIndex:1] intValue] == 1)
        {
            [funcdic setObject:[array objectAtIndex:0] forKey:@"funcName"];
            [funcdic setObject:type forKey:@"type"];
            return funcdic;
        }
        
        if(name!=nil && [name isEqualToString:@"block"] &&
           type != nil && [type isEqualToString:@"Block"] && [[array objectAtIndex:1] intValue] == 1)
        {
            [funcdic setObject:[array objectAtIndex:0] forKey:@"funcName"];
            [funcdic setObject:type forKey:@"type"];
            return funcdic;
        }
        
        if(name!=nil && [name isEqualToString:@"ccbFile"] &&
           type != nil && [type isEqualToString:@"CCBFile"])
        {
            NSString* valuestring = [dic objectForKey:@"value"];
            NSArray* stringarray = [valuestring componentsSeparatedByString:@"/"];
            valuestring = [stringarray objectAtIndex:[stringarray count]-1];
            NSRange range;
            range.location = 0;
            range.length = [valuestring length];
            valuestring = [valuestring stringByReplacingOccurrencesOfString:@".ccb" withString:@"" options: NSCaseInsensitiveSearch range:range];
            [funcdic setObject:valuestring forKey:@"ccbName"];
            [funcdic setObject:type forKey:@"type"];
            return funcdic;
        }
    }
    return nil;
}

-(NSString*) GenerateNewLoader_H_File:(NSDictionary*)paramDic
{
    NSString* returnstring = @"";
    NSString* classname = [[paramDic objectForKey:@"File"] objectForKey:@"customClass"];
    NSString* classloadername = [NSString stringWithFormat:@"%@Loader", classname];
    returnstring = [returnstring stringByAppendingString:[self CommonComment]];
    returnstring = [returnstring stringByAppendingString:[self HeaderFileDefineStart:classloadername]];
    
    returnstring = [returnstring stringByAppendingFormat:@"\n\n#include \"%@.h\"\n\n", classname];
    
    returnstring = [returnstring stringByAppendingFormat:@"\
/*Forward declaration.*/\n\
class CCBReader;\n\n\
class %@ : public cocos2d::extension::CCLayerLoader {\n\
public:\n\
\tCCB_STATIC_NEW_AUTORELEASE_OBJECT_METHOD(%@, loader);\n\
\n\
protected:\n\
\tCCB_VIRTUAL_NEW_AUTORELEASE_CREATECCNODE_METHOD(%@);\n\
};\n", classloadername, classloadername, classname];
    
    returnstring = [returnstring stringByAppendingString:[self HeaderFileDefineEnd]];
    
    return returnstring;
    
}

-(NSString*) GenerateNewLayer_H_FunctionsVars:(NSDictionary*)paramDic
{
    NSString* returnstring = @"";
    
    BOOL has_output = NO;
    NSString* commentstringstart = [NSString stringWithFormat:@"//<<<<<<......!Please do NOT change codes below![functions, vars declare start]......>>>>>>\n"];
    NSString* commentstringend = [NSString stringWithFormat:@"//<<<<<<......!Please do NOT change codes above![functions, vars declare end]......>>>>>>\n"];
    
    NSArray* array = [paramDic objectForKey:@"Func"];
    if(array != nil && [array count]>0)
    {
        has_output = YES;
        returnstring = [returnstring stringByAppendingString:commentstringstart];
        
        
        returnstring = [returnstring stringByAppendingFormat:@"\
public:\n"];
        for(int i=0; i<[array count]; i++)
        {
            NSString* functionname = [[array objectAtIndex:i] objectForKey:@"funcName"];
            returnstring = [returnstring stringByAppendingFormat:@"\tvoid %@(cocos2d::CCObject * pSender, cocos2d::extension::CCControlEvent pCCControlEvent);\n", functionname];
        }
    }
    
    array = [paramDic objectForKey:@"Var"];
    if(array != nil && [array count]>0)
    {
        if(has_output == NO)
        {
            returnstring = [returnstring stringByAppendingString:commentstringstart];
            has_output = YES;
        }
        returnstring = [returnstring stringByAppendingFormat:@"\
private:\n"];
        for(int i=0; i<[array count]; i++)
        {
            NSString* varname = [[array objectAtIndex:i] objectForKey:@"varName"];
            NSString* customclassname = [[array objectAtIndex:i] objectForKey:@"customClass"];
            NSString* baseclassname = [[array objectAtIndex:i] objectForKey:@"baseClass"];
            
            NSString* classname = @"";
            if(customclassname != nil && ![customclassname isEqualToString:@""])
                classname = customclassname;
            else
                classname = baseclassname;
            
            returnstring = [returnstring stringByAppendingFormat:@"\tcocos2d::%@ * %@;\n", classname, varname];
        }

    }
    
    if(has_output == YES)
    {
        returnstring = [returnstring stringByAppendingString:commentstringend];
    }
    
    return returnstring;
}

-(NSString*) GenerateNewLayer_H_File:(NSDictionary*)paramDic
{
    NSString* returnstring = @"";
    NSString* classname = [[paramDic objectForKey:@"File"] objectForKey:@"customClass"];
    returnstring = [returnstring stringByAppendingString:[self CommonComment]];
    returnstring = [returnstring stringByAppendingString:[self HeaderFileDefineStart:classname]];
    
    returnstring = [returnstring stringByAppendingString:@"\n\n#include \"cocos2d.h\"\n"];
    returnstring = [returnstring stringByAppendingString:@"#include \"cocos-ext.h\"\n\n"];
    
    returnstring = [returnstring stringByAppendingFormat:@"\
/*\n\
* Note: for some pretty hard fucked up reason, the order of inheritance is important!\n\
* When CCLayer is the 'first' inherited object:\n\
* During runtime the method call to the (pure virtual) 'interfaces' fails jumping into a bogus method or just doing nothing:\n\
*  #0    0x000cf840 in non-virtual thunk to HelloCocos....\n\
*  #1    ....\n\
*\n\
* This thread describes the problem:\n\
* http://www.cocoabuilder.com/archive/xcode/265549-crash-in-virtual-method-call.html\n\
*/\n\
class %@\n\
: public cocos2d::CCLayer\n\
, public cocos2d::extension::CCBSelectorResolver\n\
, public cocos2d::extension::CCBMemberVariableAssigner\n\
, public cocos2d::extension::CCNodeLoaderListener\n\
{\n\
public:\n\
\tCCB_STATIC_NEW_AUTORELEASE_OBJECT_WITH_INIT_METHOD(%@, create);\n\
\n\
\t%@();\n\
\tvirtual ~%@();\n\
\n\
\tstatic cocos2d::CCNode LoadCCNode(const char * pCCBFileName, const char * pCCNodeName = NULL, cocos2d::extension::CCNodeLoader * pCCNodeLoader = NULL);\n\
\n\
\tvirtual cocos2d::SEL_MenuHandler onResolveCCBCCMenuItemSelector(cocos2d::CCObject * pTarget, cocos2d::CCString * pSelectorName);\n\
\tvirtual cocos2d::extension::SEL_CCControlHandler onResolveCCBCCControlSelector(cocos2d::CCObject * pTarget, cocos2d::CCString * pSelectorName);\n\
\tvirtual bool onAssignCCBMemberVariable(cocos2d::CCObject * pTarget, cocos2d::CCString * pMemberVariableName, cocos2d::CCNode * pNode);\n\
\tvirtual void onNodeLoaded(cocos2d::CCNode * pNode, cocos2d::extension::CCNodeLoader * pNodeLoader);\n\n",classname,classname,classname,classname];
        
    returnstring = [returnstring stringByAppendingString:[self GenerateNewLayer_H_FunctionsVars:paramDic]];
    returnstring = [returnstring stringByAppendingString:@"};\n"];
    
    returnstring = [returnstring stringByAppendingString:[self HeaderFileDefineEnd]];
    
    return returnstring;
}

-(NSString*) GenerateNewLayer_CPP_File:(NSDictionary*)paramDic
{
    return nil;
}

-(NSString*) CommonComment
{
    return @"\
/////////////////////////////////////////////////////\n\
//This file was created by CCBX export plugins\n\
//You can find more infomation at:............\n\
//Bowie Xu\n\
/////////////////////////////////////////////////////\n";
    
}

-(NSString*) HeaderFileDefineStart:(NSString*)filename
{
    NSString* definestring = [NSString stringWithFormat:@"__%@_H__", [filename uppercaseString]];
    
    NSString* returnstring = [NSString stringWithFormat:@"\
#ifndef %@\n\
#define %@\n", definestring, definestring];
    
    return returnstring;
}

-(NSString*) HeaderFileDefineEnd
{
    return @"#endif\n";
}


-(BOOL) ProcessLoader_H_File:(NSDictionary*)paramDic
{
    NSFileManager* filemanager = [NSFileManager defaultManager];
    NSString* exportfile = [NSString stringWithFormat:@"%@/CCBXExport/%@Loader.h", NSHomeDirectory(), [[paramDic objectForKey:@"File"] objectForKey:@"customClass"]];
    
    //create CCBExport folder if it is not exist.
    
    NSError* error;
    if(![filemanager fileExistsAtPath:exportfile])
    {
        NSString* filecontent = [self GenerateNewLoader_H_File:paramDic];
        [filecontent writeToFile:exportfile atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }
    
    
    return YES;
}

-(BOOL) ProcessLayer_H_File:(NSDictionary*)paramDic
{
    NSFileManager* filemanager = [NSFileManager defaultManager];
    NSString* exportfile = [NSString stringWithFormat:@"%@/CCBXExport/%@.h", NSHomeDirectory(), [[paramDic objectForKey:@"File"] objectForKey:@"customClass"]];
    
    //create CCBExport folder if it is not exist.
    
    NSError* error;
    if(![filemanager fileExistsAtPath:exportfile])
    {
        NSString* filecontent = [self GenerateNewLayer_H_File:paramDic];
        [filecontent writeToFile:exportfile atomically:NO encoding:NSUTF8StringEncoding error:&error];
    }
    
    return YES;
}

-(BOOL) ProcessLayer_CPP_File:(NSDictionary*)paramDic
{
    return YES;
}


@end
