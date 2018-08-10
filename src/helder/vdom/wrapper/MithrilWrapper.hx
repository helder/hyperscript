package helder.vdom.wrapper;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import helder.hyperscript.Parser;
using tink.MacroApi;
#end

@:native('m') #if !no_require @:jsRequire('mithril/hyperscript') #end
extern class MithrilExtern {
  @:selfCall
  public static function m(selector: Dynamic, attrs: Dynamic, ?children: Dynamic): Dynamic;
}

class MithrilWrapper<Props: {}, State: {}> {
  var props: Props;
  var state: State;

  public function new(vnode)
    props = vnode.props;

  macro function h(ethis: Expr, selector: Expr, ?attrs: Expr, ?children: Array<Expr>) {
    parser.parse(selector, attrs, children);
    return macro null;
  }

  #if macro
  static var parser = new Parser();
  #else
  @:keep function oninit(vnode) {
    props = vnode.props;
    onInit();
  }
  @:keep function oncreate(vnode) {
    props = vnode.props;
    onCreate(vnode.dom);
  }
  @:keep function onupdate(vnode) {
    props = vnode.props;
    onUpdate(vnode.dom);
  }
  @:keep function onremove() onRemove();
  @:keep function view(vnode) {
    props = vnode.props;
    return untyped this.render();
  }

  function onInit() {}
  function onCreate(element: js.html.Element) {}
  function onUpdate(element: js.html.Element) {}
  function onRemove() {}
  #end
}