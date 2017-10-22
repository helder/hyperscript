import hyper.Script.h;

class RunTests {

    static function main() {
        function attrs() return {className: ['1', '2']}
        trace(h('div.a.b#id',{className: 'd c'}, [
            12,
            h('input', {}),
            'abc',
            if (Math.random() > .9) 'yes'
        ]));
        trace(h('input', {
            id: 'ok',
            hidden: true,
            className: ['a', 'b'],
            oninput: e -> trace(e.target.value)
        }));
    }
  
}