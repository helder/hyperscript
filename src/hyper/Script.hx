package hyper;

#if macro
import haxe.macro.Expr;
#end

class Script {

  macro public static function h(selector: ExprOf<String>, ?attr: ExprOf<Attr>, ?children: ExprOf<Array<VNode>>): ExprOf<VNode>
    return hyper.macro.Hyperscript.call(selector, attr, children);

}