package helder.hyperscript;

abstract Children(Array<VNode>) from Array<VNode> {

  @:from static inline function ofString(s: String): Children 
    return cast [s];

  @:from static inline function ofInt(i: Int): Children 
    return cast ofString(Std.string(i));

}

@:coreType abstract VNode {

  @:from static inline function ofString(s: String): VNode 
    return cast s;

  @:from static inline function ofInt(i: Int): VNode 
    return ofString(Std.string(i));

  @:to inline function toChildren(): Children
    return cast this;

}