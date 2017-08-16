import coconut.Hyperscript.h;
import coconut.hyperscript.View;
import haxe.macro.Expr;

class Test extends View<{title: String}> {
    function render() {
        return h('article', [
            h('h1', title),
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