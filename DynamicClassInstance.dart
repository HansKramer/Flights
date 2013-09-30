/*
       Author : Hans Kramer

         Date : September 2013

    Copyright : Hans Kramer

 */

import 'dart:mirrors';


class DynamicClassInstance {

    static Map<String, ClassMirror> class_lut;

    factory DynamicClassInstance(String name) {
        if (class_lut == null) {
            class_lut = {};

            var cm = currentMirrorSystem().isolate.rootLibrary.classes;
            cm.forEach((k,v) => class_lut[MirrorSystem.getName(k)] = v);

            for (var lib in currentMirrorSystem().libraries.keys) {
                var libname = lib.pathSegments.last.endsWith(".dart") ?
                              lib.pathSegments.last.substring(0, lib.pathSegments.last.length-5) :
                              lib.pathSegments.last;
                currentMirrorSystem().libraries[lib].classes.forEach((k,v) => class_lut[libname + "." + MirrorSystem.getName(k)] = v);
            }
        }

        return class_lut.containsKey(name) ? class_lut[name].newInstance(const Symbol(""), []).reflectee : null;
    }

    
    static get_classes() {
        return class_lut.keys;
    }
    
    static get_functions() {
        return currentMirrorSystem().isolate.rootLibrary.functions.keys.map((e) => MirrorSystem.getName(e));
    }
}

class Fuckers {
    Fuckers() {
       print("we are the fuckers");
    }
}
