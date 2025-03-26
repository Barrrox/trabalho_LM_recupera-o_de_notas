# Otimização de Cálculos para Análise de Sensores Meteorológicos

Autores: André Gustavo Franco, Matheus Barros

O programa em assembly processa as leituras de de sensores metereológicos

A entrada deve ser uma sequencia de temperaturas seguida de um Enter, então uma sequencia de umidades seguida de 2 Enters. As sequências devem ter o mesmo tamanho.

Exemplo de entrada:
```
10.0 20.0 31.0 // enter
50 60 70 // enter
// enter
```

Saída esperada:
```
Média das Temperaturas: 20.333334 °C
Média da Umidade: 60.000000 %
Anomalias: Temperatura 10.000000 fora do intervalo esperado,
Temperatura 31.000000 fora do intervalo esperado,

Conversões:

        •  10.000000 °C -> 50.000000 °F
        •  20.000000 °C -> 68.000000 °F
        •  31.000000 °C -> 87.800003 °F
```

## Decisões de projeto

Utilização de 2 casas decimais para os printfs