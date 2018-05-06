package hyper.backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import hyper.macro.Attributes;

using tink.MacroApi;
using tink.CoreApi;

#if !macro
@:native('m') #if !no_require @:jsRequire('mithril/hyperscript') #end
extern class MithrilExtern {
    @:selfCall
    public static function m(selector: Dynamic, attrs: Dynamic, children: Dynamic): Dynamic;
}
#end

class Mithril implements hyper.Backend {

  public function new() {}

  public function createElement(tag: String, attr: Attributes, children: Option<Expr>): Expr {
    var obj = attr.toObjectDecl(function (field) return field);
    return switch children {
      case Some(macro null) | None: 
        macro (cast hyper.backend.MithrilExtern.m($v{tag}, cast $obj): hyper.VNode);
      case Some(c): 
        macro (cast hyper.backend.MithrilExtern.m($v{tag}, cast $obj, cast $c): hyper.VNode);
    }
  }

  public function createComponent(type: Type, attr: Expr, children: Expr): Expr {
    throw 'Unsupported';
  }

}