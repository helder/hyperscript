package helder.hyperscript.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import tink.macro.TypeMap;

using tink.MacroApi;

typedef AttrTypes = Map<String, ComplexType>;
typedef Field = {name: String, expr: Expr}

class Attributes {

  static inline var HAXE_KEY_PREFIX = "@$__hx__";
  static var types = new TypeMap<AttrTypes>();
  static var alias = [
    'class' => 'className',
    'for' => 'htmlFor',
    'tabindex' => 'tabIndex',
    'accesskey' => 'accessKey',
    'accesskeylabel' => 'accessKeyLabel',
    'contenteditable' => 'contentEditable',
    'colspan' => 'colSpan',
    'rowspan' => 'rowSpan',
    'allowfullscreen' => 'allowFullscreen',
    'defaultselected' => 'defaultSelected'
  ];
  
  var fields: Array<Field>;
  var type: AttrTypes;
  var setup: Expr;

  public function new(fields, type, ?setup) {
    this.type = getType(type);
    this.fields = normalize(fields);
    remapKeys(alias);
    this.setup = setup;
  }

  public function addClasses(classes: Array<String>) {
    var add = classes.join(' ');
    for (field in fields) {
      if (field.name == 'className') {
        var old = field.expr;
        field.expr = switch old.expr {
          case EConst(CString(str)): macro $v{add+' '+str};
          default: macro $v{add} + ' ' + ($old: tink.domspec.ClassName);
        }
        return;
      }
    }
    fields.push({
      name: 'className', expr: macro $v{add}
    });
  }

  function normalize(fields: Array<Field>) {
    var attributes = [], properties = [];
    for (field in fields) {
      if (alias.exists(field.name)) field.name = alias[field.name];
      if (field.name.indexOf('-') > 0) attributes.push(field);
      else properties.push(field);
    }
    if (attributes.length > 0)
      properties.push({
        name: 'attributes',
        expr: EObjectDecl(attributes.map(function(field) {
          var expr = field.expr;
          return cast {field: field.name, expr: macro @:pos(expr.pos) ($expr: helder.hyperscript.Attr.Ext)}
        })).at(Context.currentPos())
      });
    return properties;
  }

  function remapKeys(map: Map<String, String>) {
    for (field in fields) {
      var key = field.name;
      if (key.substr(0, HAXE_KEY_PREFIX.length) == HAXE_KEY_PREFIX)
          key = key.substr(HAXE_KEY_PREFIX.length);
      if (map.exists(key)) 
        field.name = map[key];
    }
  }

  function typeField(field: Field): Field {
    var expr = field.expr;
    if (!type.exists(field.name))
      expr.reject('Extra field ${field.name}');
    var typed = type[field.name];
    return {name: field.name, expr: macro @:pos(expr.pos) ($expr: $typed)}
  }

  function toObjectField(field) {
    // Todo: deal with haxe 4 changes ... (ObjectField)
    return cast {field: field.name, expr: field.expr}
  }

  public function toObjectDecl(map: Field -> Field) {
    var decl = 
      EObjectDecl(fields.map(typeField).map(map).map(toObjectField))
      .at(Context.currentPos());
    return 
      if (setup == null) decl
      else macro @:pos(decl.pos) {$setup; $decl;}
  }

  function getType(type: Type) {
    if (!types.exists(type))
      types.set(type, switch Context.follow(type) {
        case TAnonymous(_.get().fields => fields):
          [for (field in fields) field.name => field.type.toComplex()];
        default: throw 'assert';
      });
     return types.get(type);
  }

}