package hyper.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using tink.MacroApi;

typedef AttrTypes = Map<String, ComplexType>;
typedef Field = {name: String, expr: Expr}

class Attributes {

  static var types: Map<Type, AttrTypes> = new Map();
  
  var fields: Array<Field>;
  var type: AttrTypes;
  var setup: Expr;

  public function new(fields, type, ?setup) {
    this.type = getType(type);
    this.fields = fields;
    this.setup = setup;
  }

  public function addClasses(classes: Array<String>) {
    var add = classes.join(' ');
    for (field in fields) {
      if (field.name == 'className') {
        var old = field.expr;
        field.expr = switch old.expr {
          case EConst(CString(str)): macro $v{add+' '+str};
          default: macro $v{add} + ' ' + ($old: hyper.Attr.ClassName);
        }
        return;
      }
    }
    fields.push({
      name: 'className', expr: macro $v{add}
    });
  }

  function typeField(field: Field): Field {
    var expr = field.expr;
    if (!type.exists(field.name))
      expr.reject('Extra field ${field.name}');
    var typed = type[field.name];
    return {name: field.name, expr: macro @:pos(expr.pos) ($expr: $typed)}
  }

  public function toObjectDecl(map: Field -> Field) {
    var decl = EObjectDecl(fields.map(typeField).map(map).map(function(field) {
      return {field: field.name, expr: field.expr}
    })).at(Context.currentPos());
    return 
      if (setup == null) decl
      else macro @:pos(decl.pos) {$setup; $decl;}
  }

  function getType(type: Type) {
    if (types.exists(type)) return types[type];
    return types[type] = switch Context.follow(type) {
      case TAnonymous(_.get().fields => fields):
        types[type] = [for (field in fields) field.name => field.type.toComplex()];
      default: throw 'assert';
    }
  }

}