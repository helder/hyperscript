package helder.vdom.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class ComponentBuilder {
  static var wrapper = 
    #if mithril 'helder.vdom.wrapper.MithrilWrapper'
    #elseif react 'helder.vdom.wrapper.ReactWrapper'
    #else throw 'No virtual dom libary selected' #end;
  static var object = (macro: {}).toType().sure();
  
  static function build()
    return switch Context.getLocalType() {
      case type = TInst(_.toString() == 'helder.vdom.Component' => true, params):
        wrapper.asComplexType((
          switch params {
            case [p]: [p, object];
            case [p, s]: [p, s];
            default: [object, object];
          }
        ).map(function (type) return TPType(type.toComplex())));
      default:
        throw 'assert';
    }
}