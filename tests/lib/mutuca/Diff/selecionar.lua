local Diff = require('mutuca.Diff')

local test = {}

test['deve manter so lua de lib e app que existe'] = function()
  local alterados = {
    ['lib/mutuca/Gerador.lua']   = { [3] = true },
    ['lib/mutuca/Removido.lua']  = { [1] = true },
    ['tests/lib/mutuca/x.lua']   = { [1] = true },
    ['README.md']                = { [1] = true },
    ['lib/mutuca/Processo.lua']  = {}
  }
  local lista = Diff.selecionar(alterados, 'lib/mutuca/Diff.lua\nscript/mutuca.lua\nlib/mutuca/Gerador.lua\n')

  assert(#lista == 2, #lista)
  assert(lista[1].arquivo == 'lib/mutuca/Diff.lua', lista[1].arquivo)
  assert(lista[1].linhas == nil)
  assert(lista[2].arquivo == 'lib/mutuca/Gerador.lua', lista[2].arquivo)
  assert(lista[2].linhas[3] == true)
end

return test
