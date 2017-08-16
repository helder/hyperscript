package coconut.hyperscript.impl;

import coconut.Hyperscript;
import coconut.hyperscript.Selector;
import haxe.macro.Expr;

#if !macro
import coconut.hyperscript.Selector;
@:native('m') #if !no_require @:jsRequire('mithril/hyperscript') #end
extern class MithrilExtern {
    @:selfCall
    public static function m<Attrs>(selector: Selector<Attrs>, attrs: Attrs, children: Dynamic): Dynamic;
}
#end

class Mithril {

    public static function register()
        Hyperscript.register(hyperscript);

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr)
        return macro @:privateAccess coconut.hyperscript.libraries.Mithril.MithrilExtern.m($selector, $attrs, $children);

}