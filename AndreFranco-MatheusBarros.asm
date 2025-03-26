; Trabalho de recuperação de notas
; Matéria: Linguagens de montagem
; Professor: Gabriela Stein
; Alunos: André Gustavo Franco e Matheus Barros
; Linkagem e Montagem:
; nasm -f elf64 Trabalho_2.asm -o Trabalho_2.o; gcc -m64 -no-pie -o Trabalho_2 Trabalho_2.o -lm

section .data

    format_scanf: db "%f%c" ; Formato das leituras do scanf, ver linha 63
    saida_temperatura: db "Média das Temperaturas: %.2f °C", 10, 0 
    saida_umidade: db "Média da Umidade: %.2f %%", 10, 0

    anomalias_1: db "Anomalias: ", 10, 0
    anomalias_2: db 9,"•  Temperatura %.2f fora do intervalo esperado",10, 0
    anomalia_virgula: db ", "
    anomalia_final: db "", 10, 0

    conversao_1: db "Conversões: ",10,0
    conversao_2: db 9,"•  %.2f °C -> %.2f °F", 10, 0

    const_nove: dd 9.0
    const_cinco: dd 5.0
    const_trinta_dois: dd 32.0

section .bss
; variáveis de entrada 
    vetor_temperatura resd 64        ; onde os valores de temperatura serão armazenados 
    vetor_umidade resd 64            ; onde os valores de umidade serão armazenados    
    
; varíaveis de controle
    media_temperatura resd 1         ; onde a média das temperaturas será armazenada
    media_umidade resd 1             ; onde a média das umidades será armazenada
    desvio_temperatura resd 1        ; onde o desvio padrao das temperaturas será armazenada

    compararQuebraDeLinha resb 1     ; onde será guardado o 2° caracter lido nos loops de scanf de leitura das entradas, ver linha 73
    bufferFloat resd 1               ; buffer temporário de leitura dos valores de entrada

; variáveis para o print de saída
    anomalias_buffer resd 64         ; deve ser do mesmo tamanho que vetor_temperatura  ARRUMAR, nn sabemos quantos dados serão lidos
    conversao_buffer resd 64         ; onde os valores convertidos serão armazenados
    nAnomalias resb 1                ; número de anomalias identificadas
    nConversoes resb 1               ; número de entradas lidas

section .text
    global main
    extern scanf, printf

main:
    ; Inicializa o stack frame
    push rbp
    mov rbp, rsp
    
    ; primeiro scanf -> vetor_temperaturas
        ; guardar o número de floats lidos em nConversoes

    xor rbx, rbx

loop_scanf_temperaturas_start:


    mov rax, 0
    lea rdi, [format_scanf]              ; "%f%c"
    lea rsi, [bufferFloat]          
    lea rdx, [compararQuebraDeLinha]

    call scanf
    
    movss xmm0, [bufferFloat]
    movss [vetor_temperatura+rbx*4], xmm0 ; guardar o float lido no vetor
    inc rbx

    mov eax, [compararQuebraDeLinha]      ; verifica-se se é o fim da entrada de temperaturas
    cmp al, 10 ; quebra de linha 
    je loop_scanf_temperaturas_end        ; se é vai para o final, linha 79

    jmp loop_scanf_temperaturas_start     ; se não volta para o começo, linha 59

loop_scanf_temperaturas_end:

    mov byte [nConversoes], bl ; salvar a quantidade de elementos lidos
    
    ; segundo scanf  -> vetor_umidade
    xor rbx, rbx

loop_scanf_umidades_start:
; mesmo processo da leitura de temperaturas
    mov rax, 0
    lea rdi, [format_scanf]
    lea rsi, [bufferFloat] 
    lea rdx, [compararQuebraDeLinha]

    call scanf
    
    movss xmm0, [bufferFloat]
    movss [vetor_umidade+rbx*4], xmm0 
    
    inc rbx

    mov eax, [compararQuebraDeLinha]
    cmp al, 10
    je loop_scanf_umidades_end
    
    jmp loop_scanf_umidades_start

loop_scanf_umidades_end:


; Calculo de media e variancia
calcular_medias:
    xor rbx, rbx
    xorps xmm1, xmm1 ; Clear no xmm1
    xorps xmm2, xmm2 ; Clear no xmm2
    xorps xmm3, xmm3 ; sera utilizado para guardar o rbx (iterador)


loop_calcular_media:
        addss xmm1, [vetor_temperatura + rbx*4] ; xmm1 += temperatura[i]
        addss xmm2, [vetor_umidade + rbx*4]     ; xmm2 += umidade[i]
        inc rbx                                 ;i++
        cmp byte [nConversoes], bl
        jz fim_loop_calcular_media
        jmp loop_calcular_media

fim_loop_calcular_media:
    cvtsi2ss xmm3, rbx 
    divss xmm1, xmm3                            ; somatório/n
    divss xmm2, xmm3                            ; somatório/n
        
    movss [media_temperatura], xmm1
    movss [media_umidade], xmm2

    jmp calcular_desvio_padrao

