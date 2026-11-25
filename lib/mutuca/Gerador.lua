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
-- MUTANTES
-------------------------------------------------------------------------------

function Gerador:mutantes()
  local tokens      = Tokenizador.new{ fonte = self.fonte }:tokens()
  local ignoradas   = self:linhasIgnoradas(tokens)
  local lista       = {}
  local descartados = 0

  for _, token in ipairs(tokens) do
    if not ignoradas[token.linha] then
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
