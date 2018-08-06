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
    return ClassBuilder.run([function (c: ClassBuilder) {
      var fields = Context.getBuildFields();
      var module = Context.getLocalModule().asTypePath();
      var name = c.target.name;
      var meta = c.target.meta;
      meta.remove(':build');
      var superType = c.target.superClass;
      var superModule = superType.t.get();
      var superDef = {
        name: superModule.name,
        pack: superModule.pack,
        //sub: superModule.name == superModule.module ? null: superModule.name,
        params: superType.params.map(function (param)
          return TPType(param.toComplex())
        )
      }
      trace(superDef);
      var definition: TypeDefinition = {
        pack: [],//Context.getLocalModule().split('.'),
        name: '${name}_Impl',
        pos: Context.currentPos(),
        meta: meta.get(),
        kind: TDClass(superDef, [], false),
        fields: fields
      }
      Context.defineType(definition);
      trace(definition.pack);
    }]);
  }
}