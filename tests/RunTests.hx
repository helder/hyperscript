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
      new ChildrenTest(),
      new ComponentTest()
    ])).handle(Runner.exit);
  }
}

class Component {
  public function new(attrs) {}
  public function render() 
    return h('.test', 'test');
}

@:asserts
class ComponentTest {

  public function new() {}

  public function useComponent() {
    return assert(h(Component).is({
      tag: 'div', attr: {className: 'test'}, 
      children: ['test']
    }));
  }

}

@:asserts
class ChildrenTest {
  
  public function new() {}

  public function skipAttrs()
    return assert(h('', ['test']).is({
      tag: 'div', attr: {}, 
      children: ['test']
    }));

  public function ifStatements()
    return assert(h('', {}, [
      if (true) 'test'
    ]).is({
      tag: 'div', attr: {}, 
      children: ['test']
    }));

  public function forLoops()
    return assert(h('', {}, [
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
    return assert(h('div#test').is({tag: 'div', attr: {id: 'test'}}));

  public function parseClasses() {
    asserts.assert(h('div.a').is({tag: 'div', attr: {className: 'a'}}));
    asserts.assert(h('div.a.b').is({tag: 'div', attr: {className: 'a b'}}));
    asserts.assert(h('div.a.b', {className: 'c'}).is({tag: 'div', attr: {className: 'a b c'}}));
    return asserts.done();
  }

  public function addRuntimeClasses() {
    var runtimeClass = 'c-'+Math.random();
    asserts.assert(h('div.a.b', {'class': runtimeClass}).is({tag: 'div', attr: {className: 'a b '+runtimeClass}}));
    return asserts.done();
  }

  public function attributes() {
    var click = e -> null;
    asserts.assert(h('div', {
      onclick: click
    }).is({tag: 'div', attr: {onclick: click}}));
    asserts.assert(h('div[data-test=123]').is({
      tag: 'div', 
      attr: {
        attributes: {'data-test': '123'}
      }
    }));
    return asserts.done();
  }

  public function parseAttrs() {
    asserts.assert(h('div[hidden]').is({tag: 'div', attr: {hidden: true}}));
    asserts.assert(h('div[id=test]').is({tag: 'div', attr: {id: 'test'}}));
    asserts.assert(h('div[id=test]', {hidden: true}).is({tag: 'div', attr: {id: 'test', hidden: true}}));
    asserts.assert(h('div[title="my title"][spellcheck]').is({tag: 'div', attr: {title: 'my title', spellcheck: true}}));
    return asserts.done();
  }

}