# Gramática
Vamos estabelecer a ordem de precedência das operações, do mais fraco para o mais forte:
1. União 
2. Concatenação
3. Estrela


```
regexp  -> uniao
uniao   -> concat( '|' uniao )?
concat  -> star(concat)?
star    -> star'*' |
           simples
simples -> CARACTERE |
           '(' regexp ')'
```

# Uso do Repositório

## Rodar testes

Basta executar o comando:
```
make clean && make && ./tests/run_tests.sh
```

## Debugar um caso específico

Aí você precisa colocar o conteúdo do caso/teste no arquivo `input.txt`, na raíz e executar o comando:
```
make clean && make debug && ./parser < ./tests/input.txt
```
