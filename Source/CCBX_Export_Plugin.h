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
#import "CCBX.h"

@interface CCBX_Export_Plugin : CCBX
{
    
}

-(BOOL) ProcessLoader_H_File:(NSDictionary*)paramDic;
-(BOOL) ProcessLayer_H_File:(NSDictionary*)paramDic;
-(BOOL) ProcessLayer_CPP_File:(NSDictionary*)paramDic;
-(NSDictionary*) ParseFromCCBDoc:(NSDictionary*)doc;
-(NSDictionary*) ParseVarFromDic:(NSDictionary*)doc;
-(NSDictionary*) ParsePropertiesFromDic:(NSDictionary*)doc;

@end
