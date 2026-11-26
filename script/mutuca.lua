local raiz = os.abspath(arg[0]):gsub('/script/mutuca%.lua$', '')
package.path = raiz .. '/lib/?.lua;' .. package.path

local routine  = require('arken.routine')
local Campanha = require('mutuca.Campanha')
local Revisao  = require('mutuca.Revisao')
local params   = routine.parseArgs(arg)
local isolado  = params['sem-isolamento'] == nil

if params.diff then
  local base = params.diff == true and 'origin/master' or params.diff
  Revisao.new{ raiz = raiz, base = base, isolado = isolado }:executar()
else
  Campanha.new{ raiz = raiz, alvo = params[1], testes = params.testes, isolado = isolado }:executar()
end
