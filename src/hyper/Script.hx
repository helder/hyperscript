package hyper;

#if macro
import haxe.macro.Expr;
#end

class Script {

  macro public static function h(selector: Expr, ?attr: Expr, ?children: Expr): Expr
    return hyper.macro.Hyperscript.call(selector, attr, children);

}