section .data
    ; O vetor variavel ou constante?
    ;vetor_temperaturas: db "Vetor de temperaturas (°C): [22.5, 25.3, 40.1, 18.7, 15.2]"
    entrada_temperaturas: db "Vetor de temperaturas (°C): ["    ; ARRUMAR, nn sabemos quantos dados serão lidos
    entrada_umidadades: db "Vetor de umidade relativa (%%): ", 0  ; ARRUMAR, nn sabemos quantos dados serão lidos
    format_scanf: db "%f%c%c"                                  ; Formato das leituras subsequentes do scanf, ver linha<!!!!!!!!!!!!!!!!!!!>
    saida_temperatura: db "Média das Temperaturas: %f °C", 10, 0
    saida_umidade: db "Média da Umidade: %f %%", 10, 0

    anomalias_1: db "Anomalias: ", 0
    anomalias_2: db "Temperatura %f fora do intervalo esperado", 0
    anomalia_virgula: db ", "
    anomalia_final: db "", 10, 0

    conversao_1: db "Conversões: ",10,10,0
    conversao_2: db 9,"•  %f °C -> %f °F", 10, 0

    vetor_temperatura: dd 12.0, 13.0, 140.0, 20.0, 130.0
    vetor_umidade: dd 50.0, 60.0, 70.0, 80.0

    nConversoes: db 5; numero de floats lidos

    formato_1: db "%d"



    ;•••
    ;•


section .bss
; variáveis de entrada 
    dumpC resb 1
    dumpF resd 1
; varíaveis de controle
    media_temperatura resd 1  ; onde a média das temperaturas será armazenada
    media_umidade resd 1      ; onde a média das umidades será armazenada
    desvio_temperatura resd 1      ; onde o desvio padrao das temperaturas será armazenada

    conversoes resb 1              ; onde os valores convertidos serão guardados ARRUMAR, nn sabemos quantos dados serão lidos
    compararColchete resb 1        ; onde será guardado o 2° caracter lido nos loops de scanf de leitura das entradas, ver linha <!!!!!!!!!!!>
    bufferFloat resd 1

; variáveis para o print de saída
    anomalias_buffer resd 10        ; deve ser do mesmo tamanho que vetor_temperatura  ARRUMAR, nn sabemos quantos dados serão lidos
    nAnomalias resb 1



section .text
    global main
    extern scanf, printf


main:
    ; Inicializa o stack frame
    push rbp
    mov rbp, rsp

    mov rbx, 0
    xorps xmm1, xmm1 ; Clear no xmm1
    xorps xmm2, xmm2
    xorps xmm3, xmm3 ; sera utilizado para guardar o rbx (iterador)

    

    loop_calcular_media:
        addss xmm1, [vetor_temperatura + rbx*4] ; xmm1 += temperatura[i]
        addss xmm2, [vetor_umidade + rbx*4] ; xmm2 += umidade[i]
        

        inc rbx ;i++
        cmp byte [nConversoes], bl
        jz fim_loop_calcular_media
        jmp loop_calcular_media



    fim_loop_calcular_media:
    cvtsi2ss xmm3, rbx 
    divss xmm1, xmm3
    divss xmm2, xmm3
        

    movss [media_temperatura], xmm1
    movss [media_umidade], xmm2

    mov rax, 1                   ; rax = 1 argumento
    lea rdi, [saida_temperatura] ; argumento de formato para o  print "Média das Temperaturas: %f °C"
;   mov rdi, saida_temperatura
    movss xmm0, [media_temperatura]   
    cvtss2sd xmm0, xmm0          ; conversão de float (32 bits) para 64 bits
    call printf

    mov rax, 1                   ; rax = 1 argumento
    lea rdi, [saida_umidade]     ; argumento de formato para o  print "Média das umidades: %f "
