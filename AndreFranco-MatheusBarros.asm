; Trabalho de recuperação de notas
; Matéria: Linguagens de montagem
; Professor: Gabriela Stein
; Alunos: André Gustavo Franco e Matheus Barros
; Linkagem e Montagem:
; nasm -f elf64 Trabalho_2.asm -o Trabalho_2.o; gcc -m64 -no-pie -o Trabalho_2 Trabalho_2.o -lm

; To-Do:
; scanfs
; conversao 
; verificar se o numero de leituras é maior do que 1
; 
; To-Conferir:
; prints
; parte em que printa vetor
; 
;  Vetor de temperaturas (°C): [22.5, 25.3, 40.1, 18.7, 15.2]


section .data
    ; O vetor variavel
    entrada_temperaturas: db "Vetor de temperaturas (°C): ["    
    entrada_umidadades: db "Vetor de umidade relativa (%%): [" 

    format_scanf: db "%f%c"                                  ; Formato das leituras subsequentes do scanf, ver linha 86
    saida_temperatura: db "Média das Temperaturas: %f °C", 10, 0
    saida_umidade: db "Média da Umidade: %f %%", 10, 0

    anomalias_1: db "Anomalias: ", 0
    anomalias_2: db "Temperatura %f fora do intervalo esperado", 0
    anomalia_virgula: db ", "
    anomalia_final: db "", 10, 0

    conversao_1: db "Conversões: ",10,10,0
    conversao_2: db 9,"•  %f °C -> %f °F", 10, 0

    const_nove: dd 9.0
    const_cinco: dd 5.0
    const_trinta_dois: dd 32.0

    formato_1: db "%d",10,0
    formato_char: db "%c", 10, 0
    formato_quebra_de_linha: db 10, 0


    ;•••
    ;•

; 

section .bss
; variáveis de entrada 
    vetor_temperatura resd 64  ; onde os valores de temperatura serão armazenados ARRUMAR, nn sabemos quantos dados serão lidos ; talvez ir guardando os valores lidos na stack
    vetor_umidade resd 64      ; onde os valores de umidade serão armazenados     ARRUMAR, nn sabemos quantos dados serão lidos
    dumpC resb 1
    dumpF resd 1
; varíaveis de controle
    media_temperatura resd 1  ; onde a média das temperaturas será armazenada
    media_umidade resd 1      ; onde a média das umidades será armazenada
    desvio_temperatura resd 1      ; onde o desvio padrao das temperaturas será armazenada

    compararColchete resb 1        ; onde será guardado o 2° caracter lido nos loops de scanf de leitura das entradas, ver linha 116
    bufferFloat resd 1

; variáveis para o print de saída
    anomalias_buffer resd 64         ; deve ser do mesmo tamanho que vetor_temperatura  ARRUMAR, nn sabemos quantos dados serão lidos
    conversao_buffer resd 64         ; onde os valores convertidos serão armazenados
    nAnomalias resb 1

    nConversoes resb 1 ; numero de floats lidos



; o que FUNCIONA
; tudo ate conversao
    ; mas
    ; calculo do desvio padrao esta incorreto
    ; xmm1 ta sendo wipado durante o trecho das anomalias - linha 287


section .text
    global main
    extern scanf, printf

main:
    ; Inicializa o stack frame
    push rbp
    mov rbp, rsp

    ; mov rdi, formato_1 ; Primeiro argumento para printf: a string de formato
    ; mov rsi, 1         ; Segundo argumento para printf: o número 1
    ; xor rax, rax         ; Número de registradores de ponto flutuante usados (nenhum neste caso)
    ; call printf        ; Chama a função printf

    ; primeiro scanf -> vetor_temperaturas
        ; guardar o número de floats lidos em nConversoes

    ; preparação para entrar no loop de leitura
    


    ; xor rax, rax
    ; lea rdi, [entrada_temperaturas]
    ; call scanf                        ; leitura de entrada_temperaturas: db "Vetor de temperaturas (°C): " 
    xor rbx, rbx

loop_scanf_temperaturas_start:
;format_scanf %f%c%c numero virgula espaço -> numero fechaColchete void
;compararColchete

    mov rax, 0
    lea rdi, [format_scanf]
    lea rsi, [bufferFloat] ; estou lendo um float, nn um int, talvez funcione
    lea rdx, [compararColchete]

    ;lea rcx, [dumpC] ; ignorar o 3 elemento lido
