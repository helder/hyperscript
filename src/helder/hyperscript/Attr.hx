package helder.hyperscript;

abstract Ext(String) from String to String {  
  @:from static inline function ofInt(i:Int):Ext
    return cast i;
  
  @:from static inline function ofFloat(f:Float):Ext
    return cast f;
  
  @:from static inline function ofBool(b:Bool):Ext
    return if (b) '' else js.Lib.undefined;
}

abstract Key(Dynamic) from String from Int from Float from Bool {
  static var keygen = 0;

  @:from static function ofObj<T:{}>(v:T):Key {
    if (v == null) return null;
    var o: { __vdomKey__:Key } = cast v;
    if (o.__vdomKey__ == null) o.__vdomKey__ = keygen++;
    return o.__vdomKey__;
  }

  @:from static function ofAny<T>(v:T):Key 
    return switch Type.typeof(v) {
      case TInt, TFloat, TBool, TClass(String): cast v;
      case TClass(Array): (cast v : Array<Dynamic>).join(':');
      default: ofObj(cast v);
    }
}