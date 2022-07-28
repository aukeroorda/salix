module salix::demo::lsp::Demo

import salix::App;
import salix::HTML;
import salix::Node;
import salix::Core;

import salix::lib::Mode;
import salix::lib::CodeMirror;

import util::Maybe;
import List;
import String;
import IO;
import ParseTree;

// Language
import salix::demo::lsp::QL;


SalixApp[LspModel] lspApp(str id = "lspDemo") = makeApp(id, lspInit, lspView, lspUpdate, parser = parseMsg);

App[LspModel] lspWepApp()
    = webApp(
        lspApp(),
        |project://salix/src/salix/demo/lsp/index.html|,
        |project://salix/src|
    );

alias LspModel = tuple[
    str src,
    Mode mode
];

LspModel lspInit() {
    Mode languageMode = grammar2mode("ql", #Form);
    LspModel model = <"Initialized model", languageMode>;

    return model;
}

data Msg
    = textChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed);

LspModel lspUpdate(Msg msg, LspModel model) {

    // Autocomplete suggestions
    // list[str] myAutoComplete(str prefix) = ...

    switch(msg) {
        case textChange(int fromLine, int fromCol, int toLine, int toCol, str text, str removed): {
            model.src = updateSrc(model.src, fromLine, fromCol, toLine, toCol, text, removed);
        }
    }

    return model;
}

// list[str] byLine(str sep, str text) {
//     if (/^<before:.*?><sep>/m := s) {
//         return [before] + byLine(sep, s[size(before) + size(sep)..]);
//     }

//     return [s];
// }
list[str] mySplit(str sep, str s) {
  if (/^<before:.*?><sep>/m := s) {
    return [before] + mySplit(sep, s[size(before) + size(sep)..]);
  }
  return [s];
}

str updateSrc(str src, int fromLine, int toLine, int fromCol, int toCol, str text, str removed) {
    list[str] lines = mySplit("\n", src);
    int from = ( 0 | it + size(l) + 1 | str l <- lines[..fromLine] ) + fromCol;
    int to = from + size(removed);

    str newsrc = src[..from] + text + src[to..];
    return newsrc;
}

void lspView(LspModel model) {
    div(() {
        h4("lspSalix demo");
        codeMirrorWithMode("myCodeMirror", model.mode, onChange(textChange), height(400), 
            mode("statemachine"), indentWithTabs(false), lineNumbers(true), \value(model.src));
    });
}