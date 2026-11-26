local Diff = require('mutuca.Diff')

local test = {}

test['deve devolver a saida do comando'] = function()
  assert(Diff.capturar('printf %s', 'a b') == 'a b', Diff.capturar('printf %s', 'a b'))
end

test['deve falhar quando o comando falha'] = function()
  local status, erro = pcall(Diff.capturar, 'false')
  assert(status == false)
  assert(erro:match("^falha ao executar: false > '/") ~= nil, erro)
end

return test
