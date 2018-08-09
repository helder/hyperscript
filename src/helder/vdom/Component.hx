package helder.vdom;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
using tink.MacroApi;
#else
@:genericBuild(helder.vdom.Component.setDefaults())
#end
class Component<Rest> {
  #if macro
  static var object = (macro: {}).toType().sure();
  static function setDefaults()
    return switch Context.getLocalType() {
      case type = TInst(_.toString() == 'helder.vdom.Component' => true, params):
        'helder.vdom.Component.ComponentWrapper'.asComplexType((
          switch params {
            case [p]: [p, object];
            case [p, s]: [p, s];
            default: [object, object];
          }
        ).map(function (type) return TPType(type.toComplex())));
      default:
        throw 'assert';
    }
  #end
}

typedef ComponentWrapper<Props: {}, State: {}> =
  #if mithril helder.vdom.wrapper.MithrilWrapper<Props, State>
  #elseif react helder.vdom.wrapper.ReactWrapper<Props, State>
  #else #error 'No virtual dom library selected' #end