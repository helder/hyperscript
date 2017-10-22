package hyper.backend;

import haxe.macro.Expr;

class Object {

  var indent = 0;

  public function new() {}

  function attr(name: String, expr: Expr) {
    return macro $name+'="'+$expr+'"';
  }

  public function createElement(tag: String, attrs: Expr, children: Null<Expr>) {
    indent++;
    //tra
    if (children == null) return '<$tag '
    return macro {
      tag: $v{tag}, attrs: $attrs, children: $children
    }
  }

}