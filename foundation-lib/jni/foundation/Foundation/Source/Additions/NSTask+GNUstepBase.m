/* Implementation of extension methods for base additions

   Copyright (C) 2010 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

 */
#import "common.h"
#import "Foundation/NSFileManager.h"
#import "Foundation/NSPathUtilities.h"
#import "Foundation/NSProcessInfo.h"
#import "GNUstepBase/NSTask+GNUstepBase.h"

@implementation NSTask (GNUstepBase)

static NSString*
executablePath(NSFileManager *mgr, NSString *path)
{
    if ([mgr isExecutableFileAtPath:path])
    {
        return path;
    }
    return nil;
}

+ (NSString*)launchPathForTool:(NSString*)name
{
    NSEnumerator  *enumerator;
    NSDictionary  *env;
    NSString  *pathlist;
    NSString  *path;
    NSFileManager *mgr;

    mgr = [NSFileManager defaultManager];

#if defined(GNUSTEP)
    enumerator = [NSSearchPathForDirectoriesInDomains(
                      GSToolsDirectory, NSAllDomainsMask, YES) objectEnumerator];
    while ((path = [enumerator nextObject]) != nil)
    {
        path = [path stringByAppendingPathComponent:name];
        if ((path = executablePath(mgr, path)) != nil)
        {
            return path;
        }
    }
    enumerator = [NSSearchPathForDirectoriesInDomains(
                      GSAdminToolsDirectory, NSAllDomainsMask, YES) objectEnumerator];
    while ((path = [enumerator nextObject]) != nil)
    {
        path = [path stringByAppendingPathComponent:name];
        if ((path = executablePath(mgr, path)) != nil)
        {
            return path;
        }
    }
#endif

    env = [[NSProcessInfo processInfo] environment];
    pathlist = [env objectForKey:@"PATH"];
    enumerator = [[pathlist componentsSeparatedByString:@":"] objectEnumerator];
    while ((path = [enumerator nextObject]) != nil)
    {
        path = [path stringByAppendingPathComponent:name];
        if ((path = executablePath(mgr, path)) != nil)
        {
            return path;
        }
    }
    return nil;
}
@end
