/* Sessão de Inclusão de Bibliotecas */
/* --------------------------------- */
#include<stdio.h>
#include<stdlib.h>

/* Configurações de Ambiente */
/* --------------------- */
#define TAM_MAX             1024
// #define DEBUG

/* Variáveis Globais */
/* ----------------- */
char linha[TAM_MAX]; /* Linha contendo 01 expressão regular */
int pos = 0; /* Posição do parser na linha */
char carac; /* Caracter atual */


/* Definição da estrutura de dados para as árvores de RegExp */
/* --------------------------------------------------------- */
enum RegExpTag {
        TAG_EMPTY,
        TAG_CHAR,
        TAG_STAR,
        TAG_CONCAT,
        TAG_UNION,
    };

    struct RegExp {
        char tag;
        union {
            struct {
                char c;
            } ch;
            struct {
                struct RegExp *filho;
            } un;
            struct {
                struct RegExp *filho1;
                struct RegExp *filho2;
            } bin;
        } u;
    };

    typedef struct RegExp RegExp;

/* Declaração dos Construtores */
/* --------------------------- */
RegExp *new_empty();
RegExp *new_char(char c);
RegExp *new_star(RegExp *filho);
RegExp *new_concat(RegExp *filho1, RegExp *filho2);
RegExp *new_union(RegExp *filho1, RegExp *filho2);

/* Implementação dos Construtores */
/* ------------------------------ */
RegExp *new_empty() {
    /* Cria a RegExp */
    RegExp * r = (RegExp*) malloc(sizeof(RegExp));

    /* Preenche */
    r->tag = TAG_EMPTY;

    return r;
}
RegExp *new_char(char c) {
    /* Cria a RegExp */
    RegExp * r = (RegExp*) malloc(sizeof(RegExp));

    /* Preenche */
    r->tag = TAG_CHAR;
    r->u.ch.c = c;

    return r;
}
RegExp *new_star(RegExp *filho) {
    /* Cria a RegExp */
    RegExp * r = (RegExp*) malloc(sizeof(RegExp));

    /* Preenche */
    r->tag = TAG_STAR;
    r->u.un.filho = filho;

    return r;
}
RegExp *new_concat(RegExp *filho1, RegExp *filho2) {
    /* Cria a RegExp */
    RegExp * r = (RegExp*) malloc(sizeof(RegExp));

    /* Preenche */
    r->tag = TAG_CONCAT;
    r->u.bin.filho1 = filho1;
    r->u.bin.filho2 = filho2;

    return r;
}
RegExp *new_union(RegExp *filho1, RegExp *filho2) {
    /* Cria a RegExp */
    RegExp * r = (RegExp*) malloc(sizeof(RegExp));

    /* Preenche */
    r->tag = TAG_UNION;
    r->u.bin.filho1 = filho1;
    r->u.bin.filho2 = filho2;

    return r;
}

/**
 * @brief Joga um erro de sintaxe informativo e encerra o programa.
 * 
 * @param posicao posição do erro de sintaxe dentro da regexp
 * @param c_recebido caracter que foi recebido
 * @param c_esperado caracter que era esperado se não fosse o erro de sintaxe
*/
void raiseSintaxError(int posicao, char c_recebido, char c_esperado) {
    printf("Erro se sintaxe na posição %d: esperava '%c', encontrei '%d'\n", posicao, c_esperado, c_recebido);
    exit(1);
}

/**
 * @brief Erro de RegExp maior que o buffer TAM_MAX
*/
raiseRegExpOverflowError() {
    printf("Erro: overflow no tamanho do buffer da RegExp.\n");
    exit(1);
}

/**
 * @brief Função recursiva que recebe uma árvore e imprime no STDOUT.
 * 
 * @param arvore ponteiro para a raíz da árvore
 * @param nivel nível do ponteiro na árvore. Se  arvore  é a raiz, o nível deve ser 0
*/
void print_arvore(RegExp* arvore, int nivel) {
    int i;

    /* Imprime a identação do nível */
    for (i = 0; i < nivel; i++) {
        printf("  ");
    }

    /* Imprime o conteúdo do nível */
    switch (arvore->tag)
    {
    case TAG_EMPTY:
        printf("EMPTY\n");
        break;
    case TAG_CHAR:
        printf("CHAR %c\n", arvore->u.ch.c); 
        break;
    case TAG_STAR:
        printf("STAR\n");
        print_arvore(arvore->u.un.filho, nivel + 1);
        break;
    case TAG_CONCAT:
        printf("CONCAT\n");
        print_arvore(arvore->u.bin.filho1, nivel + 1);
        print_arvore(arvore->u.bin.filho2, nivel + 1);
        break;
    case TAG_UNION:
        printf("UNION\n");
        print_arvore(arvore->u.bin.filho1, nivel + 1);
        print_arvore(arvore->u.bin.filho2, nivel + 1);
        break;
    }
}

/* Rotina principal do Parser */
/* -------------------------- */

void consome_caracter() {
    if (pos < TAM_MAX) {
        carac = linha[pos++];
    } else {
        raiseRegExpOverflowError();
    }
}

/* Declaração das Funções do Parser */
static RegExp *parse_regexp();
static RegExp *parse_uniao();
static RegExp *parse_concat();
static RegExp *parse_estrela();
static RegExp *parse_basico();

/* Implementação das Funções do Parser */
static RegExp *parse_regexp() {

}
static RegExp *parse_uniao() {
    RegExp *e1, *e2;

    e1 = parse_concat();
    if (carac == '|') {
        consome_caracter(); /* Consome e joga fora a '|' */
        e2 = parse_concat();
        e1 = new_union(e1, e2);
    }
    return e1;
}
static RegExp *parse_concat() {
    RegExp *e1, *e2;
    /* Parseia o primeiro filho */
    switch (carac) {
    case '\n': case '\0':
        /* code */
        break;
    case '|': case '*': case '(': case ')':
        break;
    default: /* Caracter normal */
        e1 = parse_estrela();
        break;
    }

    /* Parseia o segundo  filho */
    consome_caracter();
    switch (carac) {
    case '\n': case '\0':
        /* code */
        break;
    case '|': case '*': case '(': case ')':
        break;
    default: /* Caracter normal */
        e2 = parse_estrela();
        break;
    }
    return new_concat(e1, e2);
}
static RegExp *parse_estrela();
static RegExp *parse_basico();

int main(void) {
#ifdef DEBUG
    /* Teste de sanidade: construir árvore na mão. OK*/
    RegExp *ptArv;
    ptArv = new_union(
        new_concat(
            new_char('a'), 
            new_char('b')),
        new_char('c')
    );

    print_arvore(ptArv, 0);
#endif
    
    /* Declaração de variáveis úteis */
    int i;
    RegExp *ptCabeca; /* Ponteiro para o início da árvore (nível 0)*/
    RegExp *no; /* Referência mutável da árvore*/

    /* Le a regexp (linha inteira) */
    while( fgets(linha, TAM_MAX, stdin) != EOF ) {
        consome_caracter();
        parseia_regexp();
    }
    return 0;
}