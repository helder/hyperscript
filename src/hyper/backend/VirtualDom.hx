package coconut.hyperscript.impl;

import coconut.Hyperscript;
import coconut.hyperscript.Selector;
import haxe.macro.Expr;
import haxe.macro.Context;

using tink.MacroApi;
using tink.CoreApi;

@:require('coconut.vdom')
class VirtualDom {

    static var options = coconut.ui.macros.HXX.options;

    public static function register()
        Hyperscript.register(hyperscript);

    public static var attrMap = [
        'class' => 'className'
    ];

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr) {
        var child = options.child;
        return switch selector.expr {
            case EConst(CString(source)):
                macro @:pos(selector.pos) vdom.VDom.h(
                    $selector,
                    ${AttributeMapper.map(attrs, attrMap, macro coconut.hyperscript.libraries.VirtualDom.attrMap)},
                    ($children: $child)
                );
            case EConst(CIdent(component)):
                switch component.definedType() {
                    case None: throw selector.reject('Unknown type ${component}');
                    case Some(_.reduce() => t):
                        var path = component.asTypePath();
                        macro (coconut.ui.tools.ViewCache.create(new $path($attrs)): $child);
                }
            default:
                throw selector.reject('Selector is expected to be a string literal or Class<T>');
        }
        
    }

}