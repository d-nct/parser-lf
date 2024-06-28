/**
 * @file parser.c
 * @brief Dada várias expressões regulares, o programa constroi uma árvore.
 * @author Samuel Sampaio Diniz - 122076523
 * @author Daniel Nocito        - 122076971
*/


/* Inclusão de Bibliotecas */
/* ----------------------- */
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

/* Configurações de Ambiente */
/* --------------------- */
#define TAM_BUFFER_REGEXP   10

#ifdef DEBUG
    #define LOG(fmt, ...) printf("DEBUG: " fmt "\n", ##__VA_ARGS__)
#else
    #define LOG(fmt, ...) 
#endif

/* Variáveis Globais */
/* ----------------- */
const char *input; /* Ponteiro que direciona para um vetor de caracteres contendo 01 expressão regular */
int pos; /* Posição do parser na linha */
int num_parenteses_abertos = 0;

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
    if (c_recebido == '\n' || c_recebido == '\0') {
        printf("Erro de sintaxe na posição %d: esperava '%c', encontrei '\\n'\n", posicao, c_esperado);
    } else if (c_esperado == '\n' || c_esperado == '\0') {
        printf("Erro de sintaxe na posição %d: esperava '\\n', encontrei '%c'\n", posicao, c_recebido);
    } else {
        printf("Erro de sintaxe na posição %d: esperava '%c', encontrei '%c'\n", posicao, c_esperado, c_recebido);
    }

    exit(1);
}

/**
 * @brief Erro de RegExp maior que o buffer TAM_BUFFER_REGEXP
*/
void raiseRegExpOverflowError() {
    printf("Erro: overflow no tamanho do buffer da RegExp.\n");

    exit(2);
}

/**
 * @brief Caracter espacial inesperado na posição
*/
/*
 void raiseSpecialCharError(char c, int pos){
     printf("Caracter especial não esperado!\n");
 }
*/

/**
 * @brief Erro lançado caso haja algo fora do comum
*/
void raiseSuddenEnd(){
    printf("Erro inesperado! Fim do programa!\n");

    exit(3);
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
    LOG("Consultado: %c", input[pos]);
    return input[pos];
}

void consome_caracter() {
    LOG("Consumido: %c", input[pos]);
    /* Checa se abrimos parênteses */
    if (input[pos] == '(') {
        num_parenteses_abertos++;
    }

    /* Consome o caractere */
    pos++;
  
    /* Confirma que não vamos acessar memória que não é do programa */ 
    if (pos > TAM_BUFFER_REGEXP){
        LOG("pos: %d    buff: %d\n", pos, TAM_BUFFER_REGEXP);
        raiseRegExpOverflowError();
    }
}

void exige_caractere(char c) {
    if (input[pos] == c) {
        consome_caracter();
    } else {
        LOG("Erro ao consumir caractere");
        raiseSintaxError(pos, input[pos], c);
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
    LOG("entrei em: parse_regexp");
    RegExp *e;
    char c = atual_caracter();
}

static RegExp *parse_uniao() {
    LOG("entrei em: parse_union");
    RegExp *e1, *e2;
}

static RegExp *parse_concat() {
    LOG("entrei em: parse_concat");
    RegExp *e1, *e2;  
} 

static RegExp *parse_estrela() {
    LOG("entrei em: parse_estrela");
    RegExp *e;
}

static RegExp *parse_basico() {
    LOG("entrei em: parse_basico");
    RegExp *e;
}

int main(void) {


    /* Teste de sanidade: construir árvore na mão. OK*/
  /*
    RegExp *ptArv;
    ptArv = new_union(
        new_concat(
            new_char('a'), 
            new_char('b')),
        new_char('c')
    );

    print_arvore(ptArv, 0);
*/
    char linha[TAM_BUFFER_REGEXP];

    while(fgets(linha, sizeof(linha), stdin)){
        pos = 0;
        LOG("linha lida: %s", linha);
        input = linha;

        /* Trata o caso linha vazia */
        if (linha[strlen(linha) - 1] == '\n'){
            linha[strlen(linha) - 1] = '\0'; /*remove o caractere newline*/
        }

        /* Ignora linhas comentadas com $ */
        if (linha[0] != '$') { 
        /* Parseia a linha */
        RegExp *ptCabeca = parse_regexp(); /* ponteiro para o inicio da arvore (nivel 0)*/

        /* Imprime para o usuário */
        print_arvore(ptCabeca, 0);
        }
    }
    
    return 0;
}
