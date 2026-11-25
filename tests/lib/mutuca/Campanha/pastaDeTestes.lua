local Campanha = require('mutuca.Campanha')

local test = {}

test['deve seguir a convencao de pastas'] = function()
  assert(Campanha.pastaDeTestes('lib/util/Cpf.lua') == 'tests/lib/util/Cpf')
  assert(Campanha.pastaDeTestes('./lib/Cpf.lua') == 'tests/lib/Cpf')
  assert(Campanha.pastaDeTestes('app/models/Pedido.lua') == 'tests/models/Pedido')
end

return test
