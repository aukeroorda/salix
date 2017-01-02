module salix::demo::ListDemo

import salix::HTML;
import salix::App;
import salix::lib::EditableList;

//App[ListModel[str]] listApp() 
// generics and functions...
App[tuple[list[value],str(Msg, str), str(int)]] listApp() 
  = app(<["hello", "world!"], editStr, initStr>, view, editList, 
        |http://localhost:9200|, |project://salix/src|); 

data Msg
  = changeText(str x)
  ;

str initStr(int i) = "Edit string <i>";

str editStr(changeText(str x), str _) = x;

void view(ListModel[str] m) {
  div(() {
    h2("Editable list demo");
    listView(m, strView);
  });
}

void strView(str x) {
  input(\type("text"), \value(x), onInput(changeText));
}

