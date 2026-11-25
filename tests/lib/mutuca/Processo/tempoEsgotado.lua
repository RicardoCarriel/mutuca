local Processo = require('mutuca.Processo')

local test = {}

test['deve reconhecer o sinal de alarme'] = function()
  assert(Processo.tempoEsgotado(14) == true)
  assert(Processo.tempoEsgotado(36352) == true)
  assert(Processo.tempoEsgotado(0) == false)
  assert(Processo.tempoEsgotado(512) == false)
end

return test
