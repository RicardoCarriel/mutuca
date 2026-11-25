local Campanha  = require('mutuca.Campanha')
local Relatorio = require('mutuca.Relatorio')

local test = {}

test.before = function()
  Relatorio.output = tostring
end

test.after = function()
  Relatorio.output = io.write
end

test['deve barrar escrita no projeto e permitir no tmp'] = function()
  local relatorio = Campanha.new{
    raiz    = os.pwd(),
    alvo    = 'exemplo/lib/Disco.lua',
    testes  = 'exemplo/tests/lib/Disco',
    isolado = true
  }:executar()

  assert(relatorio.contagem.morto == 2, relatorio.contagem.morto)
  assert(relatorio.contagem.vivo == 0, relatorio.contagem.vivo)
  assert(os.exists('lib/proibido') == false)
  assert(os.exists('tmp/permitido') == false)
end

return test
