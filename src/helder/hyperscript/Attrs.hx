package helder.hyperscript;
#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
#end

abstract Attrs<T>(T) to T {
  @:from macro public static function fromExpr<T>(e: ExprOf<T>) {
    var typed = Context.typeExpr(e);
    var expr = Context.getTypedExpr(typed);
    var stored = Context.storeTypedExpr(typed);
    var type = Context.typeof(e);
    var complex = type.toComplex();
    return macro ($e: Attrs<Int>);
  }

  macro public function unwrap(e: Expr): ExprOf<T> {
    trace(Context.typeof(e));
    return macro $e;
  }

  macro public static function type(e: Expr) {
    trace(Context.typeof(e));
    return macro null;
  }
}

@:coreType abstract AttrsBag {

}