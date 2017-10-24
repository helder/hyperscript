import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import hyper.macro.Attributes;

using tink.CoreApi;
using tink.MacroApi;

class TestBackend implements hyper.Backend {

  function new() {}

  static function setup() hyper.macro.Hyperscript.backend = new TestBackend();

  public function createElement(tag: String, attr: Attributes, children: Option<Expr>): Expr {
    var obj = attr.toObjectDecl(function (field) {
      return field;
    });
    return switch children {
      case Some(macro null) | None: 
        macro (cast {tag: $v{tag}, attr: $obj}: hyper.VNode);
      case Some(c): 
        macro (cast {tag: $v{tag}, attr: $obj, children: $c}: hyper.VNode);
    }
  }

  public function createComponent(type: Type, attr: Expr, children: Expr): Expr {
    var path = type.toComplex().toString().asTypePath();
    return macro new $path($attr).render();
  }

}