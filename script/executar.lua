local raiz = os.abspath(arg[0]):gsub('/script/executar%.lua$', '')
package.path = package.path .. ';' .. raiz .. '/lib/?.lua'

local json     = require('arken.json')
local Execucao = require('mutuca.Execucao')
local execucao = Execucao.new(json.decode(os.read(arg[1])))

execucao:executar()
