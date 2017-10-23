import tink.unit.*;
import tink.unit.Assert.*;
import tink.testrunner.*;
import deepequal.DeepEqual;
import hyper.Script.h;
import hyper.VNode;

using RunTests.VNodeCompare;

class VNodeCompare {
  public static function is(vnode: VNode, obj: {}, ?pos:haxe.PosInfos) {
    return DeepEqual.compare(obj, vnode, pos);
  }
}

class RunTests {
  static function main() {
    Runner.run(TestBatch.make([
      new SelectorTest(),
      new ChildrenTest()
    ])).handle(Runner.exit);
  }
}

@:asserts
class ChildrenTest {
  
  public function new() {}

  public function ifStatements()
    return assert(h('', [
      if (true) 'test'
    ]).is({
      tag: 'div', attr: {}, 
      children: ['test']
    }));

  public function forLoops()
    return assert(h('', [
      0,
      for (i in 1 ... 3) i,
      3
    ]).is({
      tag: 'div', attr: {}, 
      children: (['0', ['1', '2'], '3']: Array<Dynamic>)
    }));

}

@:asserts
class SelectorTest {

  public function new() {}

  public function parseId()
    return assert(h('div#test').is({tag: 'div', attr: {id: 'test'}, children: null}));

  public function parseClasses() {
    asserts.assert(h('div.a').is({tag: 'div', attr: {className: 'a'}, children: null}));
    asserts.assert(h('div.a.b').is({tag: 'div', attr: {className: 'a b'}, children: null}));
    asserts.assert(h('div.a.b', {className: 'c'}).is({tag: 'div', attr: {className: 'a b c'}, children: null}));
    return asserts.done();
  }

  public function parseAttrs() {
    asserts.assert(h('div[hidden]').is({tag: 'div', attr: {hidden: true}, children: null}));
    asserts.assert(h('div[id=test]').is({tag: 'div', attr: {id: 'test'}, children: null}));
    asserts.assert(h('div[id=test]', {hidden: true}).is({tag: 'div', attr: {id: 'test', hidden: true}, children: null}));
    asserts.assert(h('div[title="my title"][spellcheck]').is({tag: 'div', attr: {title: 'my title', spellcheck: true}, children: null}));
    return asserts.done();
  }

}