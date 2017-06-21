import helder.vdom.Hyperscript.h;
import helder.vdom.Component;
import haxe.macro.Expr;

class Test extends Component {
    public function view() {
        return h('article', [
            h('h1', 'title'),
            h('p.intro', [
                'hello', 
                h('b', 'world')
            ])
        ]);
    }
}

class RunTests {

    static function main() {
        trace(h(Test));
    }
  
}