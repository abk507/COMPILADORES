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


%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lexico.c"
#include "utils.c"
int contaVar = 0;
int rotulo = 0;
int ehRegistro = 0;
int tipo;
int tam; // tamanho da estrutura qdo percorre expressão de acesso
int des = 0; // deslocamento para chegar no campo
int pos; // posicao do tipo na tabela de simbolos
int somatoriaTamanho = 0; // para o registro
int posicaoNova = 2; //gambiarra sinistra, procurar solução melhor depois
int achado = 0;
ptno listaCampos;
int end = 0;
%}

%token T_PROGRAMA
%token T_INICIO
%token T_FIM
%token T_IDENTIF
%token T_LEIA
%token T_ESCREVA
%token T_ENQTO
%token T_FACA
%token T_FIMENQTO
%token T_SE
%token T_ENTAO
%token T_SENAO
%token T_FIMSE
%token T_ATRIB
%token T_VEZES
%token T_DIV
%token T_MAIS
%token T_MENOS
%token T_MAIOR
%token T_MENOR
%token T_IGUAL
%token T_E
%token T_OU
%token T_V
%token T_F
%token T_NUMERO
%token T_NAO
%token T_ABRE
%token T_FECHA
%token T_LOGICO
%token T_INTEIRO
%token T_DEF
%token T_FIMDEF
%token T_REGISTRO
%token T_IDPONTO

%start programa

%left T_E T_OU
%left T_IGUAL
%left T_MAIOR T_MENOR
%left T_MAIS T_MENOS
%left T_VEZES T_DIV

%%

programa 
   : cabecalho definicoes variaveis 
        { 
            mostraTabela();
            empilha (contaVar);
            if (contaVar)
               fprintf(yyout, "\tAMEM\t%d\n", contaVar); 
        }
     T_INICIO lista_comandos T_FIM
        { 
            int conta = desempilha();
            if (conta)
               fprintf(yyout, "\tDMEM\t%d\n", conta); 
        }
        { fprintf(yyout, "\tFIMP\n"); }
   ;

cabecalho
   : T_PROGRAMA T_IDENTIF
       { 
         fprintf(yyout, "\tINPP\n");
         strcpy(elemTab.id, "inteiro");
         elemTab.end = -1;
         elemTab.tip = INT;
         elemTab.tam = 1;
         elemTab.pos = 0;
         insereSimbolo(elemTab);

         strcpy(elemTab.id, "logico");
         elemTab.end = -1;
         elemTab.tip = LOG;
         elemTab.tam = 1;
         elemTab.pos = 1;
         insereSimbolo(elemTab);
       }
   ;

tipo
   : T_LOGICO
         { 
            tipo = LOG; 
            // TODO #1
            // Além do tipo, precisa guardar o TAM (tamanho) do
            // tipo e a POS (posição) do tipo na tab. símbolos
            tam = 1;
            pos = 1;

            somatoriaTamanho += tam;
         }
   | T_INTEIRO
         { 
            tipo = INT;
            // idem 
            tam = 1;
            pos = 0;

            somatoriaTamanho += tam;
        }
   | T_REGISTRO T_IDENTIF
         { 
            tipo = REG; 
            // TODO #2
            // Aqui tem uma chamada de buscaSimbolo para encontrar
            // as informações de TAM e POS do registro

            int aux = buscaSimbolo(atomo);
            if (aux != -1){
               tam = tabSimb[aux].tam;
               pos = tabSimb[aux].pos;

               somatoriaTamanho += tam;
            }
         }
   ;

definicoes
   : define definicoes
   | /* recursividade */
   ;

define 
   : T_DEF
        {
            // TODO #3
            // Iniciar a lista de campos
            elemTab.listaCampos = NULL;
            des = 0;
        } 
   definicao_campos T_FIMDEF T_IDENTIF
       {
           // TODO #4
           // Inserir esse novo tipo na tabela de simbolos
           // com a lista que foi montada
           strcpy(elemTab.id, atomo);
           elemTab.end = -1;
           elemTab.tip = REG;
           elemTab.tam = somatoriaTamanho;
           elemTab.pos = posicaoNova; // a gambiarra pra forçar ajeitar a pos
           insereSimbolo(elemTab);

           somatoriaTamanho = 0;
           posicaoNova++; //aumenta a pos gambiarra
       }
   ;

