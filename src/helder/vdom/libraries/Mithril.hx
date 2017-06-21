package helder.vdom.libraries;

import helder.vdom.Hyperscript;
import helder.vdom.Selector;
import haxe.macro.Expr;

@:native('m') #if !no_require @:jsRequire('mithril') #end
extern class MithrilExtern {
    @:selfCall
    public static function m(selector: Selector, attrs: Dynamic, children: Dynamic): Dynamic;
}

class Mithril {

    public static function register()
        Hyperscript.register(hyperscript);

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr)
        return macro @:privateAccess helder.vdom.libraries.Mithril.MithrilExtern.m($selector, $attrs, $children);

}