calcular_desvio_padrao:

    xor rbx, rbx
    xorps xmm1, xmm1 
    xorps xmm2, xmm2
    xorps xmm3, xmm3


    ; calcular variancia
    ; formula: somatorio(x[i] - media)² / (n - 1)
    ;
    ; utiliza xmm2 para guardar cada (x[i] - media_x[i])
    ; e guarda os somatorios em xmm1 e xmm2
    
    loop_calcular_variancia:
        ; variancia da temperatura

        movss xmm2, [vetor_temperatura + rbx*4] ; += temperatura[i]
        subss xmm2, [media_temperatura] 
        mulss xmm2, xmm2                        ; xmm2²
        addss xmm1, xmm2                        ; somatório
        inc rbx                                 ; i++ 
        cmp byte [nConversoes], bl
        jz fim_loop_calcular_variancia
        jmp loop_calcular_variancia

    fim_loop_calcular_variancia:
    
    xor rax, rax
    mov al, byte [nConversoes]
    cvtsi2ss xmm3, rax

    divss xmm1, xmm3                            ; somatório / n

    sqrtss xmm1, xmm1 ; desvio padrao = sqrt(variancia)
    movss [desvio_temperatura], xmm1

    jmp verificar_anomalias

verificar_anomalias:
    xor rbx, rbx ; iterador
    xor rcx, rcx ; guardara iterador do vetor de anomalias
    xor rdx, rdx ; guardará contador de anomalias

    xorps xmm1, xmm1
    xorps xmm3, xmm3 ; guardara media_temperatura + desvio padrao ou media_temperatura - desvio padrao

loop_verificar_anomalias:

        movss xmm1, [vetor_temperatura + rbx*4] ; xmm1 = temperatura[i]

        movss xmm3, [media_temperatura] ; xmm3 = media
        addss xmm3, [desvio_temperatura] ; xmm3 = media + desvio padrao

        ucomiss xmm1, xmm3 ; xmm3 = media + 1 desvio padrao
        ja anomalia_encontrada ; se teemperatura > desvio padrao

        ; Verificando se passa do desvio padrão inferior
        movss xmm3, [media_temperatura]
        subss xmm3, [desvio_temperatura] ; xmm3 = media - desvio padrao

        ucomiss xmm1, xmm3  ; verifica se a leitura está abaixo do desvio padrão ; xmm1 está sendo zerado
        jb anomalia_encontrada ; se teemperatura < desvio padrao
        jmp anomalia_nao_encontrada


anomalia_encontrada:
            movss [anomalias_buffer + rdx*4], xmm1 ; move o valor da anomalia para o vetor de anomalias
            add rdx, 1
        
        ; É necessário passar por anomalia_nao_encontrada para incrementar rbx e ver se o loop acabou
        ; entao nao se deve colocar jump para o começo do loop entre anomalia encontrada e nao encontrada


anomalia_nao_encontrada:

            inc rbx ; i++
            cmp byte [nConversoes], bl
            jz fim_loop_verificar_anomalias
            jmp loop_verificar_anomalias
            
    fim_loop_verificar_anomalias:

    mov byte [nAnomalias], dl

    xor rbx, rbx
    xor rcx, rcx

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

    ; Comparadacao para o jump
    cmp rbx, rax 
    je loop_conversao_end

    ; Pega as constantes 9, 5 e 32 para o calculo da conversao
    movss xmm1, [const_nove] 
    movss xmm2, [const_cinco]
    movss xmm3, [const_trinta_dois]

loop_conversao_start:

    je loop_conversao_end

    ; Conversao ºC -> ºF
    movss xmm0, dword [vetor_temperatura+rbx*4]
    mulss xmm0, xmm1
    divss xmm0, xmm2
    addss xmm0, xmm3

    movss dword [conversao_buffer+rbx*4], xmm0 ; Move para o vetor de conversoes

    inc rbx
    
    cmp rbx, rax
    jmp loop_conversao_start

loop_conversao_end:

;--------------------------------------------------------------------------------------;

print_saida:
    mov rax, 1                   ; rax = 1 argumento
    lea rdi, [saida_temperatura] ; argumento de formato para o  print "Média das Temperaturas: %f °C"
    movss xmm0, [media_temperatura]   
    cvtss2sd xmm0, xmm0          ; conversão de float (32 bits) para 64 bits
    call printf

    mov rax, 1                   ; rax = 1 argumento
    lea rdi, [saida_umidade]     ; argumento de formato para o  print "Média das umidades: %f "
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

    movzx r10, byte [nConversoes]
    test r10, r10
    jz loop_print_anomalias_end

    mov rbx, 0                               ; iterador

loop_print_anomalias_start:
    cmp bl, byte [nAnomalias] 
    je loop_print_anomalias_end

    mov rax, 1                               ; rax = 1 argumento
    lea rdi, [anomalias_2]                   ; argumento de formato para o print "Temperatura %f fora do intervalo esperado"
    movss xmm0, dword [anomalias_buffer + 4*rbx]
    cvtss2sd xmm0, xmm0                      ; conversão de float (32 bits) para 64 bits  
    call printf

    inc rbx  
    
    xor rax, rax
    cmp rbx, r10
    je loop_print_anomalias_end

    ; lea rdi, [anomalia_virgula]             ; argumento de formato para o print ",  "  
    ; call printf

                                   ; incremento do rbx
    jmp loop_print_anomalias_start
    
loop_print_anomalias_end:

    xor rax, rax
    lea rdi, [anomalia_final]               ; argumento de formato para o print "\n "  
    call printf

;--------------------------------------------------------------------------------------;

; loop printando as conversões

    xor rbx, rbx
    xorps xmm0, xmm0
    
    xor rax, rax
    lea rdi, [conversao_1]                     ; argumento de formato para o  print "Conversões: ",10,10,0
    call printf
                         ; número de conversões realizadas
    mov rbx, 0                                 ; iterador
    
loop_print_conversoes_start:
    cmp rbx, [nConversoes]
    je loop_print_conversoes_end
loop_print_conversoes_1:

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