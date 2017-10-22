package hyper;

// Source: https://github.com/back2dos/js-virtual-dom/blob/master/src/vdom/VDom.hx

import hyper.Attr;
import js.html.*;
import js.Browser;

typedef Elements = {
  var iframe: IframeAttr;
  var object: ObjectAttr;
  @:noChildren var param: ParamAttr;

  var div: EditableAttr;
  var aside: EditableAttr;
  var section: EditableAttr;

  var header: EditableAttr;
  var footer: EditableAttr;
  var main: EditableAttr;
  var nav: EditableAttr;

  var table: EditableAttr;
  var thead: EditableAttr;
  var tbody: EditableAttr;
  var tfoot: EditableAttr;
  var tr: EditableAttr;
  var td: TableCellAttr;
  var th: TableCellAttr;

  var h1: EditableAttr;
  var h2: EditableAttr;
  var h3: EditableAttr;
  var h4: EditableAttr;
  var h5: EditableAttr;

  var strong: EditableAttr;
  var em: EditableAttr;
  var span: EditableAttr;
  var a: AnchorAttr;

  var p: EditableAttr;
  var i: EditableAttr;
  var b: EditableAttr;
  var small: EditableAttr;
  var menu: EditableAttr;
  var ul: EditableAttr;
  var ol: EditableAttr;
  var li: EditableAttr;
  var label: LabelAttr;
  var button: InputAttr;
  var textarea: TextAreaAttr;

  var pre: EditableAttr;

  @:noChildren var hr: Attr;
  @:noChildren var br: Attr;
  @:noChildren var wbr: Attr;

  @:noChildren var canvas: CanvasAttr;
  @:noChildren var img: ImgAttr;
  var audio: AudioAttr;
  var video: VideoAttr;
  var source: SourceAttr;
  @:noChildren var input: InputAttr;
  var form: FormAttr;

  var select: SelectAttr;
  var option: OptionAttr;
}

typedef ObjectAttr = {>Attr, 
  @:optional var type(default, never): String;
  @:optional var data(default, never): String;
}

typedef ParamAttr = {>Attr, 
  @:optional var name(default, never): String;
  @:optional var value(default, never): String;
}

typedef CanvasAttr = {>Attr,
  @:optional var width(default, never):String;
  @:optional var height(default, never):String;
}

typedef EditableAttr = {>Attr,
  @:optional var contentEditable(default, never):Bool;
}

typedef FormAttr = {>AttrOf<FormElement>,
  @:optional var method(default, never):String;
  @:optional var action(default, never):String;
}

typedef AnchorAttr = {> AttrOf<AnchorElement>,
  @:optional var href(default, never):String;
  @:optional var target(default, never):String;
  @:optional var type(default, never):String;
}

typedef TableCellAttr = {> Attr,
  @:optional var abbr(default, never):String;
  @:optional var colSpan(default, never):Int;
  @:optional var headers(default, never):String;
  @:optional var rowSpan(default, never):Int;
  @:optional var scope(default, never):String;
  @:optional var sorted(default, never):String;
}

typedef InputAttr = {> AttrOf<InputElement>,
  @:optional var checked(default, never):Bool;
  @:optional var disabled(default, never):Bool;
  @:optional var required(default, never):Bool;
  @:optional var value(default, never):String;
  @:optional var type(default, never):String;
  @:optional var name(default, never):String;
  @:optional var placeholder(default, never):String;
  @:optional var max(default, never):String;
  @:optional var min(default, never):String;
  @:optional var step(default, never):String;
  @:optional var maxlength(default, never):Int;
}

typedef TextAreaAttr = {> AttrOf<TextAreaElement>,
  @:optional var autofocus(default, never):Bool;
  @:optional var cols(default, never):Int;
  @:optional var dirname(default, never):String;
  @:optional var disabled(default, never):Bool;
  @:optional var form(default, never):String;
  @:optional var maxlength(default, never):Int;
  @:optional var name(default, never):String;
  @:optional var placeholder(default, never):String;
  @:optional var readonly(default, never):Bool;
  @:optional var required(default, never):Bool;
  @:optional var rows(default, never):Int;
  @:optional var wrap(default, never):String;
}

typedef IframeAttr = {> AttrOf<IFrameElement>,
  @:optional var sandbox(default, never):String; 
  @:optional var width(default, never):Int; 
  @:optional var height(default, never):Int; 
  @:optional var src(default, never):String; 
  @:optional var srcdoc(default, never):String; 
  @:optional var allowFullscreen(default, never):Bool;
  @:deprecated @:optional var scrolling(default, never):IframeScrolling;
}

@:enum abstract IframeScrolling(String) {
  var Yes = "yes";
  var No = "no";
  var Auto = "auto";
}

typedef ImgAttr = {> AttrOf<ImageElement>,
  @:optional var src(default, never):String;
  @:optional var width(default, never):Int;
  @:optional var height(default, never):Int;
}

typedef AudioAttr = {> AttrOf<AudioElement>,
  @:optional var src(default, never):String;
  @:optional var autoplay(default, never):Bool;
  @:optional var controls(default, never):Bool;
  @:optional var loop(default, never):Bool;
  @:optional var muted(default, never):Bool;
  @:optional var preload(default, never):String;
}

typedef VideoAttr = {> AttrOf<VideoElement>,
  @:optional var src(default, never):String;
  @:optional var autoplay(default, never):Bool;
  @:optional var controls(default, never):Bool;
}

typedef SourceAttr = {> AttrOf<SourceElement>,
  @:optional var src(default, never):String;
  @:optional var srcset(default, never):String;
  @:optional var media(default, never):String;
  @:optional var sizes(default, never):String;
  @:optional var type(default, never):String;
}

typedef LabelAttr = {> AttrOf<LabelElement>,
  @:optional var htmlFor(default, never):String;
}

typedef SelectAttr = {> AttrOf<SelectElement>,
  @:optional var autofocus(default, never):Bool;
  @:optional var disabled(default, never):Bool;
  @:optional var form(default, never):FormElement;
  @:optional var multiple(default, never):Bool;
  @:optional var name(default, never):String;
  @:optional var required(default, never):Bool;
  @:optional var size(default, never):Int;
}

typedef OptionAttr = {> AttrOf<OptionElement>,
  @:optional var disabled:Bool;
  @:optional var form(default, never):FormElement;
  @:optional var label(default, never):String;
  @:optional var defaultSelected(default, never):Bool;
  @:optional var selected(default, never):Bool;
  @:optional var value(default, never):String;
  @:optional var text(default, never):String;
  @:optional var index(default, never):Int;
}