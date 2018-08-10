package helder.vdom.wrapper;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import helder.hyperscript.Parser;
using tink.MacroApi;
#end

@:native('React') #if !no_require @:jsRequire('react') #end
extern class ReactExtern {
  public static function createElement(selector: Dynamic, attrs: Dynamic, children: Dynamic): Dynamic;
}
@:native('React.Component') #if !no_require @:jsRequire('react', 'Component') #end
extern class ReactComponent<Props: {}, State: {}> {
  var props: Props;
  var state: State;
  public function new(props: Props): Void;
}
@:native('ReactDOM') #if !no_require @:jsRequire('react-dom') #end
extern class ReactDom {
  #if !macro static function findDOMNode<P: {}, S: {}>(component: ReactComponent<P, S>): js.html.Element; #end
}

class ReactWrapper<Props: {}, State: {}> extends ReactComponent<Props, State> {
  static 
  macro function h(ethis: Expr, selector: Expr, ?attrs: Expr, ?children: Array<Expr>) {
    parser.parse(selector, attrs, children);
    return macro null;
  }
  
  #if macro
  static var parser = new Parser();
  #else
  public function new(props) {
    super(props);
    onInit();
  }

  @:keep function componentDidMount() onCreate(ReactDom.findDOMNode(this));
  @:keep function componentDidUpdate() onUpdate(ReactDom.findDOMNode(this));

  function onInit() {}
  function onCreate(element: js.html.Element) {}
  function onUpdate(element: js.html.Element) {}
  @:native('componentWillUnmount')
  function onRemove() {}
  #end
}