;   mov rdi, saida_umidade
    movss xmm0, [media_umidade]      
    cvtss2sd xmm0, xmm0          ; conversão de float (32 bits) para 64 bits
    call printf


    calcular_desvio_padrao:
    ;

    xor rbx, rbx
    xorps xmm1, xmm1 
    xorps xmm2, xmm2
    xorps xmm3, xmm3


    ; calcular variancia
    ; formula: somatorio(x[i] - media_x[i])² / (n - 1)
    ;
    ; utiliza xmm2 para guardar cada (x[i] - media_x[i])
    ; e guarda os somatorios em xmm1 e xmm2
    loop_calcular_variancia:
        ; variancia da temperatura
        movss xmm2, [vetor_temperatura + rbx*4] ; += temperatura[i]
        subss xmm2, [media_temperatura]
        mulss xmm2, xmm2 ; xmm2²
        addss xmm1, xmm2

        inc rbx ; i++
        cmp byte [nConversoes], bl
        jz fim_loop_calcular_variancia
        jmp loop_calcular_variancia

    fim_loop_calcular_variancia:
    
    xor rax, rax
    mov al, byte [nConversoes]
    cvtsi2ss xmm3, rax

    ; Salvando o inteiro 1 e convertendo para float para fazer o calculo n -1
    xorps xmm4, xmm4
    mov rax, 1
    cvtsi2ss xmm4, rax
    subss xmm3, xmm4 ; n - 1
    
    divss xmm1, xmm3  ; somatorio / (n - 1)

    sqrtss xmm1, xmm1 ; desvio padrao = sqrt(variancia)
    movss [desvio_temperatura], xmm1

    jmp verificar_anomalias

verificar_anomalias:

    xor rbx, rbx ; iterador
    xor rcx, rcx ; guardara iterador do vetor de anomalias
    xor rdx, rdx ; guardará contador de anomalias

    xorps xmm1, xmm1
    xorps xmm2, xmm2
    xorps xmm3, xmm3 ; guardara media_temperatura + desvio padrao
    xorps xmm4, xmm4 ; guardara media_umidade + desvio padrao

    movss xmm3, [media_temperatura]
    addss xmm3, [desvio_temperatura]

    loop_verificar_anomalias:

        movss xmm1, [vetor_temperatura + rbx*4]

        ; cmpss precisa de um terceiro parametro que indica o tipo de comparação
        ; no caso, 6 = "greater than"
        cmpss xmm1, xmm3, 6 ; verifica se a leitura está acima do desvio padrão
        jg anomalia_encontrada ; se teemperatura > desvio padrao
        
        ; Verificando se passa do desvio padrão inferior
        movss xmm3, [media_temperatura]
        subss xmm3, [desvio_temperatura] ; xmm3 = media - desvio padrao

        ; cmpss precisa de um terceiro parametro que indica o tipo de comparação
        ; no caso, 1 = "less than"
        cmpss xmm1, xmm3, 1  ; verifica se a leitura está abaixo do desvio padrão
        jl anomalia_encontrada ; se teemperatura < desvio padrao
        jmp anomalia_nao_encontrada

        anomalia_encontrada:
            movss [anomalias_buffer + rdx*4], xmm1 ; move o valor da anomalia para o vetor de anomalias
            add rdx, 1

        anomalia_nao_encontrada:

            inc rbx ; i++
            cmp byte [nConversoes], bl
            jz fim_loop_verificar_anomalias
            jmp loop_verificar_anomalias
            
    fim_loop_verificar_anomalias:

    mov rcx, rdx                      ; número de elementos no vetor anomalias

    xor rbx, rbx
    mov rbx, 0                               ; iterador

loop_print__anomalias_start:
    cmp bl, cl
    jge loop_print_anomalias_end

    mov rax, 1                               ; rax = 1 argumento
    lea rdi, [anomalias_2]                   ; argumento de formato para o print "Temperatura %f fora do intervalo esperado"
    movss xmm0, [anomalias_buffer + 4 * rbx]
    cvtss2sd xmm0, xmm0                      ; conversão de float (32 bits) para 64 bits  
    call printf

    ; cmp rbx, nAnomalias pra ver se precisa printar a virgula
    xor rax, rax
    lea rdi, [anomalia_virgula]             ; argumento de formato para o print ",  "  
    call printf

    inc rbx                                 ; incremento do rbx
    jmp loop_print__anomalias_start
    
loop_print_anomalias_end:

    xor rax, rax
    lea rdi, [anomalia_final]               ; argumento de formato para o print "\n "  
    call printf

    jmp fim


fim: 

    leave
    
    mov rax, 60
    mov rdi, 0
    syscall
