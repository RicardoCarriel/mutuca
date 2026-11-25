local Processo = require('mutuca.Processo')

local test = {}

test['deve isolar o processo'] = function()
  local processo = Processo.new{ raiz = '/m', sombra = { pasta = '/t', raiz = '/t/projeto', projeto = '/p' }, limite = 3, isolado = true }
  local comando = processo:comando()
  local esperado = "cd '/t/projeto' && exec env ARKEN_ENV=test perl -e '" .. Processo.alarme .. "' 3 /usr/bin/sandbox-exec -p '" .. processo:perfil()
    .. "' arken '/m/script/executar.lua' '/t/params.json' > /dev/null 2>&1"
  assert(comando == esperado, comando)
end

test['deve rodar sem isolamento'] = function()
  local comando = Processo.new{ raiz = '/m', sombra = { pasta = '/t', raiz = '/t/projeto', projeto = '/p' }, limite = 3, isolado = false }:comando()
  local esperado = "cd '/t/projeto' && exec env ARKEN_ENV=test perl -e '" .. Processo.alarme .. "' 3 arken '/m/script/executar.lua' '/t/params.json' > /dev/null 2>&1"
  assert(comando == esperado, comando)
end

return test
