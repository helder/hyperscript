package hyper;

#if macro
import haxe.macro.Expr;
#end

class Script {

  macro public static function h(selector: Expr, ?attr: Expr, ?children: ExprOf<Array<VNode>>): ExprOf<VNode>
    return hyper.macro.Hyperscript.call(selector, attr, children);

}