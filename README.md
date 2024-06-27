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
simples -> caracter |
           '(' regexp ')'
```

## Testes 

(ab)
$()*
$(a
$(a))

