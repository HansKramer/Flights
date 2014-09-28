/*
       Author : Hans Kramer

         Date : September 2013

    Copyright : Hans Kramer

 */

import 'dart:mirrors';


class DynamicClassInstance {

    static Map<String, ClassMirror> library_class_lut;

    static init() {
        library_class_lut = {};

        currentMirrorSystem().libraries.forEach( (uri, lib) {
             var lib_name = MirrorSystem.getName(lib.qualifiedName);
             //print(lib.declarations);
             lib.declarations.forEach( (symbol, declaration_mirror) {
                 if (declaration_mirror is ClassMirror) {
                     library_class_lut[MirrorSystem.getName(symbol)] = declaration_mirror;
                     //library_class_lut[MirrorSystem.getName(klass.qualifiedName)] = klass;
                     //print(lib_name + ":" + MirrorSystem.getName(symbol));
                 }
             });
        });
    }

    static get_classes() {
        if (library_class_lut == null) 
            DynamicClassInstance.init();

        return library_class_lut.keys;
    }
    
    factory DynamicClassInstance(String name, {String constructor: "", List arguments: null}) {
        if (library_class_lut == null) 
            DynamicClassInstance.init();

        //if (! library_class_lut.containsKey(name))
        //    name = "." + name;
        if (arguments == null)
            arguments = [];
        if (library_class_lut.containsKey(name)) 
            for (var dm in library_class_lut[name].declarations.values) 
                if (dm is MethodMirror && dm.isConstructor && MirrorSystem.getName(dm.constructorName) == constructor) 
                    return library_class_lut[name].newInstance(dm.constructorName, arguments).reflectee;

        return null;
    }
    
// probaby broken beyond here
    factory DynamicClassInstance.get_name(T, List arguments) {
        if (library_class_lut == null) 
            DynamicClassInstance.init();

        return library_class_lut[MirrorSystem.getName(reflectClass(T).qualifiedName)].newInstance(const Symbol(""), arguments).reflectee;
    }

    static getMethod(var instance, string method) {
        if (library_class_lut == null) 
            DynamicClassInstance.init();

        for (var mname in reflect(instance).type.methods.keys)
            if (MirrorSystem.getName(mname) == method)
                return (var arg) => reflect(instance).invoke(mname, [arg,]);

        return null;
    }
/*
    static get_functions() {
        return currentMirrorSystem().isolate.rootLibrary.functions.keys.map((e) => MirrorSystem.getName(e));
    }
*/
}
