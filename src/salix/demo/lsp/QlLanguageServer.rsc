module salix::demo::lsp::QlLanguageServer

import util::Reflective;
import util::IDEServices;
import util::LanguageServer;

import ParseTree;

// Language
import salix::demo::lsp::QL;


set[LanguageService] QlLanguageContributor() = {
    parser(parser(#start[Form])),
    outliner(QlOutliner),
    summarizer(QlSummarizer, providesImplementations = false),
    lenses(QlLenses),
    executor(QlCommands),
    inlayHinter(QlHinter),
    definer(lookupDef)
};

// Tree of symbols: https://github.com/usethesource/rascal-language-servers/blob/a403b77bebce061112d5749571943ed1fe462cc5/rascal-lsp/src/main/rascal/util/LanguageServer.rsc#L91
list[DocumentSymbol] QlOutliner(start[Form] input)
  = [symbol("<input.src>", DocumentSymbolKind::\file(), input.src, children=[
      *[symbol("<q.id>", \variable(), var.src) | /Question q := input]
  ])];

Summary QlSummarizer(loc l, start[Form] input) {
    println("Running summary for Ql!");
    rel[str, loc] defs = {<"<var.id>", var.src> | /IdType var  := input};
    rel[loc, str] uses = {<id.src, "<id>"> | /Id id := input};
    rel[loc, str] docs = {<var.src, "*variable* <var>"> | /IdType var := input};

    return summary(l,
        references = (uses o defs)<1,0>,
        definitions = uses o defs,
        documentation = (uses o defs) o docs
    );
}

set[loc] lookupDef(loc l, start[Form] input, Tree cursor) =
    { d.src | /IdType d := input, cursor := d.id};


data Command
  = renameAtoB(start[Form] form);

rel[loc,Command] QlLenses(start[Form] input) = {<input@\loc, renameAtoB(input, title="Rename variables a to b.")>};


list[InlayHint] QlHinter(start[Form] input) {
    typeLookup = ( "<name>" : "<tp>" | /(IdType)`<Id name> : <Type tp>` := input);
    return [
        hint(name.src, ": <typeLookup["<name>"]>", \type()) | /(Expression)`<Id name>` := input
    ];
}

list[DocumentEdit] getAtoBEdits(start[Form] input)
   = [changed(input@\loc.top, [replace(id@\loc, "b") | /id:(Id) `a` := input])];

void QlCommands(renameAtoB(start[Form] input)) {
    applyDocumentsEdits(getAtoBEdits(input));
}

void main() {
    registerLanguage(
        language(
            pathConfig(),
            "Ql",
            "Ql",
            "demo::lang::Ql::LanguageServer",
            "QlLanguageContributor"
        )
    );
}
