//
//  Debug.h
//  Pods
//
//  Created by Thomas Opiolka on 06.10.15.
//
//
#define DEBUGLOCAL 1

#if defined DEBUG && defined DEBUGLOCAL 
#define DebugLog(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define DebugLog(s, ...)
#endif
