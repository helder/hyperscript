package helder;

import helder.hyperscript.VNode;

#if macro
import haxe.macro.Expr;
#end

class Hyperscript {

  macro public static function h(selector: Expr, ?attr: Expr, ?children: ExprOf<Array<VNode>>): ExprOf<VNode>
    return helder.hyperscript.macro.Hyperscript.call(selector, attr, children);

}