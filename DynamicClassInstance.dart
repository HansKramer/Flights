/*
       Author : Hans Kramer

         Date : September 2013

    Copyright : Hans Kramer

 */

import 'dart:mirrors';


class DynamicClassInstance {

    static Map<String, ClassMirror> library_class_lut;

    factory DynamicClassInstance(String name, {String constructor: "", List arguments: null}) {
        if (library_class_lut == null) {
            library_class_lut = {};

            currentMirrorSystem().libraries.forEach( (uri, lib) {
                lib.classes.forEach( (name, klass) {
                    library_class_lut[MirrorSystem.getName(klass.qualifiedName)] = klass;
                });
            });
        }

        if (! library_class_lut.containsKey(name))
            name = "." + name;
        if (arguments == null)
            arguments = [];
        if (library_class_lut.containsKey(name)) 
            for (var cname in library_class_lut[name].constructors.values) 
                if (MirrorSystem.getName(cname.constructorName) == constructor) 
                    return library_class_lut[name].newInstance(cname.constructorName, arguments).reflectee;

        return null;
    }

    
/*
    static get_classes() {
        return class_lut.keys;
    }
    
    static get_functions() {
        return currentMirrorSystem().isolate.rootLibrary.functions.keys.map((e) => MirrorSystem.getName(e));
    }
*/
}
