local Processo = require('mutuca.Processo')

local test = {}

test['deve reconhecer interrupcao do usuario'] = function()
  assert(Processo.cancelado(2) == true)
  assert(Processo.cancelado(15) == true)
  assert(Processo.cancelado(33280) == true)
  assert(Processo.cancelado(36608) == true)
  assert(Processo.cancelado(0) == false)
  assert(Processo.cancelado(512) == false)
  assert(Processo.cancelado(14) == false)
end

return test
