import 'dart:mirrors';


class Aap {
    Aap() {
        print("create an aap");
    }

    hello() {
        print("Monkey!!!!");
    }
}


class DynamicClassInstance {

    static Map<String, ClassMirror> class_lut;

    factory DynamicClassInstance(String name) {
        if (class_lut == null) {
            var cm = currentMirrorSystem().isolate.rootLibrary.classes;
            class_lut = {};
            cm.forEach((k,v) => class_lut[MirrorSystem.getName(k)] = v);
        }

        return class_lut.containsKey(name) ? class_lut[name].newInstance(const Symbol(""), []).reflectee : null;
    }
}


main() {
    String class_name = "Aap";
    var aap = new DynamicClassInstance(class_name);
    aap.hello();
    var leuk = new DynamicClassInstance("Aapje");
    print(leuk);
}
