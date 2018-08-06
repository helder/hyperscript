package helder.vdom.wrapper;

import helder.vdom.Wrapper;

#if !macro
@:native('m') #if !no_require @:jsRequire('mithril/hyperscript') #end
extern class MithrilExtern {
  @:selfCall
  public static function m(selector: Dynamic, attrs: Dynamic, ?children: Dynamic): Dynamic;
}
#else
import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
#end

class MithrilBase<Props: {}, State: {}> extends WrapperBase<Props, State, Dynamic> {
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

@:autoBuild(helder.vdom.macro.ComponentBuilder.buildClass())
class MithrilWrapper<Props: {}, State: {}> {
  var instance: MithrilBase<Props, State>;

  public function new(vnode) {
    props = vnode.attrs;
    instance = getInstance();
  }

  function getInstance(): MithrilBase<Props, State>
    throw 'implement';

  @:keep function oninit() instance.onInit();
  @:keep function oncreate(vnode) {
    props = vnode.attrs;
    return instance.onCreate();
  }
  @:keep function onupdate() instance.onUpdate();
  @:keep function onremove() instance.onRemove();
  @:keep function view() instance.doRender();

}