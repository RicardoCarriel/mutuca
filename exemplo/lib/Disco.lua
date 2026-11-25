local Disco = {}

Disco.gravar = function(caminho)
  local arquivo = io.open(caminho, 'w')
  if arquivo == nil then
    return false -- mutuca: ignora
  end
  arquivo:close()
  return true
end

return Disco
