local Campanha = require('mutuca.Campanha')

local test = {}

test['deve manter so as linhas pedidas'] = function()
  local mutantes = { { linha = 1 }, { linha = 2 }, { linha = 2 }, { linha = 5 } }
  local lista = Campanha.filtrar(mutantes, { [2] = true, [9] = true })
  assert(#lista == 2, #lista)
  assert(lista[1] == mutantes[2])
  assert(lista[2] == mutantes[3])
end

test['deve manter tudo sem filtro'] = function()
  local mutantes = { { linha = 1 } }
  assert(Campanha.filtrar(mutantes, nil) == mutantes)
end

return test