; a ideia é o quarto parametro(posição de escrita do terceiro elemento lido) ir pro espaço
    call scanf
    
    movss xmm0, [bufferFloat]
    movss [vetor_temperatura+rbx*4], xmm0 ; ACHO que eh assim com dword
teste_1:
    inc rbx

    mov eax, [compararColchete]

    cmp al, 10 ; quebra de linha 
    je loop_scanf_temperaturas_end

    jmp loop_scanf_temperaturas_start

loop_scanf_temperaturas_end:

    mov byte [nConversoes], bl ; salvar a quantidade de elementos lidos

    mov rdi, formato_1 ; Primeiro argumento para printf: a string de formato
    mov rsi, [nConversoes]         ; Segundo argumento para printf: o número 1
    xor rax, rax         ; Número de registradores de ponto flutuante usados (nenhum neste caso)
    call printf        ; Chama a função printf

    ; xor rax, rax
    ; lea rdi, [formato_char]       ; talvez nn fucncione, testar com lea rdi, variavel com '0'
    ; lea rsi, [dumpC]           ; tentativa de remover o \n do final da entrada
    ; call scanf
teste_4:
    

    ; segundo scanf  -> vetor_umidade

    ; xor rax, rax
    ; lea rdi, [entrada_umidadades]
    ; call scanf                        ; leitura de "Vetor de umidade relativa (%%): [ " 
    
    ; mov rbx, 0                        ; contador 


loop_scanf_umidades_start:

;     mov rax, 1
;     lea rdi, [format_scanf]
;     lea rsi, [bufferFloat] ; estou lendo um float, nn um int, talvez funcione
;     lea rdx, [compararColchete]
;     ;lea rcx, [dumpC] ; ignorar o 3 elemento lido " "
; ; a ideia é o quarto parametro(posição de escrita do terceiro elemento lido) ir pro espaço
    
;     movss xmm0, [bufferFloat]
;     movss dword [vetor_umidade+rbx*4], xmm0 ; ACHO que eh assim com dword
    
;     inc rbx

;     mov al, compararColchete
;     cmp eax, 10
;     je loop_scanf_temperaturas_end
    
;     jmp loop_scanf_umidades_start

loop_scanf_umidades_end:
; katchau
; katchuga


; Calculo de media e variancia
calcular_medias:
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

    jmp calcular_desvio_padrao



    
; Verificação de anomalia: Se uma leitura estiver acima ou abaixo do desvio padrão
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

    divss xmm1, xmm3

    sqrtss xmm1, xmm1 ; desvio padrao = sqrt(variancia)
    movss [desvio_temperatura], xmm1

    jmp verificar_anomalias

teste_5:
verificar_anomalias:

    xor rbx, rbx ; iterador
    xor rcx, rcx ; guardara iterador do vetor de anomalias
    xor rdx, rdx ; guardará contador de anomalias

    xorps xmm1, xmm1
    xorps xmm2, xmm2
    xorps xmm3, xmm3 ; guardara media_temperatura + desvio padrao
    xorps xmm4, xmm4 ; guardara media_umidade + desvio padrao

    movss xmm3, [media_temperatura]
    addss xmm3, [desvio_temperatura] ; xmm3 = media + desvio padrao

    loop_verificar_anomalias:

        movss xmm1, [vetor_temperatura + rbx*4]
teste_xmm1_1:
        ; cmpss precisa de um terceiro parametro que indica o tipo de comparação
        ; no caso, 6 = "greater than"
        comiss xmm1, xmm3 ; verifica se a leitura está acima do desvio padrão
        ja anomalia_encontrada ; se teemperatura > desvio padrao
        
        ; Verificando se passa do desvio padrão inferior
        movss xmm3, [media_temperatura]
        subss xmm3, [desvio_temperatura] ; xmm3 = media - desvio padrao

        ; cmpss precisa de um terceiro parametro que indica o tipo de comparação
        ; no caso, 1 = "less than"
        comiss xmm1, xmm3  ; verifica se a leitura está abaixo do desvio padrão ; xmm1 está sendo zerado
teste_xmm1_3:
        jb anomalia_encontrada ; se teemperatura < desvio padrao
        jmp anomalia_nao_encontrada


        anomalia_encontrada:
            movss [anomalias_buffer + rdx*4], xmm1 ; move o valor da anomalia para o vetor de anomalias
            add rdx, 1
