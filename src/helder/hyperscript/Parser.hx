package helder.hyperscript;

import haxe.macro.Expr;
import tink.csss.Parser in SelectorParser;
using haxe.macro.Context;
using tink.MacroApi;

typedef Attributes = Dynamic;

enum HyperscriptCall {
  Element(tag: String, attributes: Attributes, children: Expr);
  Component(component: Expr, props: Expr, children: Expr);
}

typedef Selector = {
  tag: String,
  id: Null<String>,
  classes: Array<String>,
  attrs: Map<String, Expr>
}

class Parser {
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

  public function new() {}

  public function parse(selector: Expr, ?attrs: Expr, ?children: Array<Expr>) {
    if (children == null) children = [];
    if (attrs == null) attrs = macro null;
    else if (!isAttrs(attrs)) children.unshift(attrs);
    return switch selector {
      case {expr: EConst(CString(source)), pos: pos}:
        var selector = parseSelector(source, pos);
        if (selector.tag.indexOf('-') > 0) throw 'todo: custom elements';
        if (!dom.exists(selector.tag)) selectorE.reject('Not a valid html element: $source');

      default: 
        var type = Context.getType(selectorE.toString());
        // Todo: typecheck props
        Component(selector, attrs, children);
    }
  }

  function isAttrs(e: Expr)
    return switch e.expr {
      case EObjectDecl(_): true;
      case EArrayDecl(_): false;
      default:
        switch e.typeof().sure().followWithAbstracts() {
          case TAnonymous(_): true;
          default: false;
        }
    }

  function isNull(e: Expr) 
    return switch e {
      case macro null: true;
      default: false;
    }

  function parseSelector(source: String, pos: Position): Selector {
    var selector: Selector = {
      tag: 'div', id: null, 
      classes: [], attrs: new Map()
    }
    if (source == '') return selector;
    return switch SelectorParser.parse(source) {
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

  function elementType(field) 
    return switch field.type {
      case TType(_.get() => {module: 'tink.domspec.Attributes', name: name}, _): 
        var html = 'js.html.' + (switch name.split('Attr') {
          case ['Global', '']: '';
          case [name, '']: name;
          default: throw 'assert';
        }) + 'Element';
        var ct = html.asComplexType();
        (macro @:pos(field.pos) (null: $ct)).typeof().sure();
      default: throw 'assert';
    }
}