import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import helder.hyperscript.macro.Attributes;

using tink.CoreApi;
using tink.MacroApi;

class TestBackend implements helder.hyperscript.Backend {

  function new() {}

  static function setup() helder.hyperscript.macro.Hyperscript.backend = new TestBackend();

  public function createElement(tag: String, attr: Attributes, children: Option<Expr>): Expr {
    var obj = attr.toObjectDecl(function (field) {
      return field;
    });
    return switch children {
      case Some(macro null) | None: 
        macro (cast {tag: $v{tag}, attr: $obj}: helder.hyperscript.VNode);
      case Some(c): 
        macro (cast {tag: $v{tag}, attr: $obj, children: $c}: helder.hyperscript.VNode);
    }
  }

  public function createComponent(type: Type, attr: Expr, children: Expr): Expr {
    var path = type.toComplex().toString().asTypePath();
    return macro new $path($attr).render();
  }

}