definicao_campos
   : tipo lista_campos definicao_campos
   | tipo lista_campos
   ;

lista_campos
   : lista_campos T_IDENTIF
      {
         // TODO #5
         // acrescentar esse campo na lista de campos que
         // esta sendo construida
         // o deslocamento (endereço) do próximo campo
         // será o deslocamento anterior mais o tamanho desse campo

         elemTab.listaCampos = inserir(elemTab.listaCampos, atomo, tipo, pos, des, tam);
         //printf("inserindo campo %s %d %d %d %d    ", atomo, tipo, pos, des, tam);
         des += tam;

         /*ptno novoCampo = (ptno)malloc(sizeof(struct no)); //criando o novo nó pra ser adicionado
         strcpy(novoCampo->id, atomo);
         novoCampo->tip = tipo;
         novoCampo->desl = elemTab.tam; // deslocamento é o tamanho
         novoCampo->tam = elemTab.tam;
         novoCampo->prox = elemTab.listaCampos; // empilhando
         elemTab.listaCampos = novoCampo; // novo topo da lista
         elemTab.tam++; // mais 1 tamanho*/
      }
   | T_IDENTIF
      {
        // idem
        // copiar e colar aqui, pois o outro era da recursão
        elemTab.listaCampos = inserir(elemTab.listaCampos, atomo, tipo, pos, des, tam);
        des += tam;
         //printf("inserindo campo %s %d %d %d %d    ", atomo, tipo, pos, des, tam);

         /*ptno novoCampo = (ptno)malloc(sizeof(struct no)); //criando o novo nó pra ser adicionado
         strcpy(novoCampo->id, atomo);
         novoCampo->tip = tipo;
         novoCampo->pos = -1; // Só pra inicializar
         novoCampo->desl = elemTab.tam; // deslocamento é o tamanho
         novoCampo->tam = elemTab.tam;
         novoCampo->prox = elemTab.listaCampos; // empilhando
         elemTab.listaCampos = novoCampo; // novo topo da lista
         elemTab.tam++; // mais 1 tamanho*/
      }
   ;

variaveis
   : /* vazio */
   | declaracao_variaveis
   ;

declaracao_variaveis
   : tipo lista_variaveis declaracao_variaveis
   | tipo lista_variaveis
   ;

lista_variaveis
   : lista_variaveis
     T_IDENTIF 
        { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            // TODO #6
            // Tem outros campos para acrescentar na tab. símbolos
            elemTab.tam = tam;
            elemTab.pos = pos;
            insereSimbolo (elemTab);
            // TODO #7
            // Se a variavel for registro
            // contaVar = contaVar + TAM (tamanho do registro)
            if (tipo == REG){
               contaVar += tam;
            }
            else{
               contaVar++; 
            }
        }
   | T_IDENTIF
       { 
            strcpy(elemTab.id, atomo);
            elemTab.end = contaVar;
            elemTab.tip = tipo;
            elemTab.tam = tam;
            elemTab.pos = pos;
            // idem
            insereSimbolo (elemTab);
            // bidem 
           if (tipo == REG){
               contaVar += tam;
            }
            else{
               contaVar++; 
            }
       }
   ;

lista_comandos
   : /* vazio */
   | comando lista_comandos
   ;

comando
   : entrada_saida
   | atribuicao
   | selecao
   | repeticao
   ;

entrada_saida
   : entrada
   | saida 
   ;

entrada
   : T_LEIA expressao_acesso
       {    
         
          int pos = buscaSimbolo (atomo);
          // TODO #8
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de leituras
          if (ehRegistro) {
            ptno temp = tabSimb[buscaSimbolo(atomo)].listaCampos;
              while (temp) {
                  fprintf(yyout, "\tLEIA\n");
                  fprintf(yyout, "\tARZG\t%d\n", temp->desl);
                  temp = temp->prox;
              }
          } else {
            fprintf(yyout, "\tLEIA\n"); 
            fprintf(yyout, "\tARZG\t%d\n", tabSimb[pos].end);
          }
       }
   ;

