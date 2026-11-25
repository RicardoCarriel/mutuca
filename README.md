# Mutuca

*Pica o seu código até os testes reagirem.*

Teste de mutação para projetos Lua no framework arken. O Mutuca altera um pedaço do código
por vez (`<` vira `<=`, `and` vira `or`, `10` vira `11`), roda os testes e avisa
quando nenhum deles percebe. Cobertura mostra que a linha foi executada; mutação
mostra se algum teste notaria um erro nela.

## Uso

Na raiz do projeto que será testado:

```bash
/caminho/do/mutuca/script/mutuca lib/Frete.lua
```

Os testes são procurados pela convenção de pastas: `lib/Frete.lua` em
`tests/lib/Frete` e `app/models/Pedido.lua` em `tests/models/Pedido`. Para usar
outra pasta, passe `--testes pasta` depois do arquivo.

Para experimentar:

```bash
cd exemplo
../script/mutuca lib/Frete.lua
```

```
V.VV.V...

lib/Frete.lua:7 [vivo]
-  if peso > 10 then
+  if peso >= 10 then
...
9 mutantes: 5 mortos, 0 por tempo, 4 vivos, 0 sem cobertura (0 descartados por não compilar)
```

| Marca | Situação |
|---|---|
| `.` | Morto: algum teste falhou |
| `T` | Os testes passaram do tempo limite, em geral por loop infinito |
| `V` | Vivo: os testes passaram com o código alterado |
| `S` | Vivo em linha que nenhum teste executa |

Nem todo sobrevivente é falha dos testes: alguns mutantes são equivalentes ao
código original. O nível em `error({...}, 0)` já é ignorado, porque não tem
efeito quando o erro é uma tabela. Para ignorar uma linha, termine-a com
`-- mutuca: ignora`.

## Isolamento

Um mutante pode pular um mock, apagar arquivo ou escapar de uma transação. Por
isso cada um roda em processo próprio, com `ARKEN_ENV=test`, sem rede (nem
local) e sem escrita fora das pastas temporárias. Os arquivos do projeto não são
alterados: o código mutado é injetado no `require`.

O processo roda numa pasta com links para o projeto e um `tmp/` descartável, que
repete só as pastas do `tmp/` original e é refeito a cada mutante. Testes que
gravam em outra pasta do projeto falham já sem mutação.

O isolamento usa o `sandbox-exec` do macOS. Sem ele, o Mutuca se recusa a rodar.
`--sem-isolamento` desliga essa proteção: use só se souber que o alvo e os testes
não têm efeito externo.

## Limites atuais

- Um arquivo por vez, em série.
- Sem suporte a testes que acessam banco.
- O alvo precisa ser carregado por `require`, e não pelo `config/profile.lua`.
- Depende de `arken`, `perl` e, para o isolamento, macOS.

## Testes

```bash
arken test:run $(find tests -name '*.lua')
```

## Créditos

O Mutuca é inspirado no [mutmut](https://github.com/boxed/mutmut), ferramenta de
teste de mutação para Python criada por Anders Hovmöller e distribuída sob a
licença BSD de 3 cláusulas. A ideia e o fluxo de trabalho vêm de lá; a
implementação em Lua, para o arken, foi escrita do zero.

Este projeto não é afiliado ao mutmut nem endossado por seus autores.

## Licença

BSD de 3 cláusulas. Veja [LICENSE](LICENSE).
