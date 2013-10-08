/*
       Author : Hans Kramer

         Date : September 2013

    Copyright : Hans Kramer

 */

import 'DynamicClassInstance.dart';



class TestClass {
    TestClass(var arg) {
        print("Main constructor TestClass($arg)");
    }

    TestClass.alt1() {
        print("Main constructor TestClass.alt1()");
    }

    TestClass.alt2(var arg) {
        print("main constructor TestClass.alt2(${arg})");
    }

    hello() {
         print("hello");
    }
}


main() {
    String class_name = ".Aap";
    var aap;
    aap = new DynamicClassInstance(".TestClass", arguments: ["hello"]);
    aap = new DynamicClassInstance(".TestClass", constructor: "alt1");
    aap = new DynamicClassInstance("TestClass", constructor: "alt2", arguments: ["hello"]);
}