saida
   : T_ESCREVA expressao
       {  
          desempilha(); 
          // TODO #9
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de escritas
          if (ehRegistro) { // basicamente a mesma coisa
              for (int i = 0; i <= tam; i++) {
                  fprintf(yyout, "\tESCR\n"); // Escreva o valor do campo
                  desempilha(); 
              }
          } else {
            fprintf(yyout, "\tESCR\n");
          } 
      }
   ;

atribuicao
   : expressao_acesso
       { 
         // TODO #10 - FEITO
         // Tem que guardar o TAM, DES e o TIPO (POS do tipo, se for registro)
          empilha(tam);
          empilha(des);
          empilha(tipo);
       }
     T_ATRIB expressao
       { 
          int tipexp = desempilha();
          int tipvar = desempilha();
          int des = desempilha();
          int tam = desempilha();
          if (tipexp != tipvar)
             yyerror("Incompatibilidade de tipo!");
          // TODO #11 - FEITO
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de ARZG
          for (int i = 0; i < tam; i++)
             fprintf(yyout, "\tARZG\t%d\n", des + i); 
       }
   ;

selecao
   : T_SE expressao T_ENTAO 
       {  
          int t = desempilha();
          if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
          fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
          empilha(rotulo);
       }
     lista_comandos T_SENAO 
       {  
           fprintf(yyout, "\tDSVS\tL%d\n", ++rotulo);
           int rot = desempilha(); 
           fprintf(yyout, "L%d\tNADA\n", rot);
           empilha(rotulo); 
       }
     lista_comandos T_FIMSE
       {  
          int rot = desempilha();
          fprintf(yyout, "L%d\tNADA\n", rot);  
       }
   ;

repeticao
   : T_ENQTO 
       { 
         fprintf(yyout, "L%d\tNADA\n", ++rotulo);
         empilha(rotulo);  
       }
     expressao T_FACA 
       {  
         int t = desempilha();
         if (t != LOG)
            yyerror("Incompatibilidade de tipo!");
         fprintf(yyout, "\tDSVF\tL%d\n", ++rotulo); 
         empilha(rotulo);
       }
     lista_comandos T_FIMENQTO
       { 
          int rot1 = desempilha();
          int rot2 = desempilha();
          fprintf(yyout, "\tDSVS\tL%d\n", rot2);
          fprintf(yyout, "L%d\tNADA\n", rot1);  
       }
   ;

expressao
   : expressao T_VEZES expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tMULT\n");  }
   | expressao T_DIV expressao
       {  testaTipo(INT,INT,INT); fprintf(yyout, "\tDIVI\n");  }
   | expressao T_MAIS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSOMA\n");  }
   | expressao T_MENOS expressao
      {  testaTipo(INT,INT,INT); fprintf(yyout, "\tSUBT\n");  }
   | expressao T_MAIOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMMA\n");  }
   | expressao T_MENOR expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMME\n");  }
   | expressao T_IGUAL expressao
      {  testaTipo(INT,INT,LOG); fprintf(yyout, "\tCMIG\n");  }
   | expressao T_E expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tCONJ\n");  }
   | expressao T_OU expressao
      {  testaTipo(LOG,LOG,LOG); fprintf(yyout, "\tDISJ\n");  }
   | termo
   ;

