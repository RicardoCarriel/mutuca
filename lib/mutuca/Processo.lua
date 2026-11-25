local Class = require('arken.oop.Class')
local json  = require('arken.json')

local Processo = Class.new("mutuca.Processo")

Processo.sandbox = '/usr/bin/sandbox-exec'
Processo.alarme  = 'alarm shift; exec @ARGV or exit 127'

Processo.perfil = '(version 1)(allow default)(deny network*)(deny file-write* (require-not (require-any '
  .. '(subpath "/private/tmp") (subpath "/private/var/folders") (literal "/dev/null"))))'

-------------------------------------------------------------------------------
-- ASPAS
-------------------------------------------------------------------------------

function Processo.aspas(texto)
  local escapado = texto:gsub("'", "'\\''")
  return "'" .. escapado .. "'"
end

-------------------------------------------------------------------------------
-- ISOLAMENTO DISPONIVEL
-------------------------------------------------------------------------------

function Processo.isolamentoDisponivel()
  return os.exists(Processo.sandbox)
end

-------------------------------------------------------------------------------
-- COMANDO
-------------------------------------------------------------------------------

function Processo:comando()
  local partes = { 'exec env ARKEN_ENV=test perl -e', Processo.aspas(Processo.alarme), tostring(self.limite) }
  if self.isolado then
    table.insert(partes, Processo.sandbox .. ' -p ' .. Processo.aspas(Processo.perfil))
  end
  table.insert(partes, 'arken ' .. Processo.aspas(self.raiz .. '/script/executar.lua'))
  table.insert(partes, Processo.aspas(self.pasta .. '/params.json'))
  table.insert(partes, '> /dev/null 2>&1')
  return table.concat(partes, ' ')
end

-------------------------------------------------------------------------------
-- GRAVAR
-------------------------------------------------------------------------------

function Processo:gravar(nome, conteudo)
  local arquivo = assert(io.open(self.pasta .. '/' .. nome, 'w'))
  arquivo:write(conteudo)
  arquivo:close()
end

-------------------------------------------------------------------------------
-- TEMPO ESGOTADO
-------------------------------------------------------------------------------

function Processo.tempoEsgotado(codigo)
  return codigo == 14 or codigo == 142 * 256
end

-------------------------------------------------------------------------------
-- CANCELADO
-------------------------------------------------------------------------------

function Processo.cancelado(codigo)
  return codigo == 2 or codigo == 15 or codigo == 130 * 256 or codigo == 143 * 256
end

-------------------------------------------------------------------------------
-- EXECUTAR
-------------------------------------------------------------------------------

function Processo:executar(fonte, cobertura)
  local saida = self.pasta .. '/resultado.json'

  os.remove(saida)
  self:gravar('fonte.lua', fonte)
  self:gravar('params.json', json.encode{
    alvo      = self.alvo,
    testes    = self.testes,
    fonte     = self.pasta .. '/fonte.lua',
    saida     = saida,
    cobertura = cobertura
  })

  local codigo = os.execute(self:comando())

  if Processo.cancelado(codigo) then
    error('cancelado', 0)
  end
  if Processo.tempoEsgotado(codigo) then
    return { tempo = true }
  end
  if not os.exists(saida) then
    return { interrompido = true }
  end
  return json.decode(os.read(saida))
end

return Processo
