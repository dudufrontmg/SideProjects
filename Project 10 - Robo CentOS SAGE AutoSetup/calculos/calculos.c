/**************************************************************************

   Arquivo : Calculos.c

   Funcao  : Neste arquivo sao definidos os calculos que o processador de
             calculos faz no processamento em tempo real. A seguir seguem
             as explicacoes para a inclusao de um novo calculo.

   Preliminares : A) No SAGE, a funcao de calculo pode ser associada a 
   ------------      3 entidades:
                     - PAS -> Valor analogico
                     - PDS -> Valor digital
                     - PTS -> Valor totalizado

                  B) Um calculo e' definido em uma das 3 entidades no sistema de
                     configuracao (STI). O retorno deve ser feito pelo uso da
                     macro RETORNA no seguinte formato :

                       RETORNA(a);

                     OBS : 
                         a) O ponto e virgula no final e' obrigatorio
                         b) "a" e' o valor que foi calculado
                         c) A variavel "a" deve ser compativel com o calculo, 
                            isto e' :
                             - PAS ->   float
                             - PDS ->   unsigned int
                             - PTS ->   unsigned short

                  C) Os parametros passados para a funcao de calculo sao :
                     - np  -> numero de parcelas que compoem o calculo;
                     - par -> vetor com as parcelas

                  D) As parcelas sao conseguidas atraves das macros :
                      - Parcelas analogicas
                         PARCELA_ANA_1
                         PARCELA_ANA_2
                                     .
                                     .
                         PARCELA_ANA_40

                      - Parcelas digitais
                         PARCELA_DIG_1
                         PARCELA_DIG_2
                                     .
                                     .
                         PARCELA_DIG_20

                      - Parcelas totalizadas
PARCELA_TOT_1
                         PARCELA_TOT_2
                                     .
                                     .
                         PARCELA_TOT_20

                    OBS : 
                     1)
                      - Sao definidas como analogicas os tipos de parcela:
                        . VAC (Valor corrente de medida analogica em PAS)
                        . IEA (Valor do limite inferior de escala de medida em PAS)
                        . IUA (Valor do limite inferior de urgencia de medida em PAS)
                        . IAA (Valor do limite inferior de advertencia de medida em PAS)
                        . SAA (Valor do limite superior de advertencia de medida em PAS)
                        . SUA (Valor do limite superior de urgencia de medida em PAS)
                        . SEA (Valor do limite superior de escala de medida em PAS)

                      - Sao definidas como digitais os tipos de parcela:
                        . EDC (Estado digital corrente em PDS)
                        . EDN (Estado digital normal em PDS)

                      - Sao definidas como totalizados os tipos de parcela:
		        . VTC (Valor corrente de medida totalizada em PTS)
                        . SAT (Valor do limite superior de advertencia de medida em PTS)
                        . SUT (Valor do limite superior de urgencia de medida em PTS) 
                        . SET (Valor do limite superior de escala de medida em PTS)    

                     2) Num calculo so' pode existir uma parcela de cada numero de ordem,
                        por exemplo, se definirmos um calculo com tres parcelas, sendo a 
                        primeira e a terceira analogicas e a segunda digital, teriamos
                        PARCELA_ANA_1, PARCELA_DIG_2, PARCELA_ANA_3


   PASSOS:  1 -> Configurar o calculo pelo sistema de configuracao (STI) do SAGE, na
   ------        tabela TCL.

            2 -> Incluir o nome do tipo do novo calculo feito em (1) na 
                 estrutura lista (no final deste arquivo), no formato :

                 {K_TIP_CAL_id      , (void*)func_id          },
 
                 Onde : - id       -> Campo identificador (id) do novo calculo incluido 
                                      na tabela TCL
                        - func_id  -> Nome da funcao chamada para executar o calculo
 
            3 -> Escrever a funcao na sintaxe do 'C'. Ex: (funcao que calcule a potencia aparente)

                 void *func_PA (np,par)
                   int np;
                   void *par[];
                 {
                   float r;

                   if (np != 2)
                   {
                     hora();
                     printf("Numero de parcelas passados para funcPA diferente de 2, %d\n",np);
                   }

                   r = sqrt ((PARCELA_ANA_1 * PARCELA_ANA_1) + (PARCELA_ANA_2 * PARCELA_ANA_2));

                   RETORNA(r);
                 }

**************************************************************************/
#include "calculos.h"

