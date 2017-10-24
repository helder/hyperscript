import js.Browser.*;
import todomvc.data.*;
import todomvc.ui.*;

class TodoMvc {
  static function main() {

    document.body.appendChild(
      h(TodoListView, {
        filter: new TodoFilter(),
        todos: new TodoList()
      }).toElement()
    );
  }
}