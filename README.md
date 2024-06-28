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

Os caracteres `|*()` e também `\n` e `\0` são considerados especiais.
Todos os outros caracteres são considerados "normais".

O operador de estrela tem precedência mais forte que concatenação, que por
sua vez tem preferência mais forte que união. A regex da string vazia é
representada por uma concatenação de 0 elementos. A gramática fica assim:

    Regexp -> Uniao
    Uniao -> lista de uma ou mais concatenações, separadas por `|`
    Concat -> lista potencialmente vazia de itens estrelados
    Estrela -> item básico, seguido de zero ou mais estrelas
    Basico -> um caractere não-especial, ou uma regexp entre parênteses.

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
