local Campanha = require('mutuca.Campanha')

local test = {}

test['deve devolver o caminho a partir do projeto'] = function()
  assert(Campanha.caminhoRelativo('lib/A.lua') == 'lib/A.lua')
  assert(Campanha.caminhoRelativo('./lib/A.lua') == 'lib/A.lua')
  assert(Campanha.caminhoRelativo(os.pwd() .. '/lib/A.lua') == 'lib/A.lua')
end

test['deve recusar arquivo de fora do projeto'] = function()
  local status, erro = pcall(Campanha.caminhoRelativo, '/outro/A.lua')
  assert(status == false and erro == 'o arquivo precisa estar no projeto atual: /outro/A.lua', erro)
end

return test
