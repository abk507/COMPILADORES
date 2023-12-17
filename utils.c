// Tabela de SImbolos
#include <stdio.h>

enum
{
    INT, 
    LOG,
    REG
};

/*+=============================================================
| UNIFAL = Universidade Federal de Alfenas.
| BACHARELADO EM CIENCIA DA COMPUTACAO.
| Trabalho......: Registro e verificacao de tipos
| Disciplina....: Teoria de Linguagens e Compiladores
| Professor.....: Luiz Eduardo da Silva
| Aluno.........: Arthur Barros Klimas
| Aluna.........: Maria Eduarda Pires
| Data..........: 14/12/2023
+=============================================================*/


char nomeTipo[3][4] = {
    "INT", "LOG", "REG"
};

// criar uma estrutura e operações para manipular uma lista de campos

typedef struct no *ptno;

typedef struct no {
    char id[10];   
    int pos;
    int desl;
    int tam;
    int tip; 
    ptno prox;
} no;



ptno inserir(ptno listaCampos, char id[100], int tip, int pos, int desl, int tam) {
    ptno novoNo = (ptno)malloc(sizeof(struct no));
    ptno L = listaCampos;
    strcpy(novoNo->id, id);
    novoNo->tip = tip;
    novoNo->pos = pos;
    novoNo->desl = desl;
    novoNo->tam = tam; 
    novoNo->prox = NULL;

    while (L && L->prox) {
        L = L->prox;
    }   
    if (L) {
        L->prox = novoNo;
    } else {
        listaCampos = novoNo;
    }
    return listaCampos;
}

ptno busca (ptno listaCampos, char id[100]) {
    while (listaCampos && strcmp(listaCampos->id, id) != 0) {
        listaCampos = listaCampos->prox;
    }
    return listaCampos;
}



#define TAM_TAB 100

//acrescentar campos na tabela
struct elemTabSimbolos 
{
    char id[100];   // nome do identificador   
    int end;        // endereco
    int tip;        // tipo
    int tam; 
    int pos;
    ptno listaCampos;        // essa posição se for um registro recebe uma estrutura de nós com os campos
} tabSimb[TAM_TAB], elemTab;

int posTab = 0;    // indica a próxima posição livre para inserção

int buscaSimbolo (char *s) 
{
    int i;
    for (i = posTab - 1; strcmp(tabSimb[i].id, s) && i >= 0; i--) 
            ;
    if (i == -1) 
    {
        char msg[200];
        sprintf(msg, " O campo [%s] não existe na estrutura.", s);
        //yyerror(msg);
    }
    return i;
}

void insereSimbolo (struct elemTabSimbolos elem) 
{
    int i;          
    if (posTab == TAM_TAB)
        yyerror("Tabela de Simbolos cheia!");                                                    //
    for (i = posTab - 1; strcmp(tabSimb[i].id, elem.id) && i >= 0; i--) 
            ;
    if (i != -1) 
    {    // caso encontre um nome igual ao que deseja inserir já existente na tabela
    char msg[200];    // se o valor for igual a -1 a tabela foi totalmente percorrida e não foram encontradas elementos duplicados
    sprintf(msg, "Identificador [%s] duplicado!", elem.id);
    yyerror(msg);
    }
    tabSimb[posTab++] = elem;         // insere o elemento na posição posTab++
}

void mostraTabela() 
{
    puts("Tabela de Simbolos");
    puts("------------------");
    printf("%30s | %s | %s | %s | %s | %s\n", "ID", "END", "TIP", "TAM", "POS", "CAMPOS");
    for(int i = 0; i < 90; i++)
        printf("-");
    //printf("\n%30s | %3s | %3s | %3s | %3s |", "inteiro", " -1", "INT", "1", "0");
    //printf("\n%30s | %3s | %3s | %3s | %3s |", "logico", " -1", "LOG", "1", "1");
    for(int i = 0; i < posTab; i++) {
        printf("\n%30s | %3d | %s | %3d | %3d |",  
                tabSimb[i].id,
                tabSimb[i].end,
                nomeTipo[tabSimb[i].tip],
                tabSimb[i].tam,
                tabSimb[i].pos
            );
        if(strcmp(nomeTipo[tabSimb[i].tip], "REG") == 0) {    
            ptno temp = tabSimb[i].listaCampos;  // Usar um ponteiro temporário

            while(temp) {  // Iterar sobre a lista com o ponteiro temporário
                if(temp->prox) {
                printf("(%s, %s, %d, %d, %d) => ", temp->id, nomeTipo[temp->tip], temp->pos, temp->desl, temp->tam);
                } else {
                    printf("(%s, %s, %d, %d, %d)", temp->id, nomeTipo[temp->tip], temp->pos, temp->desl, temp->tam);
                }
                temp = temp->prox;
        }
    }
    }
    puts("");
}

// Pilha Semantica
#define TAM_PIL 100
int pilha[TAM_PIL];
int topo = -1;      

void empilha (int valor) 
{
    if (topo == TAM_PIL)
        yyerror ("Pilha semantica cheia!");
    pilha[++topo] = valor;
}

int desempilha (void) 
{
    if (topo == -1)
        yyerror ("Pilha semantica vazia!");
    return pilha[topo--];      // se a pilha não for vazia retorna a nova posição da pilha após desempilhar
}

// tipo1 e tipo2 são os tipos esperados na expressão
// ret é o tipo que será empilhado com resultado da expressão
void testaTipo (int tipo1, int tipo2, int ret) {
    int t2 = desempilha();
    int t1 = desempilha();
    if (t1 != tipo1 || t2 != tipo2) 
        yyerror("Incompatibilidade de tipo!");
    empilha(ret);
}