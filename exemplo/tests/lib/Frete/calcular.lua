local Frete = require('Frete')

local test = {}

test['deve cobrar por quilo'] = function()
  assert(Frete.calcular(4) == 8)
end

test['deve cobrar valor fixo acima do limite'] = function()
  assert(Frete.calcular(20) == 50)
end

test['deve recusar peso negativo'] = function()
  assert(Frete.calcular(-1) == nil)
end

return test