extern void hora(void);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Calculo de potencia aparente                    +
   +								     +
   +   N. parcelas : 2						     +
   +								     +
   +   Parcelas    : 1 -> mw				             +
   +                 2 -> mvar				             +
   +								     +
   +                      __________________			     +
   +                     /   2          2			     +
   +   Formula     : \  /   mw  +    mvar			     +
   +                  \/					     +
   +								     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcPA (np,par)
 int np;
 void *par[];
{
  float r;  /* Cria a variavel de retorno . Como esta funcao e' definida  */
            /* para calcular um ponto analogico, este retorno tem que ser */
	            /* do tipo float                                              */

  if (np != 2)  /* Teste feito para verificar se a configuracao foi correta */
  {             /* (nesta fucao sao necessarias 2 parcelas)                 */
    hora();
    printf("Numero de parcelas passados para funcPA diferente de 2, %d\n",np);
  }

  r = sqrt ((PARCELA_ANA_1 * PARCELA_ANA_1) + (PARCELA_ANA_2 * PARCELA_ANA_2));

  RETORNA(r);  /* Retorna o valor calculado */
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Soma                                            +
   +								     +
   +   N. parcelas : Ate' 40 parcelas				     +
   +								     +
   +   Parcelas    : - p1 -> Primeira parcela a ser somada	     +
   +                 - p2 -> Segunda parcela a ser somada	     +
   +		       . 					     +
   +                   .                      			     +
   +                 - p40 -> Quadragesima parcela		     +
   +                                           			     +
   +   Formula     : p1 + p2 + ... + p40     			     +
   +                          					     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcSOMA (np,par)
 int np;
 void *par[];
{
  int i;
  float r=0.0;

  if (np > 40)
  {
    hora();
    printf("Numero de parametros passados para funcSOMA maior que 40, %d\n",np);
  }
  else
    for (i=0;i<np;i++)
      r = r + *(float *)par[i];
  /*
   *****
  r = PARCELA_ANA_1 + PARCELA_ANA_2 + PARCELA_ANA_3  + PARCELA_ANA_4  + PARCELA_ANA_5  + PARCELA_ANA_6 + PARCELA_ANA_7   +
      PARCELA_ANA_8 + PARCELA_ANA_9 + PARCELA_ANA_10 + PARCELA_ANA_11 + PARCELA_ANA_12 + PARCELA_ANA_13 + PARCELA_ANA_14 +
      PARCELA_ANA_15 ;
   *****
 */

  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Calculo de corrente                             +
   +								     +
   +   N. parcelas : 3 						     +
   +								     +
   +   Parcelas    :             				     +
   +                                				     +
   +								     +
   +                                         			     +
   +                              ________                           +
   +                             /  2   2        		     +
   +                         \  /  A + B        		     +
   +   Formula     : 1000     \/                		     +
   +                ----__   --------------     		     +
   +		    \  /           C            		     +
   +                 \/ 3  		                             +
   +								     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcCORRENTE (np,par)
 int np;
 void *par[];
{
  float r;

  if (np != 3)
  {
    hora();
    printf("Numero de parametros passados para funcCORRENTE diferente de 3, %d\n",np);
  }
  if (PARCELA_ANA_3 > 1.0)
  {
    r = 577.35027 * ((sqrt(((PARCELA_ANA_1*PARCELA_ANA_1)+(PARCELA_ANA_2*PARCELA_ANA_2)))) / PARCELA_ANA_3);
  }
  else
  {
    r = 0.0;
  }

  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Calculo de Corrente de SHUNTS                   +
   +								     +
   +   N. parcelas : 2 						     +
   +								     +
   +   Parcelas    :             				     +
   +                                				     +
   +								     +
   +                                         			     +
   +                              ________                           +
   +                             /  2           		     +
   +                         \  /  A         	         	     +
   +   Formula     : 1000     \/                		     +
   +                ----__   --------------     		     +
   +		    \  /           B            		     +
   +                 \/ 3  		                             +
   +								     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcAMPSHUNT (np,par)
 int np;
 void *par[];
{
  float r;

  if (np != 2)
  {
    hora();
    printf("Numero de parametros passados para funcAMPSHUNT diferente de 2, %d\n",np);
  }
  if (PARCELA_ANA_2 > 0)
  {
    r = 577.35027 * ((sqrt(PARCELA_ANA_1*PARCELA_ANA_1)) / PARCELA_ANA_2);
  }
  else
  {
    r = 0.0;
  }

  RETORNA(r);
}



/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Fator de Potencia                               +
   +								     +
   +   N. parcelas : 1 						     +
   +								     +
   +   Parcelas    :             				     +
   +                                				     +
   +								     +
   +                                         			     +
   +   Formula     :                                                 +
   +								     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcFPOT (np,par)
 int np;
 void *par[];
{
  float r;

  if (np != 1)
  {
    hora();
    printf("Numero de parametros passados para funcFPOT diferente de 1, %d\n",np);
  }
  r = cos(((PARCELA_ANA_1 * 3.14159) / 180.0));

  RETORNA(r);
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Calculo ou de ate' 15                           +
   +								     +
   +   N. parcelas : ate 15 					     +
   +								     +
   +   Parcelas    : Digitais a serem feitas ou            	     +
   +                                				     +
   +								     +
   +                                         			     +
   +   Formula     :                                                 +
   +								     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcOU (np,par)
 int np;
 void *par[];
{
  unsigned int r;

  r = PARCELA_DIG_1;
  if (np > 1) r  |= PARCELA_DIG_2;
  if (np > 2) r  |= PARCELA_DIG_3;
  if (np > 3) r  |= PARCELA_DIG_4;
  if (np > 4) r  |= PARCELA_DIG_5;
  if (np > 5) r  |= PARCELA_DIG_6;
  if (np > 6) r  |= PARCELA_DIG_7;
  if (np > 7) r  |= PARCELA_DIG_8;
  if (np > 8) r  |= PARCELA_DIG_9;
  if (np > 9) r  |= PARCELA_DIG_10;
  if (np > 10) r |= PARCELA_DIG_11;
  if (np > 11) r |= PARCELA_DIG_12;
  if (np > 12) r |= PARCELA_DIG_13;
  if (np > 13) r |= PARCELA_DIG_14;
  if (np > 14) r |= PARCELA_DIG_15;

  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Funcao and not                                  +
   +                                                                 +
   +   N. parcelas : 2                                               +
   +                                                                 +
   +   Parcelas    :                                                 +
   +                                                                 +
   +                                                                 +
   +                                                                 +
   +                                                                 +
   +   Formula     : (A AND (NOT(B))                                 +
   +                                                                 +
   +                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcANDNOT (np,par)
 int np;
 void *par[];
{
  unsigned int r;

  if (np != 2)
  {
    hora();
    printf("Numero de parametros passados para funcANDNOT diferente de 2, %d\n",np);
  }

  r = (PARCELA_DIG_1 & (!PARCELA_DIG_2));

  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Subtracao                                       +
   +								     +
   +   N. parcelas : Ate' 40 parcelas				     +
   +								     +
   +   Parcelas    : - p1 -> Primeira parcela a ser subtraida	     +
   +                 - p2 -> Segunda parcela a ser subtraida	     +
   +		       . 					     +
   +                   .                      			     +
   +                 - p40 -> Quadragesima parcela		     +
   +                                           			     +
   +   Formula     : p1 - p2 - ... - p40     			     +
   +                          					     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcSUB (np,par)
 int np;
 void *par[];
{
  int i;
  float r=0.0;

  if (np > 40) {
    hora();
    printf("Numero de parametros passados para funcSUB maior que 40, %d\n",np);
  }
  else
  {
	 r = *(float *)par[0];
    for (i=1;i<np;i++)
      r = r - *(float *)par[i];
  }
  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Multiplicacao                                   +
   +								     +
   +   N. parcelas : Ate' 40 parcelas				     +
   +								     +
   +   Parcelas    : - p1 -> Primeira parcela a ser multiplicada     +
   +                 - p2 -> Segunda parcela a ser multiplicada	     +
   +		       . 					     +
   +                   .                      			     +
   +                 - p40 -> Quadragesima parcela		     +
   +                                           			     +
   +   Formula     : p1 * p2 * ... * p40     			     +
   +                          					     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcMULT (np,par)
 int np;
 void *par[];
{
  int i;
  float r=0.0;

  if (np > 40) {
    hora();
    printf("Numero de parametros passados para funcMULT maior que 40, %d\n",np);
  }
  else
  {
	 r = *(float *)par[0];
    for (i=1;i<np;i++)
      r = r * *(float *)par[i];
  }

  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Divisao                                         +
   +								     +
   +   N. parcelas : Ate' 40 parcelas				     +
   +								     +
   +   Parcelas    : - p1 -> Primeira parcela a ser dividida         +
   +                 - p2 -> Segunda parcela a ser dividida    	     +
   +		       . 					     +
   +                   .                      			     +
   +                 - p40 -> Quadragesima parcela		     +
   +                                           			     +
   +   Formula     : p1 / p2 / ... / p40     			     +
   +                          					     +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcDIV (np,par)
 int np;
 void *par[];
{
  float r=0.0;

  if (np != 2)
  {
    hora();
    printf("Numero de parametros passados para DIV diferente de 2, %d\n",np);
  }
  else {

	if (PARCELA_ANA_2 != 0.0 )   
		r = PARCELA_ANA_1 / PARCELA_ANA_2; 

  }
  RETORNA(r);
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Raiz Quadrada                                   +
   +                                                                 +
   +   N. parcelas : 1                                               +
   +                                                                 +
   +   Parcelas    :    ____                                         +
   +                   /    \                                        +
   +   Formula     : \/  X                                           +
   +                                                                 +
   +                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcRAIZ2 (np,par)
 int np;
 void *par[];
{
  float r=0.0;

  if (*(float *) par[0] < 0) {
    hora();
    printf("Parametro passado para RAIZ2 e' negativo, %f\n", *(float *) par[0]);
  }
  else if (np != 1) {
    hora();
    printf("Numero de parametros passados para RAIZ2 diferente de 1, %d\n", np);
  }
  else
    r = sqrt(*(float *) par[0]) ;

  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Multiplicar um numero real por -1               +
   +                                                                 +
   +   N. parcelas : 1                                               +
   +                                                                 +
   +   Parcelas    :   p1 - parcela a ser multiplicada por -1        +
   +                                                                 +
   +   Formula     :  p1 * -1                                        +
   +                                                                 +
   +                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcNEGA (np,par)
   int np;
   void *par[];
{
   float r=0.0;
   if (np != 1)
     {
       hora();
       printf("Numero de parcelas passados para funcNEGA diferente de 1, %d\n",np);
     }
    else
     r = -1.0 * PARCELA_ANA_1;


   RETORNA(r);
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Funcao inverte status                           +
   +                                                                 +
   +   N. parcelas : 1                                               +
   +                                                                 +
   +   Parcelas    : PD1 -> Parcela a ser invertido o status         +
   +                                                                 +
   +   Formula     : !PD1                                            +
   +                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcINVERSO (np,par)
 int np;
 void *par[];
{
  unsigned int r;

  if (np != 1)
  {
    hora();
    printf("Numero %d de parametros passados para funcINVERSO diferente de 1",np);
    r=0;
    RETORNA(r);
  }
  r = !PARCELA_DIG_1;
  RETORNA(r);
}

/*---------------------------------------------------------------------*/

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Armazena o Valor enviado pelo IED (se > 0)   +
   +								     			+
   +   N. parcelas : 2						     			+
   +								     			+
   +   Parcelas    : 1 -> Valor Analgico da Distncia 			    			+
   +                 2 -> Valor Atual dele mesmo					    			+
   +                  					     				+
   +								     			+
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcDISKM (np,par)
 int np;

void *par[];
{ 
 float r;
 if (np != 1)
   {
    hora();
    printf("Numero de parcelas passados para funcDISKM diferente de 1, %d\n",np);
   }

 if (PARCELA_ANA_1 > 0 )  
    r = (PARCELA_ANA_1) ;
else
    r = (PARCELA_ANA_2) ;

RETORNA(r);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : FREQ - Caso haja FALTA TENSAO NA LINHA o valor da freq  zerado,   +
   + pois o IED manda a freq. de operacao qdo nao tem referencia		        +
   +                                                                                    +
   +   N. parcelas : 2						     			+
   +								     			+
   +   Parcelas    : 1 -> Ponto Digital FALTA TENSAO NA LINHA 			    	+
   +                 2 -> Valor Analgico da frequencia					+
   +                  					     				+
   +								     			+
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcFREQ (np,par)
 int np;

void *par[];
{ 
 float r;
 if (np != 1)
   {
    hora();
    printf("Numero de parcelas passados para funcFREQ diferente de 1, %d\n",np);
   }

 if (PARCELA_DIG_1)  
    r = 0 ;
else
    r = (PARCELA_ANA_2) ;

RETORNA(r);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : INTEQP Funcao para Calcular o Intertravamento dos Equipamentos     +
   +                                                                                    +
   +   N. parcelas : 5						     			+
   +								     			+
   +   Parcelas    : 1 -> Posicao do equipamento        			    	+
   +                 2 -> Permissao de Abertura					        +
   +                 3 -> Permissao de Fechamento					+
   +                 4 -> Chave Remoto do IED                                           +
   +                 5 -> Chave 43 SE/COR                                               +
   +								     			+
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcINTEQP (np,par)
 int np;

void *par[];
{

 unsigned int r;
 if (np != 5)
   {
    hora();
    printf("Numero de parcelas passados para funcINTEQP diferente de 5, %d\n",np);
   }
// hora();
// printf("Valor do Parametro PARCELA_DIG_1, %d\n",PARCELA_DIG_1);
 if (PARCELA_DIG_1 == 0)
 {

    r = (!PARCELA_DIG_3)|(PARCELA_DIG_4)|(PARCELA_DIG_5); /*Pto de intertrav fechamento*/
 }
else
 {
    r = (!PARCELA_DIG_2)|(PARCELA_DIG_4)|(PARCELA_DIG_5); /*Pto de intertrav fechamento*/
 }
 RETORNA(r);
}


/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : INTEDJ Funcao para Calcular o Intertravamento dos Disjuntores      +
   +                                                                                    +
   +   N. parcelas : 6						     			+
   +								     			+
   +   Parcelas    : 1 -> Posicao do equipamento        			    	+
   +                 2 -> Permissao de Abertura					        +
   +                 3 -> Permissao de Fechamento					+
   +                 4 -> Chave Remoto do IED                                           +
   +                 5 -> Chave 43 SE/COR                                               +
   +		     6 -> Estado das Secc.89-1 89-2	                                +
   +               					     			+       +
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcINTEDJ (np,par)
 int np;

void *par[];
{

 unsigned int r;
 if (np != 6)
   {
    hora();
	printf("Numero de parcelas passados para funcINTEDJ diferente de 6, %d\n",np);
   }
// hora();
// printf("Valor do Parametro PARCELA_DIG_1, %d\n",PARCELA_DIG_1);
 if (PARCELA_DIG_1 == 0)
 {

    r = (!PARCELA_DIG_3)|(!PARCELA_DIG_4)|(PARCELA_DIG_5)|(PARCELA_DIG_6); /*Pto de intertrav fechamento*/
 }
else
 {
    r = (!PARCELA_DIG_2)|(!PARCELA_DIG_4)|(PARCELA_DIG_5); /*Pto de intertrav fechamento*/
 }
 RETORNA(r);
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Calculo do AND de N parcelas                    +
   +                                                                 +
   +   N. parcelas : ate' 50                                         +
   +                                                                 +
   +   Parcelas    : Digitais para serem avaliados em condicao AND   +
   +                                                                 +
   +   Formula     : p1 & p2 & p3 ... & pn                           +
   +                                                                 +
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

static void *funcE (int np, void **par)
{
unsigned int i,r;

 r = *((int*)par[0]);
 for (i=1; i<np; i++) {
     r = (r & (*((int*)par[i])) );
 }
 RETORNA(r);
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +								     +                                    
   +                 ABB - 12/03/2009 - Guto                         +
   +                                                                 +
   +   N. parcelas :                                                 *
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcNOU2 (int np,void **par)
{
unsigned int i,r;
  r = *((int*)par[0]);
  for(i=1;i<np; i++)
  {
    if(i==(np-1))
      {
      r = (r | (*((int*)par[i])) );
      }
    else
      {
      r = (r | !(*((int*)par[i])) );
      }
  };
  RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +								     +
   +                 ABB - 12/03/2009 - Guto                         +
   +                                                                 +
   +   N. parcelas :                                                 *
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcNOU (int np,void **par)

{
  unsigned int i,r;

  r = *((int*)par[0]);
  for (i=1; i<np; i++) 
  {
    r = (r | (*((int*)par[i])) );
  }
  RETORNA(!r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +								     +                                    
   +                 ABB - 12/03/2009 - Guto                         +
   +                                                                 +
   +   N. parcelas :                                                 *
   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcOUN2 (int np,void **par)
{
unsigned int i,r;
  r = *((int*)par[0]);
  r = !r;
  for(i=1;i<np; i++)
  {
    if(i==(np-1))
      {
      r = (r | (*((int*)par[i])) );
      }
    else
      {
      r = (r | !(*((int*)par[i])) );
      }
  };
  RETORNA(r);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : INTEQP Funcao para Calcular a posição de TAPE dos SDV              +
   +                                                                                    +
   +   N. parcelas : 1						     			+
   +								     			+
   +   Parcelas    : 1 -> Posicao do TAPE   					   	+
   +                                                                                    +
   +								     			+
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcINTESDV (np,par)
 int np;

void *par[];
{ 
 float r;
 if (np != 1)
   {
    hora();
    printf("Numero de parcelas passados para funcINTESDV diferente de 1, %d\n",np);
   }
   
    r = ((PARCELA_TOT_1) - 11.0) * (-1.0);
    
RETORNA(r);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   +   Funcao      : Armazena o Valor enviado pelo IED SEL (se < 100)                   +
   +								     			+
   +   N. parcelas : 1						     			+
   +								     			+
   +   Parcelas    : 1 -> Valor Analogico da Distancia 		     			+
   +                					    	         		+
   +                  					     				+
   +								     			+
   ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcSEL (np,par)
 int np;

void *par[];
{ 
 float r;
 if (np != 1)
   {
    hora();
    printf("Numero de parcelas passados para funcSEL diferente de 1, %d\n",np);
   }

 if (PARCELA_ANA_1 < 100 )  
    r = (PARCELA_ANA_1) ;
else
    r = 0 ;

RETORNA(r);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * +   Funcao      : KVALTA - Calculo do KV da alta do transformador usando o KV da     +
 * + baixa usando o estado do disjuntor da alta                                         +
 * +                                                                                    +
 * +   N. parcelas : 2                                                                  +
 * +                                                                                    +
 * +   Parcelas    : 1 -> Ponto Digital Disjuntor da alta do transformador              +
 * +                 2 -> Valor Analgico de KV da baixa                                 +
 * +                                                                                    +
 * +   Obs: 345/88 = 3.92                                                               +
 * +   Decio e Lucas - 06/02/18                                                         + 
 * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcKVALTA (np,par)
 int np;

void *par[];
{
 float r;
 if (np != 2)
   {
    hora();
    printf("Numero de parcelas passados para funcKVALTA diferente de 2, %d\n",np);
   }

 if (PARCELA_DIG_1 == 0)
    r = 0 ;
else
    r = (PARCELA_ANA_2 * 3.92);

RETORNA(r);
}

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * * +   Funcao      : KVBARRA - Selecao do KV de barra atraves dos seccionadores         +
 * * +                                                                                    +
 * * +                                                                                    +
 * * +   N. parcelas : 4                                                                  +
 * * +                                                                                    +
 * * +   Parcelas Digitais   : 1 -> Seccionador barra 3                                   +
 * * +                         2 -> Seccionador barra 4                                   +
 * * +                                                                                    +
 * * +   Parcelas Analogicas : 1 -> kV barra 3                                            +
 * * +                         2 -> kV barra 4                                            +
 * * +                                                                                    +
 * * +                                                                                    +
 * * +                                                                                    +
 * * +                                                                                    +
 * * +   Obs: 345/88 = 3.92                                                               +
 * * +   Decio e Lucas - 06/02/18                                                         + 
 * * ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcKVBARRA (np,par)
 int np;

void *par[];
{
 float r;
 if(np != 4)
   {
    hora();
    printf("Numero de parcelas passados para funcKVBARRA diferente de 4, %d\n",np);
   }

 if (PARCELA_DIG_1)
       {
	r = (PARCELA_ANA_3);
       }
 else if (PARCELA_DIG_2)
      {
	r = (PARCELA_ANA_4);
      }
 else 
      {
	r = 0;
      }

RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * +   Funcao      : Calculo de potencia reativa                     +
 * +                                                                 +
 * +   N. parcelas : 3                                               +
 * +                                                                 +
 * +   Parcelas    : 1 -> tensao                                     +
 * +                 2 -> corrente
 *                   3 -> mw                                         +
 * +                                                                 +
 * +                      __________________                         +
 * +                     /   2          2                            +
 * +   Formula     : \  /   ma  -    mw                              +
 * +                  \/                                             +
 * +   Decio e Lucas - 06/02/18                                      +
 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcPR (np,par)
 int np;
 void *par[];
{
  float r;  /* Cria a variavel de retorno . Como esta funcao e' definida  */
            /* para calcular um ponto analogico, este retorno tem que ser */
                    /* do tipo float                                              */

  if (np != 3)  /* Teste feito para verificar se a configuracao foi correta */
  {             /* (nesta fucao sao necessarias 2 parcelas)                 */
    hora();
    printf("Numero de parcelas passados para funcPR diferente de 3, %d\n",np);
  }

  r = sqrt (((PARCELA_ANA_1 * PARCELA_ANA_2 * 1.732) * (PARCELA_ANA_1 * PARCELA_ANA_2 * 1.732)) - (PARCELA_ANA_3 * PARCELA_ANA_3));

  RETORNA(r);  /* Retorna o valor calculado */
}


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * +   Funcao      : Multiplicar um numero real por -1.005           +
 * +                                                                 +
 * +   N. parcelas : 1                                               +
 * +                                                                 +
 * +   Parcelas    :   p1 - parcela a ser multiplicada por -1.005    +
 * +                                                                 +
 * +   Formula     :  p1 * -1.005                                    +
 * +                                                                 +
 * +   Decio e Lucas - 06/02/18                                      +
 * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcNEGA1 (np,par)
   int np;
   void *par[];
{
   float r=0.0;
   if (np != 1)
     {
       hora();
       printf("Numero de parcelas passados para funcNEGA1 diferente de 1, %d\n",np);
     }
    else
     r = -1.005 * PARCELA_ANA_1;


   RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * * +   Funcao      : Calculo de potencia ativa                       +
 * * +                                                                 +
 * * +   N. parcelas : 2                                               +
 * * +                                                                 +
 * * +   Parcelas    :  p1 - tensao                                    +
 * * +                  p2 - corrente                                  +
 * * +   Formula     :  raiz3 * tensao * corrente * FP (0.98)          +
 * * +                                                                 +
 * * +   Decio e Lucas - 06/02/18                                      +
 * * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcPAT (np,par)
   int np;
   void *par[];
{
   float r=0.0;
   if (np != 2)
     {
       hora();
       printf("Numero de parcelas passados para funcPAT diferente de 1, %d\n",np);
     }
    else
     r = (1.732 * PARCELA_ANA_1 * PARCELA_ANA_2 * 0.98);


   RETORNA(r);
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 * * +   Funcao      : Medicao de kW para MW                           +
 * * +                                                                 +
 * * +   N. parcelas : 1                                               +
 * * +                                                                 +
 * * +   Parcelas    :   p1 - parcela a ser dividida por 1000          +
 * * +                                                                 +
 * * +   Formula     :  (p1)/1000                                      +
 * * +                                                                 +
 * * +   Decio e Lucas - 06/02/18                                      +
 * * +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

void *funcTRAT (np,par)
   int np;
   void *par[];
{
   float r=0.0;
   if (np != 1)
     {
       hora();
       printf("Numero de parcelas passados para funcTRAT diferente de 1, %d\n",np);
     }
    else
     r = (( PARCELA_ANA_1)/1000);


   RETORNA(r);
}



struct list_calc lista [] = {
              {K_TIP_CAL_PA      , (void*)funcPA          },
              {K_TIP_CAL_SOMA    , (void*)funcSOMA        },
              {K_TIP_CAL_CORRENTE, (void*)funcCORRENTE    },
              {K_TIP_CAL_AMPSHUNT, (void*)funcAMPSHUNT    },
              {K_TIP_CAL_FPOT    , (void*)funcFPOT        },
              {K_TIP_CAL_OU      , (void*)funcOU          },
              {K_TIP_CAL_ANDNOT  , (void*)funcANDNOT      },
              {K_TIP_CAL_SUB     , (void*)funcSUB         },
              {K_TIP_CAL_MULT    , (void*)funcMULT        },
              {K_TIP_CAL_DIV     , (void*)funcDIV         },
              {K_TIP_CAL_RAIZ2   , (void*)funcRAIZ2       },
              {K_TIP_CAL_NEGA    , (void*)funcNEGA        },
              {K_TIP_CAL_INVERSO , (void*)funcINVERSO     },
              {K_TIP_CAL_DISKM   , (void*)funcDISKM       },
              {K_TIP_CAL_FREQ    , (void*)funcFREQ        },
              {K_TIP_CAL_INTEQP  , (void*)funcINTEQP      },
              {K_TIP_CAL_E       , (void*)funcE           },
              {K_TIP_CAL_NOU2    , (void*)funcNOU2        },
              {K_TIP_CAL_NOU     , (void*)funcNOU         },
              {K_TIP_CAL_OUN2    , (void*)funcOUN2        },
              {K_TIP_CAL_INTEDJ  , (void*)funcINTEDJ      },
              {K_TIP_CAL_INTESDV , (void*)funcINTESDV     },
              {K_TIP_CAL_SEL     , (void*)funcSEL         },		  
              {K_TIP_CAL_KVALTA  , (void*)funcKVALTA      },		  
              {K_TIP_CAL_KVBARRA , (void*)funcKVBARRA     },		  
              {K_TIP_CAL_PR      , (void*)funcPR          },		  
              {K_TIP_CAL_NEGA1   , (void*)funcNEGA1       },		  
              {K_TIP_CAL_PAT     , (void*)funcPAT         },		  
              {K_TIP_CAL_TRAT    , (void*)funcTRAT        },
              {-1                , (void*)(-1)            }
             };
