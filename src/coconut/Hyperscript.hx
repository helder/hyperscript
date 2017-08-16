package coconut;

import tink.csss.Selector;
import tink.csss.Parser;
import haxe.DynamicAccess;
import haxe.macro.Expr;
#if macro
import haxe.macro.Context;
#end

typedef SelectorData = {
    tag: String,
    id: Null<String>,
    classes: Array<String>,
    attrs: Attrs
}

typedef Attr = {
    field: String,
    expr: Expr
}

typedef Attrs = DynamicAccess<String>;

typedef HyperscriptImpl = 
    // (selector: Expr, attrs: Expr, children: Expr) -> Expr
    Expr -> Expr -> Expr -> Expr;

class Hyperscript {

    static var impl: HyperscriptImpl = noImplementation;

    static function noImplementation(selector: Expr, attrs: Expr, children: Expr): Expr
        throw 'No implementation set';

    public static function register(library: HyperscriptImpl)
        impl = library;

    macro public static function h(selector: Expr, ?attrs: Expr, ?children: Expr) {
        function isNull(e: Expr)
            return e.expr.equals(EConst(CIdent('null')));

        if (isNull(children) && !isNull(attrs)) {
            // Figure out if attrs are actually children
            switch attrs.expr {
                case EObjectDecl(_):
                default:
                    switch Context.followWithAbstracts(Context.typeof(attrs)) {
                        case TAnonymous(_):
                        default:
                            children = attrs;
                            attrs = macro @:pos(attrs.pos) null;
                    }
            }
        }

        return switch selector.expr {
            case EConst(CString(source)):
                var selector = parseSelector(source);
                switch attrs.expr {
                    case EConst(CIdent('null')) | EObjectDecl([]) | EBlock([]):
                        var fields = [
                            for (attr in selector.attrs.keys())
                                {field: attr, expr: macro @:pos(attrs.pos) $v{selector.attrs[attr]}}
                        ];
                        if (selector.id != null) 
                            fields.push({field: 'id', expr: macro @:pos(attrs.pos) $v{selector.id}});
                        if (selector.classes.length > 0)
                            fields.push({field: 'class', expr: macro @:pos(attrs.pos) $v{selector.classes.join(' ')}});
                        var obj = {expr: EObjectDecl(fields), pos: attrs.pos}
                        impl(macro @:pos(attrs.pos) $v{selector.tag}, obj, children);
                    case EObjectDecl(fields):
                        var names = [];
                        for (field in fields) switch field.field {
                            case 'class': {
                                field: 'class', 
                                expr: macro ${field.expr} + ' ' + $v{selector.classes.join(' ')}
                            }
                            case name: names.push(name);
                        }
                        function hasField(name) return names.indexOf(name) > -1;
                        if (selector.classes.length > 0 && !hasField('class')) 
                            fields.push({field: 'class', expr: macro @:pos(attrs.pos) $v{selector.classes.join(' ')}});
                        if (selector.id != null && !hasField('id')) 
                            fields.push({field: 'id', expr: macro @:pos(attrs.pos) $v{selector.id}});
                        for (attr in selector.attrs.keys())
                            if (!hasField(attr))
                                fields.push({field: attr, expr: macro @:pos(attrs.pos) $v{selector.attrs[attr]}});
                        var obj = {expr: EObjectDecl(fields), pos: attrs.pos}
                        impl(macro @:pos(attrs.pos) $v{selector.tag}, obj, children);
                    default:
                        var attrs = macro @:pos(attrs.pos) @:privateAccess coconut.Hyperscript.merge($v{selector}, cast $attrs);
                        impl(macro @:pos(attrs.pos) $v{selector.tag}, attrs, children);
                }
            case EConst(CIdent(component)):
                impl(selector, attrs, children);
            default:
                macro @:privateAccess {
                    var selector = coconut.Hyperscript.parseSelector($selector),
                        attrs = coconut.Hyperscript.merge(selector, $attrs);
                    ${impl(macro selector, macro attrs, children)}
                }
        }
    }

    static function merge(selector: SelectorData, attrs: DynamicAccess<Any>) {
        if (!attrs.exists('id')) attrs['id'] = selector.id;
        var classes = selector.classes;
        if (attrs.exists('class')) classes = classes.concat((attrs['class']: String).split(' '));
        attrs['class'] = classes.join(' ');
        for (attr in selector.attrs.keys())
            if (!attrs.exists(attr)) 
                attrs[attr] = selector.attrs[attr];
        return attrs;
    }

    static function parseSelector(source: String): SelectorData {
        var selector: SelectorData = {
            tag: 'div', id: null, 
            classes: [], attrs: {}
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
                        case Exactly: selector.attrs[attr.name] = attr.value;
                        case None if (attr.value == null): selector.attrs[attr.name] = 'true';
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