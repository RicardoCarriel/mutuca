local Campanha  = require('mutuca.Campanha')
local Relatorio = require('mutuca.Relatorio')

local test = {}

test.before = function()
  Relatorio.output = tostring
end

test.after = function()
  Relatorio.output = io.write
end

test['deve medir o exemplo'] = function()
  local original  = os.read('exemplo/lib/Frete.lua')
  local relatorio = Campanha.new{
    raiz    = os.pwd(),
    alvo    = 'exemplo/lib/Frete.lua',
    testes  = 'exemplo/tests/lib/Frete',
    isolado = true
  }:executar()

  assert(relatorio.contagem.morto == 5, relatorio.contagem.morto)
  assert(relatorio.contagem.vivo == 4, relatorio.contagem.vivo)
  assert(relatorio.contagem.tempo == 0, relatorio.contagem.tempo)
  assert(relatorio.contagem.descoberto == 0, relatorio.contagem.descoberto)
  assert(os.read('exemplo/lib/Frete.lua') == original)
end

return test
