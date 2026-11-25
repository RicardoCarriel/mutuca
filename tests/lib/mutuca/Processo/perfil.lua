local Processo = require('mutuca.Processo')

local test = {}

test['deve negar escrita no projeto por ultimo'] = function()
  local perfil = Processo.new{ sombra = { projeto = '/tmp/p' } }:perfil()
  assert(perfil == Processo.perfilBase .. '(deny file-write* (subpath "/tmp/p"))', perfil)
end

test['deve escapar aspas e barra invertida'] = function()
  local perfil = Processo.new{ sombra = { projeto = '/a"b\\c' } }:perfil()
  assert(perfil == Processo.perfilBase .. '(deny file-write* (subpath "/a\\"b\\\\c"))', perfil)
end

return test
