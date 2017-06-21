package helder.vdom.libraries;

import helder.vdom.Hyperscript;
import helder.vdom.Selector;
import haxe.macro.Expr;
import haxe.DynamicAccess;

@:native('React') #if !no_require @:jsRequire('react') #end
extern class ReactExtern {
    public static function createElement(selector: Selector, attrs: Dynamic, children: Dynamic): Dynamic;
}

class React {

    static inline var HAXE_KEY_PREFIX = "@$__hx__";

    // Source: https://github.com/insin/babel-plugin-react-html-attrs/blob/master/lib/translations.js
    static var htmlAttrs = [
        'accesskey' => 'accessKey',
        'allowfullscreen' => 'allowFullScreen',
        'allowtransparency' => 'allowTransparency',
        'autocomplete' => 'autoComplete',
        'autofocus' => 'autoFocus',
        'autoplay' => 'autoPlay',
        'cellpadding' => 'cellPadding',
        'cellspacing' => 'cellSpacing',
        'charset' => 'charSet',
        'classid' => 'classID',
        'colspan' => 'colSpan',
        'contenteditable' => 'contentEditable',
        'contextmenu' => 'contextMenu',
        'crossorigin' => 'crossOrigin',
        'datetime' => 'dateTime',
        'enctype' => 'encType',
        'formaction' => 'formAction',
        'formenctype' => 'formEncType',
        'formmethod' => 'formMethod',
        'formnovalidate' => 'formNoValidate',
        'formtarget' => 'formTarget',
        'frameborder' => 'frameBorder',
        'hreflang' => 'hrefLang',
        'inputmode' => 'inputMode',
        'keyparams' => 'keyParams',
        'keytype' => 'keyType',
        'marginheight' => 'marginHeight',
        'marginwidth' => 'marginWidth',
        'maxlength' => 'maxLength',
        'mediagroup' => 'mediaGroup',
        'minlength' => 'minLength',
        'novalidate' => 'noValidate',
        'radiogroup' => 'radioGroup',
        'readonly' => 'readOnly',
        'rowspan' => 'rowSpan',
        'spellcheck' => 'spellCheck',
        'srcdoc' => 'srcDoc',
        'srclang' => 'srcLang',
        'srcset' => 'srcSet',
        'tabindex' => 'tabIndex',
        'usemap' => 'useMap',
        'autocapitalize' => 'autoCapitalize',
        'autocorrect' => 'autoCorrect',
        'autosave' => 'autoSave',
        'itemprop' => 'itemProp',
        'itemscope' => 'itemScope',
        'itemtype' => 'itemType',
        'itemref' => 'itemRef',
        'itemid' => 'itemID',
        'class' => 'className',
        'for' => 'htmlFor',
        'accept-charset' => 'acceptCharset',
        'http-equiv' => 'httpEquiv'
    ];

    // Source: https://facebook.github.io/react/docs/events.html
    static var events = '
        onCopy onCut onPaste
        onCompositionEnd onCompositionStart onCompositionUpdate
        onKeyDown onKeyPress onKeyUp
        onFocus onBlur
        onClick onContextMenu onDoubleClick onDrag onDragEnd onDragEnter onDragExit
        onDragLeave onDragOver onDragStart onDrop onMouseDown onMouseEnter onMouseLeave
        onMouseMove onMouseOut onMouseOver onMouseUp
        onSelect
        onTouchCancel onTouchEnd onTouchMove onTouchStart
        onScroll
        onWheel
        onAbort onCanPlay onCanPlayThrough onDurationChange onEmptied onEncrypted 
        onEnded onError onLoadedData onLoadedMetadata onLoadStart onPause onPlay 
        onPlaying onProgress onRateChange onSeeked onSeeking onStalled onSuspend 
        onTimeUpdate onVolumeChange onWaiting
        onLoad onError
        onAnimationStart onAnimationEnd onAnimationIteration
        onTransitionEnd
    '.split(' ')
    .filter(function(event) return event != '');

    static var eventAttrs = [
        for (event in events) 
            event.toLowerCase() => event
    ];

    public static function register()
        Hyperscript.register(hyperscript);

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr) {
        return macro helder.vdom.libraries.React.ReactExtern.createElement(
            $selector, 
            ${switch attrs.expr {
                case EConst(CIdent('null')) | EObjectDecl([]) | EBlock([]): attrs;
                case EObjectDecl(fields):
                    {expr: EObjectDecl([
                        for (field in fields) {
                            field: mapAttributeKey(field.field), 
                            expr: field.expr
                        }
                    ]), pos: attrs.pos}
                default: 
                    macro @:privateAccess helder.vdom.libraries.React.mapAttributes($attrs);
            }}, 
            $children
        );
    }

    static function mapAttributes(attrs: DynamicAccess<Any>) {
        var res: DynamicAccess<Any> = {};
        for (key in attrs.keys()) 
            res[mapAttributeKey(key)] = attrs[key];
        return res;
    }
    
    static function mapAttributeKey(name: String): String {
        #if macro
        if (name.substr(0, HAXE_KEY_PREFIX.length) == HAXE_KEY_PREFIX)
            name = name.substr(HAXE_KEY_PREFIX.length);
        #end
        if (htmlAttrs.exists(name)) 
            return htmlAttrs[name];
        if (name.substr(0, 2) == 'on') {
            var key = name.toLowerCase();
            if (eventAttrs.exists(key))
                return return eventAttrs[key]; 
        }
        return name;
    }

}