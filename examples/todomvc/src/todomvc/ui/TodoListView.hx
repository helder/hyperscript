package todomvc.ui;

import js.html.KeyboardEvent;
import todomvc.data.*;
import coconut.ui.*;

@:less("list.less")
class TodoListView extends View<{todos:TodoList, filter:TodoFilter}> {
  function render(): RenderResult
    return h('.todo-list', {'data-empty': todos.items.length == 0}, [
      h('h1', 'todos'),
      h('header', [
        h('input[type=text][autofocus]', {
          placeholder: 'What needs to be done?',
          onkeypress: function (e) {
            if (e.keyCode != KeyboardEvent.DOM_VK_RETURN || e.currentTarget.value == '') return;
            todos.add(e.currentTarget.value); 
            e.currentTarget.value = '';
          }
        }),
        if (todos.items.length > 0)
          if (todos.items.exists(TodoItem.isActive))
            h('button.mark-all', {onclick: e -> for (i in todos.items) i.completed = true}, 'Mark all as completed')
          else
            h('button.unmark-all', {onclick: e -> for (i in todos.items) i.completed = false}, 'Unmark all as completed')
      ]),
      if (todos.items.length > 0) [
        h('ol', [
          for (item in todos.items)
            if (filter.matches(item))
              h(TodoItemView, {
                item: item, ondeleted: item -> todos.delete(item)
              })
        ]),
        h('footer', [
          h('span', switch todos.items.count(TodoItem.isActive) {
            case 1: '1 item';
            case v: '$v items';
          }),
          h('menu', [
            for (f in filter.options)
              h('button', {onclick: e -> filter.toggle(f.value), 'data-active': filter.isActive(f.value)}, f.name)
          ]),
          if (todos.items.exists(TodoItem.isCompleted))
            h('button', {onclick: todos.clearCompleted}, 'Clear Completed')
        ])
      ]
    ]);
}