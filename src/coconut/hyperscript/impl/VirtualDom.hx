package coconut.hyperscript.impl;

import coconut.Hyperscript;
import coconut.hyperscript.Selector;
import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;
using tink.CoreApi;

@:require('js_virtual_dom')
class VirtualDom {

    static var child: ComplexType;
    static var options = coconut.ui.macros.HXX.options;

    public static function register()
        Hyperscript.register(hyperscript);

    public static var attrMap = [
        'class' => 'className'
    ];

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr) {
        var child = options.child;
        return macro @:pos(selector.pos) vdom.VDom.h(
            $selector,
            ${AttributeMapper.map(attrs, attrMap, macro coconut.hyperscript.libraries.VirtualDom.attrMap)},
            ($children: $child)
        );
    }

}