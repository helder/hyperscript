package helder.hyperscript.backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import helder.hyperscript.macro.Attributes;

using tink.MacroApi;
using tink.CoreApi;

@:require('js-virtual-dom')
class VirtualDom implements helder.hyperscript.Backend {

  public function new() {}

  public function createElement(tag: String, attr: Attributes, children: Option<Expr>): Expr {
    var obj = attr.toObjectDecl(function (field) return field);
    return switch children {
      case Some(macro null) | None: 
        macro (cast vdom.VDom.h($v{tag}, cast $obj): helder.hyperscript.VNode);
      case Some(c): 
        macro (cast vdom.VDom.h($v{tag}, cast $obj, cast $c): helder.hyperscript.VNode);
    }
  }

  public function createComponent(type: Type, attr: Expr, children: Expr): Expr {
    throw 'Unsupported';
  }

}