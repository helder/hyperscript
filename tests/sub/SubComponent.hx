package sub;

import helder.vdom.Component;
import haxe.ds.Vector;

class MyComponent extends Component {
  function render() {
    return h('.abc#idtje');
  }
}

class Sub extends Component<{attr: Bool}> {
  function render() {
    return h('.sub', 'Sub');
  }
}

class SubComponent extends Component {
  override function onInit() {
    trace('ok');
  }
  function render()
    return h('', {'class': 'abcd'}, 
      h('input[type=text]'),
      h(MyComponent),
      h(Sub),
      h('.yes', {onclick: e -> $type(e.currentTarget)}, 'Test')
    );
}