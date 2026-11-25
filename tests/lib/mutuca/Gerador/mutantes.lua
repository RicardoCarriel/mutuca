local Gerador = require('mutuca.Gerador')

local test = {}

test['deve trocar o operador de comparacao'] = function()
  local mutantes, descartados = Gerador.new{ fonte = 'return a < b' }:mutantes()
  assert(#mutantes == 2, #mutantes)
  assert(mutantes[1].fonte == 'return a <= b', mutantes[1].fonte)
  assert(mutantes[2].fonte == 'return a >= b', mutantes[2].fonte)
  assert(descartados == 0, descartados)
end

test['deve somar um ao numero'] = function()
  local mutantes = Gerador.new{ fonte = 'return 99' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  assert(mutantes[1].fonte == 'return 100', mutantes[1].fonte)
end

test['deve manter numero hexadecimal'] = function()
  local mutantes = Gerador.new{ fonte = 'return 0x10' }:mutantes()
  assert(#mutantes == 0, #mutantes)
end

test['deve remover o not'] = function()
  local mutantes = Gerador.new{ fonte = 'return not a' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  assert(mutantes[1].fonte == 'return  a', mutantes[1].fonte)
end

test['deve descartar mutante que nao compila'] = function()
  local mutantes, descartados = Gerador.new{ fonte = 'return -a' }:mutantes()
  assert(#mutantes == 0, #mutantes)
  assert(descartados == 1, descartados)
end

test['deve ignorar a linha marcada'] = function()
  local mutantes = Gerador.new{ fonte = 'a = 1 -- mutuca: ignora\nb = true' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  assert(mutantes[1].linha == 2, mutantes[1].linha)
  assert(mutantes[1].novo == 'false', mutantes[1].novo)
end

test['deve exigir que o marcador esteja em comentario'] = function()
  local mutantes = Gerador.new{ fonte = 'a = "mutuca: ignora" b = 1' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  assert(mutantes[1].novo == '2', mutantes[1].novo)
end

test['deve ignorar o nivel do error com tabela'] = function()
  local mutantes = Gerador.new{ fonte = "error({ a = 'x' }, 0)" }:mutantes()
  assert(#mutantes == 0, #mutantes)
  mutantes = Gerador.new{ fonte = "error ( { a = { b = 1 } } , -- nivel\n 0 )" }:mutantes()
  assert(#mutantes == 1, #mutantes)
  assert(mutantes[1].original == '1', mutantes[1].original)
end

test['deve manter o nivel do error com texto ou variavel'] = function()
  local mutantes = Gerador.new{ fonte = "error('x', 0)" }:mutantes()
  assert(#mutantes == 1, #mutantes)
  mutantes = Gerador.new{ fonte = 'error(resultado, 0)' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  mutantes = Gerador.new{ fonte = 'error(f{}, 0)' }:mutantes()
  assert(#mutantes == 1, #mutantes)
end

test['deve manter o numero em chamada que nao e o error global'] = function()
  local mutantes = Gerador.new{ fonte = 'log.error({}, 0)' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  mutantes = Gerador.new{ fonte = 'log:error({}, 0)' }:mutantes()
  assert(#mutantes == 1, #mutantes)
  mutantes = Gerador.new{ fonte = 'aviso({}, 0)' }:mutantes()
  assert(#mutantes == 1, #mutantes)
end

test['deve manter expressao no nivel do error'] = function()
  local mutantes = Gerador.new{ fonte = 'error({}, 1 + n)' }:mutantes()
  assert(#mutantes == 2, #mutantes)
end

test['deve aceitar error com tabela e sem nivel'] = function()
  local mutantes = Gerador.new{ fonte = 'error({})' }:mutantes()
  assert(#mutantes == 0, #mutantes)
end

return test
