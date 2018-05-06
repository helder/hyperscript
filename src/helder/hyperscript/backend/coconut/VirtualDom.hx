package helder.hyperscript.backend.coconut;

import haxe.macro.Type;
import haxe.macro.Expr;

using tink.MacroApi;

@:require('coconut.ui')
class VirtualDom extends helder.hyperscript.backend.VirtualDom {

  static var options = coconut.ui.macros.HXX.options;

  override public function createComponent(type: Type, attr: Expr, children: Expr): Expr {
    var child = options.child;
    var path = type.toComplex().toString().asTypePath();
    return macro (coconut.ui.tools.ViewCache.create(new $path($attr)): $child);
  }

}