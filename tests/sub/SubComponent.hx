package sub;

import helder.vdom.Component;
import haxe.ds.Vector;

class SubComponent extends Component {
  function render() {
    var test = new Vector(5);
    trace(test);
    return h('.abc', {attr: true});
  }
}