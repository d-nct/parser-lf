/*Autores: 
    - Samuel Sampaio Diniz - 122076523
    - Daniel Nocita - (...)
*/


/* Sessão de Inclusão de Bibliotecas */
/* --------------------------------- */
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

/* Configurações de Ambiente */
/* --------------------- */
#define TAM_MAX             1024
// #define DEBUG

/* Variáveis Globais */
/* ----------------- */
const char *input; /* Ponteiro que direciona para um vetor de caracteres contendo 01 expressão regular */
int pos; /* Posição do parser na linha */

/* Definição da estrutura de dados para as árvores de RegExp */
/* --------------------------------------------------------- */
enum RegExpTag {
        TAG_EMPTY,
        TAG_CHAR,
        TAG_STAR,
        TAG_CONCAT,
        TAG_UNION,
    };

typedef struct RegExp {
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
} RegExp;

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
    printf("Erro se sintaxe na posição %d: esperava '%c', encontrei '%c'\n", posicao, c_esperado, c_recebido);
    exit(1);
}

/**
 * @brief Erro de RegExp maior que o buffer TAM_MAX
*/
void raiseRegExpOverflowError() {
    printf("Erro: overflow no tamanho do buffer da RegExp.\n");
    exit(1);
}

/**
 * @brief Caracter espacial inesperado na posição
*/
void raiseSpecialCharError(){
    printf("Caracter especial não esperado!\n");
    exit(1);
}

/**
 * @brief Erro lançado caso haja algo fora do comum
*/
void raiseSuddenEnd(){
    printf("Erro inesperado! Fim do programa!\n");
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
char atual_caracter(){
    return input[pos];
}

void consome_caracter() {
    pos++;
    /*verifica se a incrementação ultrapassou o limite*/
    if (pos > TAM_MAX){
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
    return parse_uniao();
}

static RegExp *parse_uniao() {
    RegExp *e1, *e2;

    e1 = parse_concat();
    while (atual_caracter() == '|') {
        consome_caracter(); /* Consome '|' avançando uma posição */
        e2 = parse_concat();
        e1 = new_union(e1, e2);
    }
    return e1;
}

static RegExp *parse_concat() {
    RegExp *e1, *e2;  

    e1 = NULL;  
    /*Loop para analisar caracteres enquanto não encontra '|' ou ')'*/
    while (atual_caracter() && atual_caracter() != '|' && atual_caracter() != ')') {
        e2 = parse_estrela();
        /* Se e1 ainda não foi definida*/ 
        if (e1 == NULL) {
            /*Define e1 como a primeira sub-expressão encontrada*/ 
            e1 = e2;  
        } else {  
            /*Concatena a nova sub-expressão com a já existente*/
            e1 = new_concat(e1, e2); 
        }
    }
    /*Retorna a árvore de sintaxe da concatenação ou uma expressão vazia se nenhuma sub-expressão foi encontrada*/
    return e1 == NULL ? new_empty() : e1;
} 

static RegExp *parse_estrela() {
    RegExp *base;

    /*Analisa a expressão básica*/
    base = parse_basico(); 
    
    while (atual_caracter() == '*') {
        /*Consome e ignora o '*' */
        consome_caracter(); 
        base = new_star(base);
    }

    return base;
}

static RegExp *parse_basico() {
    char c = atual_caracter(); 

    if (c == '(') { 
        /*Consome o '('*/
        consome_caracter();
        /*Analisa a sub-expressão entre parênteses*/
        RegExp *subExpressao = parse_regexp();
        /*Verifica se a sub-expressão fecha corretamente*/ 
        if (atual_caracter() != ')') {  
            raiseSintaxError(pos, atual_caracter(), ')');  
        }
        /*Consome o ')'*/
        consome_caracter(); 
        return subExpressao; 

    } else if (c == '|' || c == '(' || c == ')' || c == '*') {  // Verifica se o caractere é especial e inesperado
        raiseSpecialCharError(); 

    } else if (c) {  // Verifica se há um caractere válido
        consome_caracter();
        return new_char(c);  // Retorna uma expressão regular com o caractere

    }

    raiseSuddenEnd(); 
    return NULL;  // Retorna NULL para evitar warning do compilador
}

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

    char linha[1024];
    while(fgets(linha, sizeof(linha), stdin)){
        pos = 0;
        input = linha;
        if (linha[strlen(linha) - 1] == '\n'){
            linha[strlen(linha) - 1] = '\0'; /*remove o caractere newline*/
        }

        RegExp *ptCabeca = parse_regexp(); /*ponteiro para o inicio da arvore (nivel 0)*/
        print_arvore(ptCabeca, 0);
        printf("\n\n");
    }
    
    return 0;
}
