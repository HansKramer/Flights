/*
Copyright 2013 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "include/dart_api.h"


Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool *auto_setup_scope);


Dart_Handle NewDartExceptionWithMessage(const char* library_url, const char* exception_name, const char* message);


Dart_Handle HandleError(Dart_Handle handle)
{
    if (Dart_IsError(handle))
        Dart_PropagateError(handle);

    return handle;
}


DART_EXPORT Dart_Handle lila_socket_Init(Dart_Handle parent_library) {
    if (Dart_IsError(parent_library)) 
        return parent_library;

    Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName, NULL);
    if (Dart_IsError(result_code)) 
        return result_code;

    return Dart_Null();
}


int get_int_argument(Dart_NativeArguments arguments, int position)
{
    Dart_Handle dart_argument = Dart_GetNativeArgument(arguments, position);
    if (! Dart_IsInteger(dart_argument))
        Dart_PropagateError(Dart_NewUnhandledExceptionError(Dart_NewStringFromCString("Invalid Argument")));

    int64_t result;
    Dart_IntegerToInt64(dart_argument, &result);

    return result;
}


void lila_socket(Dart_NativeArguments arguments)
{
    Dart_EnterScope();

    int domain   = get_int_argument(arguments, 0);
    int type     = get_int_argument(arguments, 1);
    int protocol = get_int_argument(arguments, 2);

    int sock = socket(domain, type, protocol);

    Dart_SetReturnValue(arguments, Dart_NewInteger(sock));
    Dart_ExitScope();
}


void lila_bind(Dart_NativeArguments arguments)
{
    Dart_EnterScope();

    Dart_Handle dart_argument = Dart_GetNativeArgument(arguments, 0);
    printf("Fuck windows %d\n", Dart_IsInstance(dart_argument));
    Dart_Handle dart_inst     = Dart_GetField(dart_argument, Dart_NewStringFromCString("sin_family"));
    printf("Is it a string? %d\n", Dart_IsInteger(dart_inst));

    int64_t result;
    Dart_IntegerToInt64(dart_inst, &result);
    printf("%lld\n", result);

    const char *string; 
    Dart_StringToCString(Dart_ToString(dart_argument), &string);
    printf("name %s\n", string);

    Dart_Handle sockaddr_in = Dart_NewStringFromCString("Instance of 'sockaddr_in'");
    bool success;
    Dart_ObjectEquals(sockaddr_in, Dart_ToString(dart_argument),  &success);
    if (success) {
         printf("we have a winner name %d\n", success);
    }

    Dart_ExitScope();
}


void lila_htons(Dart_NativeArguments arguments)
{
    Dart_EnterScope();

    int64_t value;
    Dart_GetNativeIntegerArgument(arguments, 0, &value);

    Dart_SetIntegerReturnValue(arguments, htons(value));

    Dart_ExitScope();
}


bool is_instance(Dart_Handle instance, const char *name)
{
    Dart_Handle name_handle = Dart_NewStringFromCString(name);
     
    bool success;
//    Dart_ObjectEquals(sockaddr_in, Dart_ToString(dart_argument), &success);

    return success;
}


void lila_inet_aton(Dart_NativeArguments arguments)
{
    Dart_EnterScope();

    if (is_instance(Dart_GetNativeArgument(arguments, 0), "Instance of 'in_addr'")) {
        Dart_GetNativeStringArgument(arguments, 0, &value);
    } else
       printf("error\n");


    inet_aton("63.161.169.137", &myaddr.sin_addr.s_addr);

    Dart_ExitScope();
}


struct FunctionLookup {
    const char* name;
    Dart_NativeFunction function;
};


FunctionLookup function_list[] = {
    {"socket",         lila_socket},
    {"bind",           lila_bind},
    {"htons",          lila_htons},
    {"inet_aton",      lila_inet_aton},
    {NULL,             NULL}
};


Dart_NativeFunction ResolveName(Dart_Handle name, int argc, bool *auto_setup_scope) {
    if (! Dart_IsString(name)) 
        return NULL;
 
    Dart_NativeFunction result = NULL;
    Dart_EnterScope();

    const char* cname;
    HandleError(Dart_StringToCString(name, &cname));

    for (int i=0; function_list[i].name != NULL; ++i) {
        if (strcmp(function_list[i].name, cname) == 0) {
            result = function_list[i].function;
            break;
        }
    }

    Dart_ExitScope();

    return result;
}
