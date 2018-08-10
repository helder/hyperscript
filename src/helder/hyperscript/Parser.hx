package helder.hyperscript;

import haxe.macro.Expr;
import tink.csss.Parser in SelectorParser;
import haxe.macro.Type;
import helder.hyperscript.Attributes;

using haxe.macro.Context;
using tink.MacroApi;

enum HyperscriptCall {
  Element(tag: String, attributes: Attributes, children: Array<Expr>);
  Component(component: Expr, props: Expr, children: Array<Expr>);
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
              params: [TPType(elementType(field).toComplex())]
            }
          ], [{
            name: 'attributes', 
            kind: FVar((macro: haxe.DynamicAccess<String>)),
            pos: Context.currentPos()
          }]).toType().sure(),
          hasChildren: kind.name == 'normal' // Todo: fix opaque
        }
  ];

  static function elementType(field) 
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

  public function new() {}

  public function parse(selector: Expr, extra: Array<Expr>) {
    var parsedExtra = getAttrsAndChildren(extra);
    var attrs = parsedExtra.attrs;
    var children = parsedExtra.children;
    return switch selector {
      case {expr: EConst(CString(source)), pos: pos}:
        var parsed = parseSelector(source, selector);
        if (parsed.tag.indexOf('-') > 0) throw 'todo: custom elements';
        if (!dom.exists(parsed.tag)) 
          selector.reject('Not a valid html element: $source');
        var element = dom[parsed.tag];
        if (!element.hasChildren) 
          switch children {
            case null | []:
            default:
              children[0]
                .reject('Element "${parsed.tag}" cannot contain children');
          }
        var attributes = Attributes.ofExpr(parsed.tag, element.type, attrs);
        if (parsed.id != null) 
          attributes.set('id', macro @:pos(selector.pos) $v{parsed.id});
        if (parsed.classes.length > 0)
          attributes.addClasses(parsed.classes);
        for (key in parsed.attrs.keys())
          attributes.set(key, parsed.attrs[key]);
        Element(parsed.tag, attributes, children);
      default:
        var type = Context.getType(selector.toString());
        // Todo: typecheck props etc
        Component(selector, attrs, children);
    }
  }
  
  function getAttrsAndChildren(extra: Array<Expr>) {
    return switch extra {
      case null | []:
        {attrs: macro null, children: []}
      case [attrs]:
        if (isAttrs(attrs)) {attrs: attrs, children: []}
        else {attrs: macro null, children: [attrs]}
      default:
        {attrs: extra[0], children: extra.slice(1)}
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

  function parseSelector(source: String, expr: Expr): Selector {
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
            case Exactly: 
              selector.attrs[attr.name] = macro @:pos(expr.pos) $v{attr.value};
            case None if (attr.value == null): 
              selector.attrs[attr.name] = macro @:pos(expr.pos) true;
            default: expr.reject('Unsupported attribute in selector');
          }
          selector;
        case []: selector;
        default: expr.reject('Single selector expected');
      }
      case Failure(error): throw error;
    }
  }
}