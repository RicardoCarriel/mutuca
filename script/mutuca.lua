local raiz = os.abspath(arg[0]):gsub('/script/mutuca%.lua$', '')
package.path = raiz .. '/lib/?.lua;' .. package.path

local routine  = require('arken.routine')
local Campanha = require('mutuca.Campanha')
local params   = routine.parseArgs(arg)

local campanha = Campanha.new{
  raiz      = raiz,
  alvo      = params[1],
  testes    = params.testes,
  isolado   = params['sem-isolamento'] == nil
}

campanha:executar()