expressao_acesso
   : T_IDPONTO
       {   //--- Primeiro nome do registro
         // TODO #12
           if (!ehRegistro) {
               ehRegistro = 1;
               // 1. busca o símbolo na tabela de símbolos
               int achado = buscaSimbolo(atomo);

               // 2. se não for do tipo registro tem erro
               if (tabSimb[achado].tip != REG) {
                  char msg[200];
                  sprintf(msg, "Erro: O campo [%s] não é registro!", atomo);
                  yyerror(msg);
               }

               // 3. guardar o TAM, POS e DES desse t_IDENTIF
               tam = tabSimb[achado].tam;
               pos = tabSimb[achado].pos;
               des = 0;
               listaCampos = tabSimb[achado].listaCampos;
           } else {
               // 1. busca esse campo na lista de campos
               ptno temp = busca(listaCampos, atomo);

               int encontrado = 0;

               // 2. se não encontrar, erro
               while (temp) {
                   if (strcmp(temp->id, atomo) == 0) {
                       encontrado = 1;
                       break;
                   }
                   temp = temp->prox;
               }

               if (!encontrado) {
                   yyerror("Erro: Campo não encontrado no registro");
               }

               // 3. se encontrar e não for registro, erro
               if (temp->tip != REG) {
                   yyerror("Erro: O campo não é do tipo registro.");
               }

               // 4. guardar o TAM, POS e DES desse CAMPO
               tam = temp->tam;
               pos = temp->pos;
               des = temp->desl;
           }
       }
     expressao_acesso
   | T_IDENTIF
       {   
           if (ehRegistro) {
               // TODO #13
               // 1. buscar esse campo na lista de campos
               ptno temp = busca(listaCampos, atomo);
               int encontrado = 0;

               // 2. Se não encontrar, erro
               while (temp) {
                   if (strcmp(temp->id, atomo) != 0) {
                       encontrado = 1;
                       break;
                   }
                   temp = temp->prox;
               }

               if (!encontrado) {
                   yyerror("Erro: Campo não encontrado no registro");
               }

               // 3. guardar o TAM, DES e TIPO desse campo.
               //    o tipo (TIP) nesse caso é a posição do tipo
               //    na tabela de símbolos
               tam = temp->tam;
               des += temp->desl;
               pos = temp->pos;
               tipo = temp->tip;
           }
           else {
                  // TODO #14
              int pos = buscaSimbolo(atomo);
              // guardar TAM, DES e TIPO dessa variável
              elemTab.tam = tabSimb[pos].tam;
              elemTab.pos = tabSimb[pos].pos;
              elemTab.end = tabSimb[pos].end;
              elemTab.tip = tabSimb[pos].tip;
              des = tabSimb[pos].end;
           }
           ehRegistro = 0;
       };

termo
   : expressao_acesso
       {
          // TODO #15
          // Se for registro, tem que fazer uma repetição do
          // TAM do registro de CRVG (em ondem inversa)
          if (ehRegistro) {
              ptno temp = tabSimb[pos].listaCampos;

              // Iterar sobre os campos do registro em ordem inversa
              while (temp) {
                  fprintf(yyout, "\tCRVG\t%d\n", temp->desl);
                  temp = temp->prox;
              }
          } else {
            fprintf(yyout, "\tCRVG\t%d\n", tabSimb[pos].end); 
          } 
          empilha(tipo);
       }
   | T_NUMERO
       {  
          fprintf(yyout, "\tCRCT\t%s\n", atomo);  
          empilha(INT);
       }
   | T_V
       {  
          fprintf(yyout, "\tCRCT\t1\n");
          empilha(LOG);
       }
   | T_F
       {  
          fprintf(yyout, "\tCRCT\t0\n"); 
          empilha(LOG);
       }
   | T_NAO termo
       {  
          int t = desempilha();
          if (t != LOG)
              yyerror ("Incompatibilidade de tipo!");
          fprintf(yyout, "\tNEGA\n");
          empilha(LOG);
       }
   | T_ABRE expressao T_FECHA
   ;
%%

int main(int argc, char *argv[]) {
    char *p, nameIn[100], nameOut[100];
    argv++;
    if (argc < 2) {
        puts("\nCompilador da linguagem SIMPLES");
        puts("\n\tUSO: ./simples <NOME>[.simples]\n\n");
        exit(1);
    }
    p = strstr(argv[0], ".simples");
    if (p) *p = 0;
    strcpy(nameIn, argv[0]);
    strcat(nameIn, ".simples");
    strcpy(nameOut, argv[0]);
    strcat(nameOut, ".mvs");
    yyin = fopen(nameIn, "rt");
    if (!yyin) {
        puts ("Programa fonte não encontrado!");
        exit(2);
    }
    yyout = fopen(nameOut, "wt");
    yyparse();
    printf("programa ok!\n\n");
    return 0;
}