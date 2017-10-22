package hyper.macro;

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

  static var backend = new hyper.Backend();

  static var dom = switch Context.follow(Context.getType('hyper.Elements')) {
    case TAnonymous(_.get().fields => fields):
      [for (field in fields) field.name => {
        type: field.type,
        hasChildren: !field.meta.has(':noChildren')
      }];
    default: throw 'assert';
  }
  
  static function getAttr(expr: Expr, merge: Array<{name: String, expr: Expr}>, type: Type): Attributes {
    return switch expr.expr {
      case EObjectDecl(fields):
        new Attributes([for (field in fields) {
          name: field.field, expr: field.expr
        }].concat(merge), type);
      case EBlock([]) | EConst(CIdent('null')):
        new Attributes([], type);
      default: switch Context.followWithAbstracts(Context.typeof(expr)) {
        case TAnonymous(_.get().fields => fields):
          new Attributes([for (field in fields) {
            name: field.name, expr: '_attrs.${field.name}'.resolve()
          }].concat(merge), type, macro var _attrs = $expr);
        default: throw 'assert';
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
          default: try {
            Context.typeof(macro ($attrs: hyper.VNode.Children));
            true;
          } catch(e: Dynamic) {
            false;
          }
        }
      else false;
  }

  public static function call(selectorE: Expr, ?attrsE: Expr, ?childrenE: Expr): Expr {
    if (switchAttrsChildren(attrsE, childrenE)) {
      childrenE = attrsE;
      attrsE = macro {};
    }
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
        if (!element.hasChildren) switch childrenE.expr {
          case EConst(CIdent('null')):
          default: childrenE.reject('Element ${selector.tag} cannot contain children');
        }
        return backend.createElement(selector.tag, attrs, 
          if (element.hasChildren) macro @:pos(childrenE.pos) ($childrenE: hyper.VNode.Children)
          else macro null
        );
      default: 
        trace(selectorE);
        throw 'todo';
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
            default: throw 'Unsupported operation';
          }
          selector;
        case []: selector;
        default: throw 'Single selector expected';
      }
      case Failure(error): throw error;
    }
  }

}