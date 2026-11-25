local Campanha = require('mutuca.Campanha')

local test = {}

test['deve aceitar base verde'] = function()
  local status = pcall(Campanha.validarBase, { ok = 1, failure = 0, carregado = true })
  assert(status == true)
end

test['deve recusar base com falha'] = function()
  local status, erro = pcall(Campanha.validarBase, { ok = 1, failure = 1, falha = 'x', carregado = true })
  assert(status == false and erro == 'os testes falham sem mutação: x', erro)
end

test['deve recusar base sem teste'] = function()
  local status, erro = pcall(Campanha.validarBase, { ok = 0, failure = 0, carregado = true })
  assert(status == false and erro == 'nenhum teste executado', erro)
end

test['deve recusar alvo que nao foi carregado'] = function()
  local status, erro = pcall(Campanha.validarBase, { ok = 1, failure = 0, carregado = false })
  assert(status == false and erro == 'os testes não carregaram o arquivo alvo por require', erro)
end

test['deve recusar base por tempo ou interrompida'] = function()
  local status, erro = pcall(Campanha.validarBase, { tempo = true })
  assert(status == false and erro == 'os testes sem mutação passaram do tempo limite', erro)
  status, erro = pcall(Campanha.validarBase, { interrompido = true })
  assert(status == false and erro == 'os testes sem mutação encerraram sem resultado', erro)
end

return test
