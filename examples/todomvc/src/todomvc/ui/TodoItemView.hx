package todomvc.ui;

import todomvc.data.TodoItem;
import coconut.ui.*;

using StringTools;

@:less("item.less")
class TodoItemView extends View<{ item: TodoItem, ondeleted: TodoItem->Void }> {
  
  @:state var isEditing:Bool = false;

  function render(): RenderResult {
    function edit(entered:String)
      switch entered.rtrim() {
        case '': ondeleted(item);
        case v: item.description = v;
      }

    return h('li.todo-item', {'data-completed': item.completed, 'data-editing': isEditing}, [
      h('input[name=completed][type=checkbox]', {
        checked: item.completed, 
        onchange: e -> item.completed = e.target.checked
      }),
      if (isEditing) [
        h('input[name=description][type=text]', {
          value: item.description,
          onchange: e -> edit(e.target.value),
          onblur: e -> isEditing = false
        })
      ] else [
        h('span.description', {
          ondblclick: e -> this.isEditing = true
        }, item.description),
        h('button.delete', {
          onclick: e -> ondeleted(item)
        }, 'Delete')
      ]
    ]);
  }

  override function afterPatching(_) 
    if (isEditing)
      get('input[type="text"]').focus();
  
}