import helder.vdom.Component;
import tink.unit.Assert.assert;
import sub.SubComponent;

class TestComponent {
  public function new() {}

  public function testCreation() {
    trace(@:privateAccess new SubComponent({props: null}).view({props: null}));
    return assert(true);
  }
}