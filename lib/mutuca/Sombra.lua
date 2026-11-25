local Class    = require('arken.oop.Class')
local Processo = require('mutuca.Processo')

local Sombra = Class.new("mutuca.Sombra")

Sombra.sufixo = '-mutuca-'

-------------------------------------------------------------------------------
-- COMANDO
-------------------------------------------------------------------------------

function Sombra.comando(formato, ...)
  local partes = {}
  for i, valor in ipairs({ ... }) do
    partes[i] = Processo.aspas(valor)
  end
  local comando = string.format(formato, unpack(partes))
  if os.execute(comando) ~= 0 then
    error('falha ao executar: ' .. comando, 0)
  end
end

-------------------------------------------------------------------------------
-- PROCESSO VIVO
-------------------------------------------------------------------------------

function Sombra.processoVivo(pid)
  return os.execute(string.format('kill -0 %d 2> /dev/null', pid)) == 0
end

-------------------------------------------------------------------------------
-- REMOVER ABANDONADAS
-------------------------------------------------------------------------------

function Sombra.removerAbandonadas()
  local lista = os.glob('/tmp/lua_*' .. Sombra.sufixo .. '*')
  for i = 1, lista:size() do
    local pasta = tostring(lista:at(i))
    local pid   = tonumber(pasta:match('^/tmp/lua_%w+%-mutuca%-(%d+)$'))
    if pid and not Sombra.processoVivo(pid) then
      os.execute('rm -rf ' .. Processo.aspas(pasta) .. ' 2> /dev/null')
    end
  end
end

-------------------------------------------------------------------------------
-- CRIAR
-------------------------------------------------------------------------------

function Sombra.criar(projeto)
  local base  = os.tmpname()
  local pasta = base .. Sombra.sufixo .. os.pid()
  os.remove(base)

  local sombra = Sombra.new{ projeto = projeto, pasta = pasta, raiz = pasta .. '/projeto' }
  Sombra.comando('mkdir -m 700 %s && mkdir %s', sombra.pasta, sombra.raiz)
  Sombra.comando("find %s -mindepth 1 -maxdepth 1 ! -name tmp -exec ln -s {} %s/ ';'", sombra.projeto, sombra.raiz)
  return sombra
end

-------------------------------------------------------------------------------
-- RENOVAR TMP
-------------------------------------------------------------------------------

function Sombra:renovarTmp()
  Sombra.comando('rm -rf %s && mkdir %s', self.raiz .. '/tmp', self.raiz .. '/tmp')
  if os.exists(self.projeto .. '/tmp') then
    Sombra.comando("cd %s && find -H tmp -type d -exec mkdir -p %s/{} ';'", self.projeto, self.raiz)
  end
end

-------------------------------------------------------------------------------
-- REMOVER
-------------------------------------------------------------------------------

function Sombra:remover()
  Sombra.comando('rm -rf %s', self.pasta)
end

return Sombra
