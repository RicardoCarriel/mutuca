local Relatorio = require('mutuca.Relatorio')
local Revisao   = require('mutuca.Revisao')

local test     = {}
local contexto = {}

test.before = function()
  Relatorio.output = tostring
  contexto.raiz    = os.pwd()
  contexto.projeto = os.tmpname()
  os.remove(contexto.projeto)
  os.execute('cp -R exemplo ' .. contexto.projeto)
  os.execute('git -C ' .. contexto.projeto .. ' init -q -b master')
  os.execute('git -C ' .. contexto.projeto .. ' add -A')
  os.execute('git -C ' .. contexto.projeto .. ' -c user.name=t -c user.email=t@t commit -q -m base')
  os.chdir(contexto.projeto)
end

test.after = function()
  os.chdir(contexto.raiz)
  os.execute('rm -rf ' .. contexto.projeto)
  Relatorio.output = io.write
end

test['deve mutar so as linhas alteradas'] = function()
  local fonte = os.read('lib/Frete.lua')
  local arquivo = io.open('lib/Frete.lua', 'w')
  arquivo:write((fonte:gsub('if peso <= 0 then', 'if peso <= 0 then -- alterada')))
  arquivo:close()

  local total = Revisao.new{ raiz = contexto.raiz, base = 'master', isolado = true }:executar()

  assert(total.contagem.morto == 1, total.contagem.morto)
  assert(total.contagem.vivo == 2, total.contagem.vivo)
  assert(total.contagem.tempo == 0, total.contagem.tempo)
end

test['deve incluir arquivo novo inteiro'] = function()
  local arquivo = io.open('lib/Novo.lua', 'w')
  arquivo:write('return { a = function(x) return x > 1 end }\n')
  arquivo:close()

  local revisao = Revisao.new{ raiz = contexto.raiz, base = 'master', isolado = true }
  local total = revisao:executar()

  assert(revisao.falhas == 1, revisao.falhas)
  assert(total.contagem.morto + total.contagem.vivo == 0)
end

test['deve ignorar branch sem alteracao'] = function()
  local revisao = Revisao.new{ raiz = contexto.raiz, base = 'master', isolado = true }
  local total = revisao:executar()
  assert(revisao.falhas == 0, revisao.falhas)
  assert(total.contagem.morto == 0, total.contagem.morto)
end

return test
