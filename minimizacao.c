#include <stdio.h>
#include <stdbool.h>

#define NSTATES 5
#define NSYMBOLS 2
int finals[NSTATES] = {0, 1, 1, 1, 0};
int afd[NSTATES][NSYMBOLS] =
    {1, 2,
     3, 4,
     3, 4,
     3, 4,
     4, 4};
int marked[NSTATES * NSTATES];

void show()
{
    printf("\n%2d\n", 0);
    for (int q = 1; q < NSTATES; q++)
    {
        for (int p = 0; p < q; p++)
            printf("%2c ", marked[p * NSTATES + q] ? 'x' : '.');
        printf("%2d \n", q);
    }
}

int main(void)
{
    bool changed;
    // Para AFD = (Q, Sigma, delta, s, F)
    // 1. Seja marked uma tabela com todos os pares
    //    {p, q}, inicialmente desmarcados
    // 2. Marque {p, q} se p in F e q notin F, ou
    //    vice-versa
    for (int q = 1; q < NSTATES; q++)
        for (int p = 0; p < q; p++)
            if (finals[p] && !finals[q] ||
                !finals[p] && finals[q])
                marked[p * NSTATES + q] = 1;
            else
                marked[p * NSTATES + q] = 0;
    show();
    // 3. Repita o seguinte passo até que nenhuma
    //    mudança ocorra: se existe um par {p,q}
    //    tal que {d(p,a), d(q,a)} está marcado
    //    para algum a in Sigma, entao marque {p,q}
    do
    {
        changed = false;
        for (int q = 1; q < NSTATES; q++)
            for (int p = 0; p < q; p++)
                if (!marked[p * NSTATES + q])
                    for (int k = 0; k < NSYMBOLS; k++)
                    {
                        int dP = afd[p][k];
                        int dQ = afd[q][k];
                        if (marked[dP * NSTATES + dQ])
                        {
                            marked[p * NSTATES + q] = 1;
                            changed = true;
                        }
                    }
    } while (changed);
    show();
    // 4. Ao final, p é equivalente a q sse
    //    {p, q} não está marcado
    printf("\nEstados equivalentes\n");
    for (int q = 1; q < NSTATES; q++)
        for (int p = 0; p < q; p++)
            if (!marked[p * NSTATES + q])
                printf("%d eq. %d\n", p, q);
}