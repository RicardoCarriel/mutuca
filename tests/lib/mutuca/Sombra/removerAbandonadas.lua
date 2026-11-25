local Sombra = require('mutuca.Sombra')

local test = {}

test['deve remover so a pasta de processo encerrado'] = function()
  local viva  = '/tmp/lua_viva-mutuca-' .. os.pid()
  local morta = '/tmp/lua_morta-mutuca-99999999'
  local outra = '/tmp/lua_outra-mutuca-x'
  os.execute('mkdir -p ' .. viva .. ' ' .. morta .. ' ' .. outra)

  Sombra.removerAbandonadas()
  assert(os.exists(viva) == true)
  assert(os.exists(morta) == false)
  assert(os.exists(outra) == true)

  os.execute('rm -rf ' .. viva .. ' ' .. outra)
end

return test
