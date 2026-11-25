local Relatorio = require('mutuca.Relatorio')

local test = {}

test['deve mostrar a linha original e a mutada'] = function()
  local relatorio = Relatorio.new{ alvo = 'lib/A.lua', fonte = 'local a\nreturn a > 1' }
  local diff = relatorio:diff{ linha = 2, fonte = 'local a\nreturn a >= 1', situacao = 'vivo' }
  assert(diff == 'lib/A.lua:2 [vivo]\n-return a > 1\n+return a >= 1\n', diff)
end

test['deve identificar a linha sem cobertura'] = function()
  local relatorio = Relatorio.new{ alvo = 'lib/A.lua', fonte = 'return 1' }
  local diff = relatorio:diff{ linha = 1, fonte = 'return 2', situacao = 'descoberto' }
  assert(diff == 'lib/A.lua:1 [sem cobertura]\n-return 1\n+return 2\n', diff)
end

return test
