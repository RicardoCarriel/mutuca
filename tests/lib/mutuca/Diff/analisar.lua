local Diff = require('mutuca.Diff')

local test = {}

test['deve ler as linhas novas de cada arquivo'] = function()
  local texto = table.concat({
    'diff --git a/lib/A.lua b/lib/A.lua',
    '--- a/lib/A.lua',
    '+++ b/lib/A.lua',
    '@@ -3 +3 @@ local a',
    '-x = 1',
    '+x = 2',
    '@@ -10,0 +11,2 @@',
    '+y = 1',
    '+++ b/falso.lua',
    '@@ -20,3 +22,0 @@',
    '-z = 1',
    'diff --git a/lib/B.lua b/lib/B.lua',
    '--- a/lib/B.lua',
    '+++ /dev/null',
    '@@ -1,2 +0,0 @@',
    '-w = 1'
  }, '\n')

  local arquivos = Diff.analisar(texto)
  local linhas = {}
  for numero, alterada in pairs(arquivos['lib/A.lua']) do
    assert(alterada == true)
    table.insert(linhas, numero)
  end
  table.sort(linhas)

  assert(table.concat(linhas, ',') == '3,11,12', table.concat(linhas, ','))
  assert(arquivos['lib/B.lua'] == nil)
  assert(arquivos['falso.lua'] == nil)
end

test['deve aceitar diff vazio'] = function()
  assert(next(Diff.analisar('')) == nil)
end

return test
