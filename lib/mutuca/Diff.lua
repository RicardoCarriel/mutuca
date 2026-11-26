local Class  = require('arken.oop.Class')
local Sombra = require('mutuca.Sombra')

local Diff = Class.new("mutuca.Diff")

Diff.pastas = { '^lib/', '^app/' }

-------------------------------------------------------------------------------
-- CAPTURAR
-------------------------------------------------------------------------------

function Diff.capturar(formato, ...)
  local saida = os.tmpname()
  local partes = { ... }
  table.insert(partes, saida)
  local status, erro = pcall(Sombra.comando, formato .. ' > %s', unpack(partes))
  local texto = os.read(saida)
  os.remove(saida)
  if not status then
    error(erro, 0)
  end
  return texto
end

-------------------------------------------------------------------------------
-- ANALISAR
-------------------------------------------------------------------------------

function Diff.analisar(texto)
  local arquivos = {}
  local atual    = nil
  local anterior = ''
  for linha in (texto .. '\n'):gmatch('([^\n]*)\n') do
    if anterior:match('^%-%-%- ') and linha:match('^%+%+%+ ') then
      local caminho = linha:match('^%+%+%+ b/(.+)$')
      atual = nil
      if caminho then
        atual = {}
        arquivos[caminho] = atual
      end
    else
      local inicio, quantidade = linha:match('^@@ %-%S+ %+(%d+),?(%d*) @@')
      if inicio and atual then
        for numero = tonumber(inicio), tonumber(inicio) + (tonumber(quantidade) or 1) - 1 do
          atual[numero] = true
        end
      end
    end
    anterior = linha
  end
  return arquivos
end

-------------------------------------------------------------------------------
-- CONSIDERAR
-------------------------------------------------------------------------------

function Diff.considerar(caminho)
  if not caminho:match('%.lua$') or not os.exists(caminho) then
    return false
  end
  for _, padrao in ipairs(Diff.pastas) do
    if caminho:match(padrao) then
      return true
    end
  end
  return false
end

-------------------------------------------------------------------------------
-- SELECIONAR
-------------------------------------------------------------------------------

function Diff.selecionar(alterados, novos)
  local lista = {}
  for caminho, linhas in pairs(alterados) do
    if next(linhas) and Diff.considerar(caminho) then
      table.insert(lista, { arquivo = caminho, linhas = linhas })
    end
  end
  for caminho in novos:gmatch('[^\n]+') do
    if alterados[caminho] == nil and Diff.considerar(caminho) then
      table.insert(lista, { arquivo = caminho })
    end
  end
  table.sort(lista, Diff.ordenar)
  return lista
end

-------------------------------------------------------------------------------
-- ORDENAR
-------------------------------------------------------------------------------

function Diff.ordenar(a, b)
  return a.arquivo < b.arquivo
end

-------------------------------------------------------------------------------
-- ARQUIVOS
-------------------------------------------------------------------------------

function Diff:arquivos()
  local base      = Diff.capturar('git merge-base %s HEAD', self.base):gsub('%s+$', '')
  local alterados = Diff.analisar(Diff.capturar('git -c core.quotePath=false diff --no-color --no-ext-diff -U0 %s', base))
  local novos     = Diff.capturar('git -c core.quotePath=false ls-files --others --exclude-standard')
  return Diff.selecionar(alterados, novos)
end

return Diff
