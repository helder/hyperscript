package hyper;

import haxe.macro.Expr;
import haxe.macro.Context;
import hyper.macro.Attributes;

using tink.MacroApi;

class Backend {

  public function new() {}

  public function createElement(tag: String, attr: Attributes, children: Expr) {
    var obj = attr.toObjectDecl(function (field) {
      return field;
    });
    return macro (cast {
      tag: $v{tag}, attr: $obj, children: $children
    }: hyper.VNode);
  }

}