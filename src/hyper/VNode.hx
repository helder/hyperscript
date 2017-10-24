package hyper;

abstract Children(Array<VNode>) from Array<VNode> {

  @:from static inline function ofString(s: String): Children 
    return cast [s];

  @:from static inline function ofInt(i: Int): Children 
    return cast ofString(Std.string(i));

  #if js_virtual_dom
  @:from static inline function ofVNodes(vnodes: Array<vdom.VNode>): Children 
    return cast vnodes;
  #end

}

@:coreType abstract VNode {

  @:from static inline function ofString(s: String): VNode 
    return cast s;

  @:from static inline function ofInt(i: Int): VNode 
    return ofString(Std.string(i));

  @:to function toChildren(): Children
    return cast this;

  @:noCompletion @:from static public function flatten(c: Array<VNode>): VNode
    return cast c;

  #if js_virtual_dom
  @:from static inline function ofVNode(vnode: vdom.VNode): VNode 
    return cast vnode;
  #end

  #if coconut_ui
  @:to inline function toResult(): coconut.ui.RenderResult
    return cast this;

  @:from static inline function ofRenderable(renderable: coconut.ui.Renderable): VNode 
    return cast renderable;
  #end

}