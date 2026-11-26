local Class     = require('arken.oop.Class')
local Campanha  = require('mutuca.Campanha')
local Diff      = require('mutuca.Diff')
local Relatorio = require('mutuca.Relatorio')

local Revisao = Class.new("mutuca.Revisao")

-------------------------------------------------------------------------------
-- SOMAR
-------------------------------------------------------------------------------

function Revisao:somar(relatorio)
  for situacao, total in pairs(relatorio.contagem) do
    self.total.contagem[situacao] = self.total.contagem[situacao] + total
  end
  self.total.descartados = self.total.descartados + relatorio.descartados
end

-------------------------------------------------------------------------------
-- EXECUTAR
-------------------------------------------------------------------------------

function Revisao:executar()
  local arquivos = Diff.new{ base = self.base }:arquivos()
  self.total  = Relatorio.new{ descartados = 0 }
  self.falhas = 0

  for _, item in ipairs(arquivos) do
    Relatorio.output('== ' .. item.arquivo .. '\n')
    local campanha = Campanha.new{ raiz = self.raiz, alvo = item.arquivo, linhas = item.linhas, isolado = self.isolado }
    local status, retorno = pcall(campanha.executar, campanha)
    if status then
      self:somar(retorno)
    else
      self.falhas = self.falhas + 1
      Relatorio.output(tostring(retorno) .. '\n')
    end
    Relatorio.output('\n')
  end

  Relatorio.output(string.format('Revisão contra %s: %d arquivos, %d sem resultado\n%s\n',
    self.base, #arquivos, self.falhas, self.total:resumo()))
  return self.total
end

return Revisao