teste_xmm1_2:
        anomalia_nao_encontrada:

            inc rbx ; i++
            cmp byte [nConversoes], bl
            jz fim_loop_verificar_anomalias
            jmp loop_verificar_anomalias
            
    fim_loop_verificar_anomalias:

    mov byte [nAnomalias], dl
teste_6:
    jmp Conversao

;--------------------------------------------------------------------------------------;
; Conversão de unidades (ºC -> ºF)
Conversao:
    xor rbx, rbx
    xor rax, rax
    xorps xmm1, xmm1
    xorps xmm2, xmm2
    xorps xmm3, xmm3
    movzx rax, byte [nConversoes]

    ; test rax, rax
    ; jz loop_conversao_end

    cmp rbx, rax 
    je loop_conversao_end

    movss xmm1, [const_nove]
    movss xmm2, [const_cinco]
    movss xmm3, [const_trinta_dois]

loop_conversao_start:

    je loop_conversao_end

    movss xmm0, dword [vetor_umidade+rbx*4]
    mulss xmm0, xmm1
    divss xmm0, xmm2
    addss xmm0, xmm3

    movss dword [conversao_buffer+rbx*4], xmm0

    inc rbx
    
    cmp rbx, rax
    jmp loop_conversao_start

loop_conversao_end:

teste_7:
;--------------------------------------------------------------------------------------;


print_saida:
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

    xor rax, rax
    lea rdi, [anomalias_1]          ; argumento de formato para o  print "Anomalias: "  
    call printf

;--------------------------------------------------------------------------------------;
    ; loop printando as anomalias

    xor rcx, rcx
    xor rbx, rbx
    xor rax, rax
    xor rdi, rdi
    xor r10, r10

    xorps xmm0, xmm0

    ;mov cl, byte [nAnomalias]                    ; rcx = número de elementos no vetor anomalias
    movzx r10, byte [nConversoes]
    test r10, r10
    jz loop_print_anomalias_end

    mov rbx, 0                               ; iterador

loop_print__anomalias_start:
    cmp bl, cl
    je loop_print_anomalias_end

    mov rax, 1                               ; rax = 1 argumento
    lea rdi, [anomalias_2]                   ; argumento de formato para o print "Temperatura %f fora do intervalo esperado"
    movss xmm0, dword [anomalias_buffer + 4 * rbx]
    cvtss2sd xmm0, xmm0                      ; conversão de float (32 bits) para 64 bits  
    call printf

    inc rbx  
    
    xor rax, rax
    cmp rbx, r10
    je loop_print_anomalias_end

    lea rdi, [anomalia_virgula]             ; argumento de formato para o print ",  "  
    call printf

                                   ; incremento do rbx
    jmp loop_print__anomalias_start
    
loop_print_anomalias_end:

    xor rax, rax
    lea rdi, [anomalia_final]               ; argumento de formato para o print "\n "  
    call printf

;--------------------------------------------------------------------------------------;



; loop printando as conversões


    
    xor rbx, rbx
    xor rcx, rcx
    xorps xmm0, xmm0
    
    xor rax, rax
    lea rdi, [conversao_1]                     ; argumento de formato para o  print "Conversões: ",10,10,0
    call printf
    
    mov rcx, nConversoes                       ; número de conversões realizadas
    mov rbx, 0                                 ; iterador


    ; conversao_1: db "Conversões: ",10,10,0
    ; conversao_2: db 9,"•  %f °C -> %f °F", 10, 0
    
loop_print_conversoes_start:
    cmp rbx, rcx 

    mov rax, 2                                ; rax = 2 argumento
    lea rdi, [conversao_2]                     ; argumento de formato para o print 9,"•  %f °C -> %f °F", 10, 0
    movss xmm0, dword [vetor_temperatura + 4 * rbx]   ; conversoes[4*iterador]
    movss xmm1, dword [conversao_buffer + 4 * rbx]
    cvtss2sd xmm0, xmm0                        ; conversão de float (32 bits) para 64 bit
    cvtss2sd xmm1, xmm1
    call printf

    inc rbx                                    ; incremento do rbx
    jmp loop_print_conversoes_start
    
loop_print_conversoes_end:


;--------------------------------------------------------------------------------------;

fim_programa:
    ; Finaliza o stack frame (main)
    leave

    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall