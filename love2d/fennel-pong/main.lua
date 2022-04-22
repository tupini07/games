-- bootstrap the compiler
fennel = require("lib.fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)

pp = function(x) print(fennel.view(x)) end

lume = require("lib.lume")
require("wrap")
