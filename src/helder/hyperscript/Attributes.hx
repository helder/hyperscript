package helder.hyperscript;

import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Context;
using tink.MacroApi;

typedef AttrTypes = Map<String, ComplexType>;

class Attributes {
  var tag: String;
  var type: AttrTypes;
  var fields: Array<ObjectField>;
  var wrap: Expr -> Expr;

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

  public function new(tag, type: Type, fields, ?wrap) {
    this.tag = tag;
    this.type = getType(type);
    this.fields = remapKeys(fields, alias);
    this.wrap = wrap == null ? function (expr) return expr : wrap;
  }

  public function set(key: String, value: Expr) {
    for (field in fields)
      if (field.field == key) {
        field.expr = value;
        return;
      }
    fields.push({
      field: key,
      expr: value
    });
  }

  public function addClasses(classes: Array<String>) {
    var add = classes.join(' ');
    for (field in fields) {
      if (field.field == 'className') {
        var old = field.expr;
        field.expr = switch old.expr {
          case EConst(CString(str)): macro $v{add+' '+str};
          default: macro $v{add} + ' ' + ($old: tink.domspec.ClassName);
        }
        return;
      }
    }
    fields.push({
      field: 'className', expr: macro $v{add}
    });
  }

  public function toObjectDecl(
    ?reorder: Array<ObjectField> -> Array<ObjectField>
  ) {
    var fields = 
      (reorder == null ? fields : reorder(fields)).map(typeField);
    var decl = EObjectDecl(fields).at(Context.currentPos());
    return wrap(decl);
  }

  function remapKeys(fields: Array<ObjectField>, map: Map<String, String>)
    return fields.map(function(field): ObjectField
      return
        if (map.exists(field.field))
          {field: map[field.field], expr: field.expr}
        else field
    );

  function typeField(field: ObjectField): haxe.macro.ObjectField {
    var expr = field.expr;
    if (!type.exists(field.field))
      expr.reject('Field "${field.field}" does not exist on element $tag');
    var typed = type[field.field];
    return {field: field.field, expr: macro @:pos(expr.pos) ($expr: $typed)}
  }

  static function getType(type: Type) {
    if (!types.exists(type))
      types.set(type, switch Context.follow(type) {
        case TAnonymous(_.get().fields => fields):
          [for (field in fields) field.name => field.type.toComplex()];
        default: throw 'assert';
      });
    return types.get(type);
  }

  public static function ofExpr(tag, type, expr: Expr)
    return switch expr.expr {
      case EObjectDecl(fields):
        new Attributes(tag, type, [
          for (field in fields) 
            {field: field.field, expr: field.expr}
        ]);
      case EBlock([]) | EConst(CIdent('null')): 
        new Attributes(tag, type, []);
      default: 
        switch expr.typeof().sure().followWithAbstracts() {
          case TAnonymous(_.get().fields => fields):
            new Attributes(tag, type, [
                for (field in fields) 
                  {
                    field: field.name, 
                    expr: '_attrs.${field.name}'.resolve()
                  }
              ], 
              function (decl: Expr) 
                return macro {
                  var _attrs = $expr;
                  $decl;
                }
            );
          default:
            expr.reject('Attributes must be of type anonymous');
        }
    }
}