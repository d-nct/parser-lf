# O Programa
O objetivo do programa é implementar um parser para expressões regulares simples.
A ideia é receber uma RegExp como input do usuário (pelo `stdin`) por linha e devolver a árvore construída seguindo a gramática.

## Gramática
## Universo de Caracteres
Os caracteres `|*()` são os operadores, que veremos mais a frente.
Os caracteres `\n` e `\0`, além dos operadores, são considerados especiais.
Todos os outros caracteres são considerados "normais".

### Precedência dos Operadores
Vamos estabelecer a ordem de precedência das operações, do mais fraco para o mais forte:

1. União 
2. Concatenação
3. Estrela

### Regras de Derivação
As regras da gramática são:
```
    Regexp  -> Uniao
    Uniao   -> lista de uma ou mais concatenações, separadas por `|`
    Concat  -> lista potencialmente vazia de itens estrelados
    Estrela -> item básico, seguido de zero ou mais estrelas
    Basico  -> um caractere não-especial, ou uma regexp entre parênteses.
```

> Note que a string vazia é uma _concatenação_ de 0 elementos.

# Compilando e Rodando o Programa

A forma mais trabalhosa é compilar usando o comando:
```sh
gcc -Wall -Wextra -ansi -o parser main.c
```

A forma mais fácil é com usando `make`, com o comando:
```
make
```

## Modo de Depuração
Quando compilado com a flag `-DDEBUG`, o programa entra em modo de depuração, imprimindo 

- Quando há chamada de função do parseamento.
- Quando há consultas aos caracteres de input.
- Quando e quais caracteres são consumidos.


## Testando

Para testar diversos casos de uma só vez, o script `run_tests.sh` roda todos os testes e compara o resultado (saída no `stdout`) com o resultado esperado (na forma de arquivo em texto plano).

Caso o teste falhe em um caso, o programa mostra ambos os resultados: obtido e esperado. O comando é:
```
make clean && make && ./tests/run_tests.sh
```

Para entrar em detalhes no debug de um caso específico, usamos a macro `-DDEBUG`, que pode ser compilada com `make debug`.

Como o programa fica extremamente verborrágico, a sugestão é que seja passado um caso por vez, por exemplo, o caso `X`, da seguinte forma:
```
make clean && make debug && ./parser < ./tests/casoX_input.txt
```

# Autores

- Daniel Nocito - 122076971
- Samuel Sampaio - 122076523
