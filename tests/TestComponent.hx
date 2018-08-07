import helder.vdom.Component;
import tink.unit.Assert.assert;
import sub.SubComponent;

class MyComponent extends Component {
  function render() {
    return h('.abc', {attr: true});
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
    trace(@:privateAccess new SubComponent(null).view());
    return assert(true);
  }
}