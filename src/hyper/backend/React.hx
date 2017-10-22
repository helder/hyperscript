package coconut.hyperscript.impl;

import coconut.Hyperscript;
import coconut.hyperscript.AttributeMapper;
import haxe.macro.Expr;

#if !macro
import coconut.hyperscript.Selector;
@:native('React') #if !no_require @:jsRequire('react') #end
extern class ReactExtern {
    public static function createElement<Attrs>(selector: Selector<Attrs>, attrs: Attrs, children: Dynamic): Dynamic;
}
#end

class React {

    // Source: https://github.com/insin/babel-plugin-react-html-attrs/blob/master/lib/translations.js
    // Source: https://facebook.github.io/react/docs/events.html
    public static var attrMap = [
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
        'http-equiv' => 'httpEquiv',
        'oninput' => 'onChange',
        'onchange' => 'onChange',
        'oncopy' => 'onCopy',
        'oncut' => 'onCut',
        'onpaste' => 'onPaste',
        'oncompositionend' => 'onCompositionEnd',
        'oncompositionstart' => 'onCompositionStart',
        'oncompositionupdate' => 'onCompositionUpdate',
        'onkeydown' => 'onKeyDown',
        'onkeypress' => 'onKeyPress',
        'onkeyup' => 'onKeyUp',
        'onfocus' => 'onFocus',
        'onblur' => 'onBlur',
        'onclick' => 'onClick',
        'oncontextmenu' => 'onContextMenu',
        'ondoubleclick' => 'onDoubleClick',
        'ondrag' => 'onDrag',
        'ondragend' => 'onDragEnd',
        'ondragenter' => 'onDragEnter',
        'ondragexit' => 'onDragExit',
        'ondragleave' => 'onDragLeave',
        'ondragover' => 'onDragOver',
        'ondragstart' => 'onDragStart',
        'ondrop' => 'onDrop',
        'onmousedown' => 'onMouseDown',
        'onmouseenter' => 'onMouseEnter',
        'onmouseleave' => 'onMouseLeave',
        'onmousemove' => 'onMouseMove',
        'onmouseout' => 'onMouseOut',
        'onmouseover' => 'onMouseOver',
        'onmouseup' => 'onMouseUp',
        'onselect' => 'onSelect',
        'ontouchcancel' => 'onTouchCancel',
        'ontouchend' => 'onTouchEnd',
        'ontouchmove' => 'onTouchMove',
        'ontouchstart' => 'onTouchStart',
        'onscroll' => 'onScroll',
        'onwheel' => 'onWheel',
        'onabort' => 'onAbort',
        'oncanplay' => 'onCanPlay',
        'oncanplaythrough' => 'onCanPlayThrough',
        'ondurationchange' => 'onDurationChange',
        'onemptied' => 'onEmptied',
        'onencrypted' => 'onEncrypted',
        'onended' => 'onEnded',
        'onloadeddata' => 'onLoadedData',
        'onloadedmetadata' => 'onLoadedMetadata',
        'onloadstart' => 'onLoadStart',
        'onpause' => 'onPause',
        'onplay' => 'onPlay',
        'onplaying' => 'onPlaying',
        'onprogress' => 'onProgress',
        'onratechange' => 'onRateChange',
        'onseeked' => 'onSeeked',
        'onseeking' => 'onSeeking',
        'onstalled' => 'onStalled',
        'onsuspend' => 'onSuspend',
        'ontimeupdate' => 'onTimeUpdate',
        'onvolumechange' => 'onVolumeChange',
        'onwaiting' => 'onWaiting',
        'onload' => 'onLoad',
        'onerror' => 'onError',
        'onanimationstart' => 'onAnimationStart',
        'onanimationend' => 'onAnimationEnd',
        'onanimationiteration' => 'onAnimationIteration',
        'ontransitionend' => 'onTransitionEnd'
    ];

    public static function register()
        Hyperscript.register(hyperscript);

    static function hyperscript(selector: Expr, attrs: Expr, children: Expr) {
        return macro coconut.hyperscript.libraries.React.ReactExtern.createElement(
            $selector, 
            ${AttributeMapper.map(attrs, attrMap, macro coconut.hyperscript.libraries.React.attrMap)},
            $children
        );
    }

}