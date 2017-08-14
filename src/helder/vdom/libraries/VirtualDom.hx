package helder.vdom.libraries;

import helder.vdom.Hyperscript;
import helder.vdom.Selector;
import haxe.macro.Expr;

@:require('js-virtual-dom')
class VirtualDom {

    public static function register()
        Hyperscript.register(hyperscript);

    public static var attrMap = [
        'class' => 'className'
    ];

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr) {
        return macro vdom.VDom.h(
            $selector,
            ${AttributeMapper.map(attrs, attrMap, macro helder.vdom.libraries.VirtualDom.attrMap)},
            cast $children
        );
    }

}