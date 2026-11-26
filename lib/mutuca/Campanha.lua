local Class     = require('arken.oop.Class')
local Gerador   = require('mutuca.Gerador')
local Processo  = require('mutuca.Processo')
local Relatorio = require('mutuca.Relatorio')
local Sombra    = require('mutuca.Sombra')

local Campanha = Class.new("mutuca.Campanha")

Campanha.limiteBase   = 120
Campanha.limiteMinimo = 2

-------------------------------------------------------------------------------
-- PASTA DE TESTES
-------------------------------------------------------------------------------

function Campanha.pastaDeTestes(alvo)
  local pasta = alvo:gsub('^%./', ''):gsub('%.lua$', ''):gsub('^app/', '')
  return 'tests/' .. pasta
end

-------------------------------------------------------------------------------
-- CAMINHO RELATIVO
-------------------------------------------------------------------------------

function Campanha.caminhoRelativo(caminho)
  local raiz = os.pwd() .. '/'
  if caminho:sub(1, #raiz) == raiz then
    return caminho:sub(#raiz + 1)
  end
  if caminho:sub(1, 1) == '/' then
    error('o arquivo precisa estar no projeto atual: ' .. caminho, 0)
  end
  local relativo = caminho:gsub('^%./', '')
  return relativo
end

-------------------------------------------------------------------------------
-- LISTAR TESTES
-------------------------------------------------------------------------------

function Campanha.listarTestes(pasta)
  local testes = {}
  local lista  = os.find(pasta, '\\.lua$', true)
  for i = 1, lista:size() do
    table.insert(testes, tostring(lista:at(i)))
  end
  table.sort(testes)
  return testes
end

-------------------------------------------------------------------------------
-- CLASSIFICAR
-------------------------------------------------------------------------------

function Campanha.classificar(base, resultado, descoberta)
  if resultado.tempo then
    return 'tempo'
  end
  if resultado.interrompido or resultado.failure > 0 or resultado.ok ~= base.ok then
    return 'morto'
  end
  if descoberta then
    return 'descoberto'
  end
  return 'vivo'
end

-------------------------------------------------------------------------------
-- FILTRAR
-------------------------------------------------------------------------------

function Campanha.filtrar(mutantes, linhas)
  if linhas == nil then
    return mutantes
  end
  local lista = {}
  for _, mutante in ipairs(mutantes) do
    if linhas[mutante.linha] then
      table.insert(lista, mutante)
    end
  end
  return lista
end

-------------------------------------------------------------------------------
-- LIMITE
-------------------------------------------------------------------------------

function Campanha.limite(segundos)
  return math.max(Campanha.limiteMinimo, math.ceil(segundos * 5))
end

-------------------------------------------------------------------------------
-- VALIDAR
-------------------------------------------------------------------------------

function Campanha:validar()
  if self.alvo == nil then
    error('uso: mutuca arquivo.lua [--testes pasta] [--sem-isolamento] ou mutuca --diff [base] [--sem-isolamento]', 0)
  end
  self.alvo = Campanha.caminhoRelativo(self.alvo)
  if not os.exists(self.alvo) then
    error('arquivo não encontrado: ' .. self.alvo, 0)
  end
  if self.isolado and not Processo.isolamentoDisponivel() then
    error('isolamento indisponível neste sistema; use --sem-isolamento por sua conta', 0)
  end
  self.testes = self.testes or Campanha.pastaDeTestes(self.alvo)
  if not os.exists(self.testes) then
    error('pasta de testes não encontrada: ' .. self.testes, 0)
  end
end

-------------------------------------------------------------------------------
-- VALIDAR BASE
-------------------------------------------------------------------------------

function Campanha.validarBase(base)
  if base.tempo then
    error('os testes sem mutação passaram do tempo limite', 0)
  end
  if base.interrompido then
    error('os testes sem mutação encerraram sem resultado', 0)
  end
  if base.failure > 0 then
    error('os testes falham sem mutação: ' .. base.falha, 0)
  end
  if base.ok == 0 then
    error('nenhum teste executado', 0)
  end
  if not base.carregado then
    error('os testes não carregaram o arquivo alvo por require', 0)
  end
end

-------------------------------------------------------------------------------
-- MUTAR
-------------------------------------------------------------------------------

function Campanha:mutar(processo, fonte)
  local mutantes, descartados = Gerador.new{ fonte = fonte }:mutantes()
  local relatorio = Relatorio.new{ alvo = self.alvo, fonte = fonte, descartados = descartados }
  mutantes = Campanha.filtrar(mutantes, self.linhas)
  if #mutantes == 0 then
    relatorio:imprimir()
    return relatorio
  end

  local descobertas = {}
  local base        = processo:executar(fonte, true)
  Campanha.validarBase(base)
  for _, linha in ipairs(base.semCobertura) do
    descobertas[linha] = true
  end

  local inicio = os.microtime()
  base = processo:executar(fonte, false)
  Campanha.validarBase(base)
  processo.limite = Campanha.limite(os.microtime() - inicio)

  for _, mutante in ipairs(mutantes) do
    local resultado = processo:executar(mutante.fonte, false)
    relatorio:registrar(mutante, Campanha.classificar(base, resultado, descobertas[mutante.linha]))
  end
  relatorio:imprimir()
  return relatorio
end

-------------------------------------------------------------------------------
-- EXECUTAR
-------------------------------------------------------------------------------

function Campanha:executar()
  self:validar()

  Sombra.removerAbandonadas()

  local sombra = Sombra.criar(os.pwd())
  local processo = Processo.new{
    raiz    = self.raiz,
    sombra  = sombra,
    alvo    = self.alvo,
    testes  = Campanha.listarTestes(self.testes),
    isolado = self.isolado,
    limite  = Campanha.limiteBase
  }

  local status, retorno = pcall(self.mutar, self, processo, os.read(self.alvo))
  sombra:remover()
  if not status then
    error(retorno, 0)
  end
  return retorno
end

return Campanha
