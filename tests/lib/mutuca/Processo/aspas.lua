local Processo = require('mutuca.Processo')

local test = {}

test['deve escapar aspas simples'] = function()
  assert(Processo.aspas("a'b") == "'a'\\''b'", Processo.aspas("a'b"))
end

return test
