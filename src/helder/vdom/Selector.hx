package helder.vdom;

import haxe.extern.EitherType;

typedef Selector<Attrs> = EitherType<String, Class<Dynamic>>;