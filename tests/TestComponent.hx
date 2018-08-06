import helder.vdom.Component;
import tink.unit.Assert.assert;

class MyComponent extends Component {
  function render() {
    return h(Sub, {attr: true});
  }
}

class Sub extends Component<{attr: Bool}> {
  function render() {
    return h('.sub', 'Sub');
  }
}

class TestComponent {
  public function new() {}

  public function testCreation() {
    trace(@:privateAccess new MyComponent(null).render());
    return assert(true);
  }
}