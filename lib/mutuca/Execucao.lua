local Class    = require('arken.oop.Class')
local json     = require('arken.json')
local test     = require('arken.test')
local coverage = require('arken.coverage')

local Execucao = Class.new("mutuca.Execucao")

-------------------------------------------------------------------------------
-- CARREGAR
-------------------------------------------------------------------------------

function Execucao.carregar(nome)
  local atual   = Execucao.atual
  local caminho = package.searchpath(nome, package.path)
  if caminho and os.abspath(caminho) == atual.alvo then
    atual.carregado = true
    return assert(loadstring(os.read(atual.fonte), '@' .. atual.alvo))
  end
end

-------------------------------------------------------------------------------
-- SILENCIAR
-------------------------------------------------------------------------------

function Execucao.silenciar()
end

-------------------------------------------------------------------------------
-- RODAR
-------------------------------------------------------------------------------

function Execucao:rodar(arquivo)
  for nome, resultados in pairs(test.execute({ arquivo })) do
    for descricao, resultado in pairs(resultados) do
      self.contagem[resultado.status] = (self.contagem[resultado.status] or 0) + 1
      if resultado.status == 'failure' then
        self.falha = arquivo .. ': ' .. descricao .. ': ' .. tostring(resultado.msg)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- RODAR TESTES
-------------------------------------------------------------------------------

function Execucao:rodarTestes()
  for _, arquivo in ipairs(self.testes) do
    local status, erro = pcall(self.rodar, self, arquivo)
    if not status then
      self.contagem.failure = self.contagem.failure + 1
      self.falha = arquivo .. ': ' .. tostring(erro)
    end
    if self.contagem.failure > 0 then
      return
    end
  end
end

-------------------------------------------------------------------------------
-- SEM COBERTURA
-------------------------------------------------------------------------------

function Execucao:semCobertura()
  local linhas = {}
  for numero, linha in ipairs(coverage.analyze(self.alvo).lines) do
    if linha.flag == nil then
      table.insert(linhas, numero)
    end
  end
  return linhas
end

-------------------------------------------------------------------------------
-- EXECUTAR
-------------------------------------------------------------------------------

function Execucao:executar()
  local resultado = {}

  Execucao.atual = self
  self.alvo      = os.abspath(self.alvo)
  self.contagem  = { ok = 0, failure = 0, pending = 0 }
  self.carregado = false
  test.output    = Execucao.silenciar
  table.insert(package.loaders, 2, Execucao.carregar)

  if self.cobertura then
    jit.off()
    coverage.start()
  end

  self:rodarTestes()

  if self.cobertura then
    coverage.stop()
    resultado.semCobertura = self:semCobertura()
  end

  resultado.ok        = self.contagem.ok
  resultado.failure   = self.contagem.failure
  resultado.carregado = self.carregado
  resultado.falha     = self.falha or ''

  local arquivo = assert(io.open(self.saida, 'w'))
  arquivo:write(json.encode(resultado))
  arquivo:close()
end

return Execucao
