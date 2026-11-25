local Tokenizador = require('mutuca.Tokenizador')

local test = {}

test['deve reconstruir o fonte a partir dos tokens'] = function()
  local fonte = '#!/usr/bin/lua\nlocal a = 0x10 + 1.5e-3 -- fim\n--[==[ ]] x > 1 ]==]\nlocal b = "a\\"b" .. [=[ c ]] ]=]\nreturn a ~= b, ...\n'
  local texto = ''
  for _, token in ipairs(Tokenizador.new{ fonte = fonte }:tokens()) do
    texto = texto .. token.texto
  end
  assert(texto == fonte, texto)
end

test['deve ignorar operadores em texto e comentario'] = function()
  local fonte = 'x = "a > b" -- c > d\ny = [[ e > f ]] --[[ g\n> h ]]'
  local total = 0
  for _, token in ipairs(Tokenizador.new{ fonte = fonte }:tokens()) do
    if token.tipo == 'simbolo' and token.texto == '>' then
      total = total + 1
    end
  end
  assert(total == 0, total)
end

test['deve numerar a linha depois de comentario longo'] = function()
  local tokens = Tokenizador.new{ fonte = '--[[ a\nb ]]\nx = 1' }:tokens()
  local ultimo = tokens[#tokens]
  assert(ultimo.texto == '1', ultimo.texto)
  assert(ultimo.linha == 3, ultimo.linha)
end

test['deve separar numeros hexadecimais, decimais e intervalos'] = function()
  local numeros = {}
  for _, token in ipairs(Tokenizador.new{ fonte = 'a = 0xFF b = 2.5 c = 1e3 d = 10 .. 20' }:tokens()) do
    if token.tipo == 'numero' then
      table.insert(numeros, token.texto)
    end
  end
  assert(table.concat(numeros, ',') == '0xFF,2.5,1e3,10,20', table.concat(numeros, ','))
end

test['deve delimitar texto com aspas e escape'] = function()
  local tokens = Tokenizador.new{ fonte = [[x="a\"b"..'' .."c\\"]] }:tokens()
  assert(#tokens == 8, #tokens)
  assert(tokens[3].texto == [["a\"b"]], tokens[3].texto)
  assert(tokens[3].tipo == 'texto', tokens[3].tipo)
  assert(tokens[4].texto == '..', tokens[4].texto)
  assert(tokens[5].texto == "''", tokens[5].texto)
  assert(tokens[8].texto == [["c\\"]], tokens[8].texto)
end

test['deve delimitar texto que termina no fim do fonte'] = function()
  local tokens = Tokenizador.new{ fonte = 'x="a"' }:tokens()
  assert(#tokens == 3, #tokens)
  assert(tokens[3].texto == '"a"', tokens[3].texto)
  assert(tokens[3].fim == 5, tokens[3].fim)
end

test['deve delimitar comentario de linha'] = function()
  local tokens = Tokenizador.new{ fonte = 'x--a\ny--b' }:tokens()
  assert(#tokens == 5, #tokens)
  assert(tokens[2].texto == '--a', tokens[2].texto)
  assert(tokens[3].texto == '\n', tokens[3].texto)
  assert(tokens[4].texto == 'y', tokens[4].texto)
  assert(tokens[5].texto == '--b', tokens[5].texto)
  assert(tokens[5].fim == 9, tokens[5].fim)
end

test['deve delimitar a linha do interpretador'] = function()
  local tokens = Tokenizador.new{ fonte = '#!lua\nx' }:tokens()
  assert(#tokens == 3, #tokens)
  assert(tokens[1].texto == '#!lua', tokens[1].texto)
  assert(tokens[1].tipo == 'comentario', tokens[1].tipo)
  tokens = Tokenizador.new{ fonte = '#!lua' }:tokens()
  assert(#tokens == 1, #tokens)
  assert(tokens[1].fim == 5, tokens[1].fim)
end

test['deve aceitar o operador de tamanho'] = function()
  local tokens = Tokenizador.new{ fonte = 'a=#b' }:tokens()
  assert(#tokens == 4, #tokens)
  assert(tokens[3].texto == '#', tokens[3].texto)
end

test['deve delimitar bloco longo com nivel'] = function()
  local tokens = Tokenizador.new{ fonte = 'x=[=[a]]b]=]--[[c]]y' }:tokens()
  assert(#tokens == 5, #tokens)
  assert(tokens[3].texto == '[=[a]]b]=]', tokens[3].texto)
  assert(tokens[4].texto == '--[[c]]', tokens[4].texto)
  assert(tokens[5].texto == 'y', tokens[5].texto)
end

test['deve fechar texto logo depois do escape'] = function()
  local tokens = Tokenizador.new{ fonte = [["\\"..y]] }:tokens()
  assert(#tokens == 3, #tokens)
  assert(tokens[1].texto == [["\\"]], tokens[1].texto)
end

test['deve separar hexadecimal do operador'] = function()
  local tokens = Tokenizador.new{ fonte = '0x10+1' }:tokens()
  assert(#tokens == 3, #tokens)
  assert(tokens[1].texto == '0x10', tokens[1].texto)
  assert(tokens[2].texto == '+', tokens[2].texto)
  tokens = Tokenizador.new{ fonte = '0x1p+4' }:tokens()
  assert(#tokens == 1, #tokens)
end

return test
