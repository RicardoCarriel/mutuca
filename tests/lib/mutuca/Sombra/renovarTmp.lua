local Sombra = require('mutuca.Sombra')

local test = {}

test['deve recriar so as pastas do tmp'] = function()
  local projeto = os.tmpname()
  os.remove(projeto)
  os.execute('mkdir -p ' .. projeto .. '/tmp/debug ' .. projeto .. '/lib && touch ' .. projeto .. '/tmp/debug/a')

  local sombra = Sombra.criar(projeto)
  sombra:renovarTmp()
  assert(os.exists(sombra.raiz .. '/tmp/debug') == true)
  assert(os.exists(sombra.raiz .. '/tmp/debug/a') == false)
  assert(os.exists(sombra.raiz .. '/lib') == true)

  os.execute('touch ' .. sombra.raiz .. '/tmp/sobra')
  sombra:renovarTmp()
  assert(os.exists(sombra.raiz .. '/tmp/sobra') == false)

  sombra:remover()
  assert(os.exists(sombra.pasta) == false)
  assert(os.exists(projeto .. '/tmp/debug/a') == true)
  os.execute('rm -rf ' .. projeto)
end

test['deve aceitar projeto sem tmp'] = function()
  local projeto = os.tmpname()
  os.remove(projeto)
  os.execute('mkdir -p ' .. projeto .. '/lib')

  local sombra = Sombra.criar(projeto)
  sombra:renovarTmp()
  assert(os.exists(sombra.raiz .. '/tmp') == true)

  sombra:remover()
  os.execute('rm -rf ' .. projeto)
end

return test
