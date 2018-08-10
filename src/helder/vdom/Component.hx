package helder.vdom;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using tink.MacroApi;
#else
// Hopefully, someday: HaxeFoundation/haxe-evolution#50
@:genericBuild(helder.vdom.Component.setDefaults())
#end
class Component<Rest> {
  #if macro
  static function setDefaults()
    return switch Context.getLocalType() {
      case TInst(_, params):
        'helder.vdom.Component.ComponentWrapper'.asComplexType(
          params
            .map(Types.toComplex.bind(_, null))
            .concat([for (_ in 0 ... 2 - params.length) (macro: {})])
            .map(TPType)
        );
      default: throw 'assert';
    }
  #end
}

typedef ComponentWrapper<Props: {}, State: {}> =
  #if mithril helder.vdom.wrapper.MithrilWrapper<Props, State>
  #elseif react helder.vdom.wrapper.ReactWrapper<Props, State>
  #else #error 'No virtual dom library selected' #end