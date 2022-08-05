
module salix::lib::Lsp

import salix::HTML;
import salix::Core;
import salix::Node;
import salix::lib::Mode;

// PathConfig pcfg, str name, str extension, str mainModule, str mainFunction
void drawIde(Language lang) {
    
}

alias LspModel = tuple[
    str src,
    Mode mode
];

LspModel lspInit(str languageName, type[&T <: Tree] sym) {
    Mode languageMode = grammar2mode(languageName, sym);
    LspModel model = <qlExampleProgram, languageMode>;

    return model;
}