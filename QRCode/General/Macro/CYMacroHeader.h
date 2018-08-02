//
//  CYMacroHeader.h
//  QRCode
//
//  Created by dev on 2018/8/2.
//  Copyright © 2018年 chun. All rights reserved.
//

#ifndef CYMacroHeader_h
#define CYMacroHeader_h

// Block
#if DEBUG
#define ext_keywordify autoreleasepool{}
#else
#define ext_keywordify try{} @finally{}
#endif

// weakify
#define weakify(obj) \
ext_keywordify \
__weak __typeof__(obj) weak##obj = obj

// strongify
#define strongify(obj) \
ext_keywordify \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong __typeof__(obj) obj = weak##obj \
_Pragma("clang diagnostic pop")

// blockify
#define blockify(obj) \
ext_keywordify \
__block __typeof__(obj) block##obj = obj

#endif /* CYMacroHeader_h */
