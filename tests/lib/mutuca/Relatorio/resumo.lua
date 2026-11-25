local Relatorio = require('mutuca.Relatorio')

local test = {}

test['deve contar por situacao'] = function()
  local relatorio = Relatorio.new{ descartados = 2 }
  relatorio.contagem = { morto = 5, tempo = 1, vivo = 3, descoberto = 4 }
  local esperado = '13 mutantes: 5 mortos, 1 por tempo, 3 vivos, 4 sem cobertura (2 descartados por não compilar)'
  assert(relatorio:resumo() == esperado, relatorio:resumo())
end

return test
