package helder.vdom;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
#else
@:genericBuild(helder.vdom.macro.ComponentBuilder.build())
class Component<Rest> {}
#end

class ComponentImpl<Props: {}> {
  public function new() {}

  macro function h(ethis: Expr, selector: Expr, ?attrs: Expr, ?children: Array<Expr>) {
    switch selector.getString() {
      case Success(selector): 
        trace(selector);
      default: 
        var type = Context.getType(selector.toString());
        return selector;
    }
    return macro 'root comp';
  }
}