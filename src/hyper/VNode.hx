package hyper;

// Source: https://github.com/back2dos/js-virtual-dom/blob/master/src/vdom/VNode.hx

#if macro 
import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
#end

typedef Children = Array<VNode>;

@:coreType abstract VNode {

  @:from static inline function ofString(s: String): VNode 
    return cast s;

  @:from static inline function ofInt(i: Int): VNode 
    return ofString(Std.string(i));

  @:to function toChildren(): Children
    return cast this;

  @:noCompletion @:from static public function flatten(c: Children): VNode
    return cast c;

  @:noCompletion @:from macro static public function fromVoid(e: ExprOf<Void>): ExprOf<VNode> {
    return switch Context.getTypedExpr(Context.typeExpr(e)) {
      case macro if($e1) $e2: macro if($e1) $e2 else null;
      default: e.reject('Expr cannot be Void');
    }
  }

}