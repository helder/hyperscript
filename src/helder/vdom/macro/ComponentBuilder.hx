package helder.vdom.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import tink.macro.BuildCache;

using tink.MacroApi;

class ComponentBuilder {
  static var wrapper = 
    #if mithril 'helder.vdom.wrapper.MithrilWrapper'
    #else throw 'No virtual dom libary selected' #end;
  static var base = 
    #if mithril 'helder.vdom.wrapper.MithrilWrapper.MithrilBase'
    #else throw 'No virtual dom libary selected' #end;
  static var object = (macro: {}).toType().sure();
  
  static function build()
    return switch Context.getLocalType() {
      case type = TInst(_.toString() == 'helder.vdom.Component' => true, params):
        //trace(type);
        wrapper.asComplexType((
          switch params {
            case [p]: [p, object];
            case [p, s]: [p, s];
            default: [object, object];
          }
        ).map(function (type) return TPType(type.toComplex())));
      default:
        throw 'assert';
    }

  static function buildClass(): Array<Field> {
    trace(Context.getLocalImports());
    var target = Context.getLocalClass().get();
    var fields = Context.getBuildFields();
    var name = target.name;
    var meta = target.meta;
    meta.remove(':build');
    meta.remove(':autoBuild');
    var superType = target.superClass;
    var superModule = superType.t.get();
    var superPath = base.asTypePath();
    superPath.params = superType.params.map(function (param)
      return TPType(param.toComplex())
    );
    var impl = '${name}_Impl';
    var baseBuilder = new ClassBuilder(target, fields);
    baseBuilder.addMembers(macro class {
      // Todo: type this somehow
      override inline function doRender() return cast render();
    });
    var definition: TypeDefinition = {
      pack: target.pack,
      name: impl,
      pos: Context.currentPos(),
      meta: meta.get(),
      kind: TDClass(superPath, [], false),
      fields: baseBuilder.export()
    }
    Context.defineType(definition);
    var builder = new ClassBuilder(target, []);
    var path = impl.asTypePath();
    builder.addMembers(macro class {
      override function getInstance() return new $path();
    });
    return builder.export();
  }
}