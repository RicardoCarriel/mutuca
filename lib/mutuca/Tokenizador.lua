local Class = require('arken.oop.Class')

local Tokenizador = Class.new("mutuca.Tokenizador")

Tokenizador.padroes = {
  { tipo = 'espaco',  padrao = '^%s+' },
  { tipo = 'nome',    padrao = '^[%a_][%w_]*' },
  { tipo = 'numero',  padrao = '^0[xX][%x%.]+[pP][+-]?%d+' },
  { tipo = 'numero',  padrao = '^0[xX][%x%.]+[uUlLiI]*' },
  { tipo = 'numero',  padrao = '^%d+%.?%d*[eE][+-]?%d+' },
  { tipo = 'numero',  padrao = '^%d+%.%d+[iI]?' },
  { tipo = 'numero',  padrao = '^%d+[uUlLiI]*' },
  { tipo = 'numero',  padrao = '^%.%d+' },
  { tipo = 'simbolo', padrao = '^%.%.%.' },
  { tipo = 'simbolo', padrao = '^%.%.' },
  { tipo = 'simbolo', padrao = '^[=~<>]=' },
  { tipo = 'simbolo', padrao = '^.' }
}

-------------------------------------------------------------------------------
-- FIM DO BLOCO LONGO
-------------------------------------------------------------------------------

function Tokenizador:fimBlocoLongo(inicio)
  local nivel = self.fonte:match('^%[(=*)%[', inicio)
  if nivel == nil then
    return nil
  end
  local abre, fecha = self.fonte:find(']' .. nivel .. ']', inicio, true)
  return fecha or #self.fonte
end

-------------------------------------------------------------------------------
-- FIM DO COMENTARIO
-------------------------------------------------------------------------------

function Tokenizador:fimComentario(inicio)
  if inicio == 1 and self.fonte:sub(1, 2) == '#!' then
    return (self.fonte:find('\n', 1, true) or #self.fonte + 1) - 1
  end
  if self.fonte:sub(inicio, inicio + 1) ~= '--' then
    return nil
  end
  local fim = self:fimBlocoLongo(inicio + 2)
  if fim then
    return fim
  end
  return (self.fonte:find('\n', inicio, true) or #self.fonte + 1) - 1
end

-------------------------------------------------------------------------------
-- FIM DO TEXTO
-------------------------------------------------------------------------------

function Tokenizador:fimTexto(inicio)
  local aspas = self.fonte:sub(inicio, inicio)
  if aspas ~= '"' and aspas ~= "'" then
    return self:fimBlocoLongo(inicio)
  end
  local posicao = inicio + 1
  while posicao <= #self.fonte do
    local caractere = self.fonte:sub(posicao, posicao)
    if caractere == '\\' then
      posicao = posicao + 1
    elseif caractere == aspas then
      return posicao
    end
    posicao = posicao + 1
  end
  return #self.fonte
end

-------------------------------------------------------------------------------
-- PROXIMO
-------------------------------------------------------------------------------

function Tokenizador:proximo(inicio)
  local fim = self:fimComentario(inicio)
  if fim then
    return 'comentario', fim
  end

  fim = self:fimTexto(inicio)
  if fim then
    return 'texto', fim
  end

  for _, item in ipairs(Tokenizador.padroes) do
    local comeco, final = self.fonte:find(item.padrao, inicio)
    if comeco then
      return item.tipo, final
    end
  end
end

-------------------------------------------------------------------------------
-- TOKENS
-------------------------------------------------------------------------------

function Tokenizador:tokens()
  local lista  = {}
  local inicio = 1
  local linha  = 1
  while inicio <= #self.fonte do
    local tipo, fim = self:proximo(inicio)
    local texto     = self.fonte:sub(inicio, fim)
    table.insert(lista, { tipo = tipo, texto = texto, inicio = inicio, fim = fim, linha = linha })
    for quebra in texto:gmatch('\n') do
      linha = linha + 1
    end
    inicio = fim + 1
  end
  return lista
end

return Tokenizador
