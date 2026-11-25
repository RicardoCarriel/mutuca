local Frete = {}

Frete.calcular = function(peso)
  if peso <= 0 then
    return nil
  end
  if peso > 10 then
    return 50
  end
  return peso * 2
end

return Frete
