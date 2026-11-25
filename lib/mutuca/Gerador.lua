local Class       = require('arken.oop.Class')
local Tokenizador = require('mutuca.Tokenizador')

local Gerador = Class.new("mutuca.Gerador")

Gerador.marcador = 'mutuca: ignora'

Gerador.trocas = {
  ['==']    = { '~=' },
  ['~=']    = { '==' },
  ['<']     = { '<=', '>=' },
  ['<=']    = { '<', '>' },
  ['>']     = { '>=', '<=' },
  ['>=']    = { '>', '<' },
  ['+']     = { '-' },
  ['-']     = { '+' },
  ['*']     = { '/' },
  ['/']     = { '*' },
  ['and']   = { 'or' },
  ['or']    = { 'and' },
  ['true']  = { 'false' },
  ['false'] = { 'true' },
  ['not']   = { '' }
}

-------------------------------------------------------------------------------
-- ALTERNATIVAS
-------------------------------------------------------------------------------

function Gerador:alternativas(token)
  if token.tipo == 'nome' or token.tipo == 'simbolo' then
    return Gerador.trocas[token.texto] or {}
  end
  if token.tipo == 'numero' and token.texto:match('^%d+%.?%d*$') then
    return { string.format('%.14g', tonumber(token.texto) + 1) }
  end
  return {}
end

-------------------------------------------------------------------------------
-- LINHAS IGNORADAS
-------------------------------------------------------------------------------

function Gerador:linhasIgnoradas(tokens)
  local linhas = {}
  for _, token in ipairs(tokens) do
    if token.tipo == 'comentario' and token.texto:find(Gerador.marcador, 1, true) then
      linhas[token.linha] = true
    end
  end
  return linhas
end

-------------------------------------------------------------------------------
-- SIGNIFICATIVOS
-------------------------------------------------------------------------------

function Gerador.significativos(tokens)
  local lista = {}
  for _, token in ipairs(tokens) do
    if token.tipo ~= 'espaco' and token.tipo ~= 'comentario' then
      table.insert(lista, token)
    end
  end
  return lista
end

-------------------------------------------------------------------------------
-- TEXTO
-------------------------------------------------------------------------------

function Gerador.texto(tokens, indice)
  return tokens[indice] and tokens[indice].texto
end

-------------------------------------------------------------------------------
-- FIM DA TABELA
-------------------------------------------------------------------------------

function Gerador.fimDaTabela(tokens, indice)
  local nivel = 0
  for i = indice, #tokens do
    if tokens[i].texto == '{' then
      nivel = nivel + 1
    elseif tokens[i].texto == '}' then
      nivel = nivel - 1
      if nivel == 0 then
        return i
      end
    end
  end
  return #tokens
end

-------------------------------------------------------------------------------
-- NIVEL DO ERROR
-------------------------------------------------------------------------------

function Gerador.nivelDoError(tokens, indice)
  local anterior = Gerador.texto(tokens, indice - 1)
  if tokens[indice].texto ~= 'error' or anterior == '.' or anterior == ':' then
    return nil
  end
  if Gerador.texto(tokens, indice + 1) ~= '(' or Gerador.texto(tokens, indice + 2) ~= '{' then
    return nil
  end
  local fim = Gerador.fimDaTabela(tokens, indice + 2)
  if Gerador.texto(tokens, fim + 1) == ',' and Gerador.texto(tokens, fim + 3) == ')' then
    return tokens[fim + 2]
  end
end

-------------------------------------------------------------------------------
-- NIVEIS IGNORADOS
-------------------------------------------------------------------------------

function Gerador:niveisIgnorados(tokens)
  local lista  = Gerador.significativos(tokens)
  local niveis = {}
  for indice = 1, #lista do
    local nivel = Gerador.nivelDoError(lista, indice)
    if nivel and nivel.tipo == 'numero' then
      niveis[nivel] = true
    end
  end
  return niveis
end

-------------------------------------------------------------------------------
-- MUTANTES
-------------------------------------------------------------------------------

function Gerador:mutantes()
  local tokens      = Tokenizador.new{ fonte = self.fonte }:tokens()
  local ignoradas   = self:linhasIgnoradas(tokens)
  local niveis      = self:niveisIgnorados(tokens)
  local lista       = {}
  local descartados = 0

  for _, token in ipairs(tokens) do
    if not ignoradas[token.linha] and not niveis[token] then
      for _, novo in ipairs(self:alternativas(token)) do
        local fonte = self.fonte:sub(1, token.inicio - 1) .. novo .. self.fonte:sub(token.fim + 1)
        if loadstring(fonte) then
          table.insert(lista, { fonte = fonte, linha = token.linha, original = token.texto, novo = novo })
        else
          descartados = descartados + 1
        end
      end
    end
  end

  return lista, descartados
end

return Gerador
