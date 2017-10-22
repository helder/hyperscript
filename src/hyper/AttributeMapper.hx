package coconut.hyperscript;

import haxe.DynamicAccess;
import haxe.macro.Expr;

class AttributeMapper {

    static inline var HAXE_KEY_PREFIX = "@$__hx__";
    
    public static function map(attrs: Expr, map: Map<String, String>, runtimeMap: Expr) {
        return switch attrs.expr {
            case EConst(CIdent('null')) | EObjectDecl([]) | EBlock([]): attrs;
            case EObjectDecl(fields):
                {expr: EObjectDecl([
                    for (field in fields) {
                        field: mapKey(map, field.field), 
                        expr: field.expr
                    }
                ]), pos: attrs.pos}
            default: 
                // Todo: We can check attrs expr type first and create an objectdecl based on that
                macro @:privateAccess coconut.hyperscript.AttributeMapper.mapRuntime($runtimeMap, $attrs);
        }
    }

    static function mapRuntime(map: Map<String, String>, attrs: DynamicAccess<Any>) {
        var res: DynamicAccess<Any> = {};
        for (key in attrs.keys())
            res[mapKey(map, key)] = attrs[key];
        return res;
    }

    static function mapKey(map: Map<String, String>, key: String): String {
        #if macro
        if (key.substr(0, HAXE_KEY_PREFIX.length) == HAXE_KEY_PREFIX)
            key = key.substr(HAXE_KEY_PREFIX.length);
        #end
        return 
            if (map.exists(key)) map[key]
            else key;
    }

}