local Class = require('arken.oop.Class')

local Relatorio = Class.new("mutuca.Relatorio")

Relatorio.output = io.write

Relatorio.marcas = { morto = '.', tempo = 'T', vivo = 'V', descoberto = 'S' }

-------------------------------------------------------------------------------
-- INITIALIZE
-------------------------------------------------------------------------------

function Relatorio:initialize()
  self.contagem      = { morto = 0, tempo = 0, vivo = 0, descoberto = 0 }
  self.sobreviventes = {}
end

-------------------------------------------------------------------------------
-- REGISTRAR
-------------------------------------------------------------------------------

function Relatorio:registrar(mutante, situacao)
  self.contagem[situacao] = self.contagem[situacao] + 1
  if situacao == 'vivo' or situacao == 'descoberto' then
    mutante.situacao = situacao
    table.insert(self.sobreviventes, mutante)
  end
  Relatorio.output(Relatorio.marcas[situacao])
  io.flush()
end

-------------------------------------------------------------------------------
-- LINHA
-------------------------------------------------------------------------------

function Relatorio.linha(fonte, numero)
  local atual = 0
  for linha in (fonte .. '\n'):gmatch('([^\n]*)\n') do
    atual = atual + 1
    if atual == numero then
      return linha
    end
  end
end

-------------------------------------------------------------------------------
-- DIFF
-------------------------------------------------------------------------------

function Relatorio:diff(mutante)
  local rotulo = mutante.situacao == 'descoberto' and 'sem cobertura' or 'vivo'
  return string.format('%s:%d [%s]\n-%s\n+%s\n', self.alvo, mutante.linha, rotulo,
    Relatorio.linha(self.fonte, mutante.linha), Relatorio.linha(mutante.fonte, mutante.linha))
end

-------------------------------------------------------------------------------
-- RESUMO
-------------------------------------------------------------------------------

function Relatorio:resumo()
  local contagem = self.contagem
  local total    = contagem.morto + contagem.tempo + contagem.vivo + contagem.descoberto
  return string.format('%d mutantes: %d mortos, %d por tempo, %d vivos, %d sem cobertura (%d descartados por não compilar)',
    total, contagem.morto, contagem.tempo, contagem.vivo, contagem.descoberto, self.descartados)
end

-------------------------------------------------------------------------------
-- IMPRIMIR
-------------------------------------------------------------------------------

function Relatorio:imprimir()
  Relatorio.output('\n\n')
  for _, mutante in ipairs(self.sobreviventes) do
    Relatorio.output(self:diff(mutante) .. '\n')
  end
  Relatorio.output(self:resumo() .. '\n')
end

return Relatorio
