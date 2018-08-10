package helder;

class Component<Attrs: {}> {
  var attrs: Attrs;
  var children: Dynamic;
  #if js
  var dom: js.html.Element;
  #end
}