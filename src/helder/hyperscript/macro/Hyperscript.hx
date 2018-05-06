package helder.hyperscript.macro;

import tink.csss.Parser;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.TypeTools;

using tink.MacroApi;

typedef SelectorData = {
    tag: String,
    id: Null<String>,
    classes: Array<String>,
    attrs: Map<String, Expr>
}

class Hyperscript {

  public static var backend: Backend = 
    #if js_virtual_dom
      #if coconut_ui new helder.hyperscript.backend.coconut.VirtualDom()
      #else new helder.hyperscript.backend.VirtualDom() #end
    #else null #end;

  static function tagType(field) return switch field.type {
    case TType(_.get() => { module: 'tink.domspec.Attributes', name: name }, _): 
      var html = 'js.html.' + (switch name.split('Attr') {
        case ['Global', '']: '';
        case [name, '']: name;
        default: throw 'assert';
      }) + 'Element';
      var ct = html.asComplexType();
      (macro @:pos(field.pos) (null:$ct)).typeof().sure();
    default: throw 'assert';
  }

  static var dom = [
    for (kind in Context.getType('tink.domspec.Tags').getFields().sure())
      for (field in kind.type.getFields().sure())
        field.name => {
          type: TExtend([
            field.type.toComplex().toString().asTypePath(),
            {
              pack: ['tink', 'domspec'],
              name: 'Events',
              params: [TPType(tagType(field).toComplex())]
            }
          ], [{
            name: 'attributes', 
            kind: FVar((macro: haxe.DynamicAccess<String>)),
            pos: Context.currentPos()
          }]).toType().sure(),
          hasChildren: kind.name == 'normal' // Todo: fix opaque
        }
  ];
  
  static function getAttr(expr: Expr, merge: Array<{name: String, expr: Expr}>, type: Type): Attributes {
    return switch expr.expr {
      case EObjectDecl(fields):
        new Attributes([for (field in fields) {
          name: field.field, expr: field.expr
        }].concat(merge), type);
      case EBlock([]) | EConst(CIdent('null')):
        new Attributes(merge, type);
      default: switch Context.followWithAbstracts(Context.typeof(expr)) {
        case TAnonymous(_.get().fields => fields):
          new Attributes([for (field in fields) {
            name: field.name, expr: '_attrs.${field.name}'.resolve()
          }].concat(merge), type, macro var _attrs = $expr);
        default: expr.reject('Attributes must be of type anonymous');
      }
    }
  }

  // Figure out if attrs are actually children
  static function switchAttrsChildren(attrs: Expr, children: Expr) {
    function isNull(e: Expr) return e.expr.equals(EConst(CIdent('null')));
    return 
      if (!isNull(attrs) && isNull(children))
        switch attrs.expr {
          case EObjectDecl(_): false;
          case EArrayDecl(_): true;
          default:
            switch Context.followWithAbstracts(Context.typeof(attrs)) {
              case TAnonymous(_): false;
              default: true;
            }
        }
      else false;
  }

  public static function call(selectorE: Expr, ?attrsE: Expr, ?childrenE: Expr): Expr {
    if (switchAttrsChildren(attrsE, childrenE)) {
      childrenE = attrsE;
      attrsE = macro {};
    }
    processChildren(childrenE);
    return switch selectorE.expr {
      case EConst(CString(source)):
        var selector = parseSelector(source, selectorE.pos);
        if (selector.tag.indexOf('-') > 0) throw 'todo: custom elements';
        if (!dom.exists(selector.tag)) selectorE.reject('Not a valid html element: $source');
        var element = dom[selector.tag], type = element.type;
        var merge = [for (attr in selector.attrs.keys()) {
          name: attr, expr: selector.attrs[attr]
        }];
        if (selector.id != null) merge.push({
          name: 'id', expr: macro $v{selector.id}
        });
        var attrs = getAttr(attrsE, merge, type);
        if (selector.classes.length > 0)
          attrs.addClasses(selector.classes);
        if (!element.hasChildren) switch childrenE {
          case macro null:
          default: childrenE.reject('Element ${selector.tag} cannot contain children');
        }
        return backend.createElement(selector.tag, attrs, 
          if (element.hasChildren) switch childrenE {
            case macro null: Some(childrenE);
            default: Some(macro @:pos(childrenE.pos) ($childrenE: helder.hyperscript.VNode.Children));
          } else None
        );
      default: 
        var type = Context.getType(selectorE.toString());
        return backend.createComponent(type, attrsE, childrenE);
    }
  }

  static function processChildren(children: Expr) {
    function process(expr: Expr) return switch expr {
      case macro for ($e1) $e2: macro ([for($e1) $e2]: helder.hyperscript.VNode);
      case macro if ($e1) $e2: macro (if($e1) $e2 else null: helder.hyperscript.VNode);
      default: macro ($expr: helder.hyperscript.VNode);
    }
    switch children.expr {
      case EArrayDecl(values): 
        children.expr = EArrayDecl(values.map(process));
        //values.map(process);
      default: // process(children);
    }
  }

  static function parseSelector(source: String, pos: Position): SelectorData {
    var selector: SelectorData = {
      tag: 'div', id: null, 
      classes: [], attrs: new Map()
    }
    if (source == '') return selector;
    return switch Parser.parse(source) {
      case Success(options): switch options {
        case [[_ => {
          id: id, tag: tag, 
          classes: classes, attrs: attrs
        }]]:
          selector.id = id;
          if (tag != null) selector.tag = tag;
          selector.classes = classes;
          for (attr in attrs) switch attr.operator {
            case Exactly: selector.attrs[attr.name] = macro @:pos(pos) $v{attr.value};
            case None if (attr.value == null): selector.attrs[attr.name] = macro @:pos(pos) true;
            default: throw 'Unsupported operation at $pos';
          }
          selector;
        case []: selector;
        default: throw 'Single selector expected at $pos';
      }
      case Failure(error): throw error;
    }
  }

}