package helder.hyperscript.backend;

#if !macro

@:native('m') #if !no_require @:jsRequire('mithril/hyperscript') #end
extern class MithrilExtern {
  @:selfCall
  public static function m(selector: Dynamic, attrs: Dynamic, ?children: Dynamic): Dynamic;
}

#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import helder.hyperscript.macro.Attributes;
import haxe.ds.Option;
using tink.MacroApi;

@:require('mithril')
class Mithril implements helder.hyperscript.Backend {
  public function new() {}

  public function createElement(tag: String, attr: Attributes, children: Option<Expr>): Expr {
    var obj = attr.toObjectDecl(function (field) return field);
    return switch children {
      case Some(macro null) | None: 
        macro (cast helder.hyperscript.backend.Mithril.MithrilExtern.m($v{tag}, cast $obj): helder.hyperscript.VNode);
      case Some(c): 
        macro (cast helder.hyperscript.backend.Mithril.MithrilExtern.m($v{tag}, cast $obj, cast $c): helder.hyperscript.VNode);
    }
  }

  public function createComponent(type: Type, attr: Expr, children: Expr): Expr {
    return macro (cast helder.hyperscript.backend.Mithril.MithrilExtern.m($i{type.toComplex().toString()}, $attr, $children): helder.hyperscript.VNode);
  }
}

#end