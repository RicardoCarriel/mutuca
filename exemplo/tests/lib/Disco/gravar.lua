local Disco = require('Disco')

local test = {}

test['deve gravar so no tmp'] = function()
  assert(Disco.gravar('tmp/permitido') == true)
  assert(Disco.gravar('lib/proibido') == false)
end

return test
