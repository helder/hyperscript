package helder.hyperscript;

abstract Ext(String) from String to String {  
  @:from static inline function ofInt(i:Int):Ext
    return cast i;
  
  @:from static inline function ofFloat(f:Float):Ext
    return cast f;
  
  @:from static inline function ofBool(b:Bool):Ext
    return if (b) '' else js.Lib.undefined;
}