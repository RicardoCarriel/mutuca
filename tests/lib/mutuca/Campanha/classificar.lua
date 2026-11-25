local Campanha = require('mutuca.Campanha')

local test = {}

test['deve classificar cada situacao'] = function()
  local base = { ok = 3 }
  assert(Campanha.classificar(base, { tempo = true }) == 'tempo')
  assert(Campanha.classificar(base, { interrompido = true }) == 'morto')
  assert(Campanha.classificar(base, { ok = 2, failure = 1 }) == 'morto')
  assert(Campanha.classificar(base, { ok = 2, failure = 0 }) == 'morto')
  assert(Campanha.classificar(base, { ok = 3, failure = 0 }) == 'vivo')
  assert(Campanha.classificar(base, { ok = 3, failure = 0 }, true) == 'descoberto')
end

return test
