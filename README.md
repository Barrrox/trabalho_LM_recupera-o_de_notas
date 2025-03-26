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
Média das Temperaturas: 20.33 °C
Média da Umidade: 60.00 %
Anomalias:
        •  Temperatura 10.00 fora do intervalo esperado
        •  Temperatura 31.00 fora do intervalo esperado

Conversões:
        •  10.00 °C -> 50.00 °F
        •  20.00 °C -> 68.00 °F
        •  31.00 °C -> 87.80 °F
```

## Decisões de projeto (perfumaria)

Utilização de 2 casas decimais para os printf's