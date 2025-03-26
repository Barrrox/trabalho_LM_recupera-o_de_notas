; Linguagens de montagem - Atividade Avaliativa 2
; Alunos: Ellen Brzozoski e Matheus Barros
;
; Resumo do trabalho:
; Cálculo de (soma, subtração, divisão ou multiplicação) de dois PF de precisão simples 
; 
; Descrição:
; Entrada pela linha de comando:
;   Ex: “./trab2 operando1 operador operando2”
;  
; Saída:
;   1. Armazenar o resultado em no arquivo saida.txt
;   2. Criar arquivo se não existir
;   Ex:  operando1 operador operando2 = resultado
;   Ex2: operando1 operador operando2 = 'funcionalidade não disponível'
;
;


section .data
    fmt_exec_correta: db "%lf %c %lf = %lf", 10,0 
    fmt_exec_incorreta: db "%lf %c %lf = funcionalidade não disponível", 10, 0
    msg_quantidade_de_argumentos_incorreta: db "Quantidade de argumentos incorreta", 10, 0
    msg_operador_invalido: db "Operador invalido", 10, 0
    msg_erro_abrir_arquivo: db "Erro ao abrir o arquivo. Encerrando o programa", 10, 0
    arquivo_saida: db "saida.txt", 0
    modo: db "a", 0 ; modo de abertura do arquivo

section .bss
    operand1 resq 1
    operand2 resq 1
    result   resq 1
    operator resb 1

section .text
    global main
    extern fopen, fclose, fprintf, printf, atof


main:

    ; iniciar stackframe
    push rbp
    mov rbp, rsp

    ; Salva os args
    mov rbx, rsi 
    
    ; Verifica quantidade de argumentos
    cmp rdi, 4
    jne quantidade_argumentos_incorreta

    ; Ler e salvar operando1
    mov rdi, [rbx+8]
    call atof ; converte pra DOUBLE
    cvtsd2ss xmm1, xmm0 ; converte de volta para simple float
    movss [operand1], xmm1 

    ; Ler e salvar operando2
    mov rdi, [rbx+24]
    call atof ; converte pra DOUBLE
    cvtsd2ss xmm1, xmm0 ; converte de volta para simple float
    movss [operand2], xmm1 

    ; Ler e salvar operador
    mov rdi, [rbx + 16] 
    movzx rcx, byte [rdi] 

    ; switch

    ; case: a (adicao)
    cmp cl, 'a'
    je caller_adicao

    ; case: s (subtracao)
    cmp cl, 's'
    je caller_subtracao

    ; case: m (multiplicacao)
    cmp cl, 'm'
    je caller_multiplicacao

    ; case: d (divisiao)
    cmp cl, 'd'
    je caller_divisao
    
    ; se nenhuma das opções
    jmp operador_invalido


caller_adicao:
    mov byte [operator], '+' 
    call adicao

    ; escreve a solucao no arquivo e finaliza o programa
    movss [result], xmm0
    call escrevesolucaoOK
    jmp fim

; somar
adicao:
    push rbp           
    mov rbp, rsp
    movss xmm0, [operand1]
    movss xmm1, [operand2]
    
    addss xmm0, xmm1   
    pop rbp            
    ret

caller_subtracao:
    mov byte [operator], '-' 
    call subtracao

    ; escreve a solucao no arquivo e finaliza o programa
    movss [result], xmm0
    call escrevesolucaoOK
    jmp fim


; subtrair
subtracao:
    push rbp            
    mov rbp, rsp

    movss xmm0, [operand1]
    movss xmm1, [operand2]
    subss xmm0, xmm1    
    pop rbp             
    ret

    call escrevesolucaoOK
    jmp fim

caller_multiplicacao:
    mov byte [operator], '*' 
    call multiplicacao

    ; escreve a solucao no arquivo e finaliza o programa
    movss [result], xmm0
    call escrevesolucaoOK
    jmp fim


; multiplicar
multiplicacao:
    push rbp           
    mov rbp, rsp
    movss xmm0, [operand1]
    movss xmm1, [operand2]
    mulss xmm0, xmm1   
    pop rbp             
    ret
    call escrevesolucaoOK

caller_divisao:

    movss xmm1, [operand1]
    movss xmm2, [operand2]
    xorps xmm0, xmm0 ; xorps = xor para regs xmm

    mov byte [operator], '/' 


    ; Comparando xmm1 com 0
    comiss xmm2, xmm0
    je execucao_incorreta
    
    call divisao

    ; escreve a solucao no arquivo e finaliza o programa
    movss [result], xmm0
    call escrevesolucaoOK
    jmp fim


; dividir
divisao:
    push rbp           
    mov rbp, rsp
    movss xmm0, [operand1]
    movss xmm1, [operand2]
    divss xmm0, xmm1   
    pop rbp             
    ret

quantidade_argumentos_incorreta:
    xor rax, rax ; não ha registradores xmm
    mov rdi, msg_quantidade_de_argumentos_incorreta
    call printf
    jmp fim

operador_invalido:
    xor rax, rax
    mov rdi, msg_operador_invalido
    call printf
    jmp fim

execucao_incorreta: 
    call escrevesolucaoNOTOK
    jmp fim

fim:
    ; Finaliza o stack frame (main)
    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall


    
    call escrevesolucaoOK
    jmp fim


escrevesolucaoOK:

    ; StackFrame
    push rbp
    mov rbp, rsp

    ; Abrir o arquivo para escrita (modo de append)
    mov rdi, arquivo_saida          ; Nome do arquivo
    mov rsi, modo                   ; Modo: "a" (append)
    call fopen                      
    mov rbx, rax                    ; Salva o ponteiro do arquivo retornado em rbx

    ; Verifique se o arquivo foi aberto corretamente
    test rbx, rbx
    jz erro_abrir_arquivo

    mov rdi, rbx                    ; rdi = arquivo
    mov rsi, fmt_exec_correta       ; Formato da string a ser escrita
    cvtss2sd xmm0, [operand1]       
    cvtss2sd xmm1, [operand2]       
    movzx rdx, byte [operator]      ; Operador
    cvtss2sd xmm2, [result]        
    mov rax, 3                      ; 3 regs xmm
    call fprintf                    ; Chama fprintf para escrever no arquivo

    ; Fecha o arquivo
    mov rdi, rbx
    call fclose

    ; Fecha o stackframe
    mov rsp, rbp
    pop rbp
    ret

escrevesolucaoNOTOK:

    ; StackFrame
    push rbp
    mov rbp, rsp

    ; Abrir o arquivo para escrita (modo de append)
    mov rdi, arquivo_saida          ; Nome do arquivo
    mov rsi, modo                   ; Modo: "a" (append)
    call fopen                      ; Chama fopen
    mov rbx, rax                    ; Salva o ponteiro do arquivo retornado em rbx

    ; Verifique se o arquivo foi aberto corretamente
    test rbx, rbx
    jz erro_abrir_arquivo

    mov rdi, rbx                    ; Arquivo aberto
    mov rsi, fmt_exec_incorreta       ; Formato da string a ser escrita
    cvtss2sd xmm0, [operand1]       ; Converte float para double
    cvtss2sd xmm1, [operand2]       ; Converte float para double
    movzx rdx, byte [operator]      ; Operador
    mov rax, 2                      ; Número de registradores XMM usados
    call fprintf                    ; Chama fprintf para escrever no arquivo
    ;

    ; Fecha o arquivo
    mov rdi, rbx
    call fclose

    ; Fecha o stackframe
    mov rsp, rbp
    pop rbp
    ret

erro_abrir_arquivo:
    xor rax, rax
    mov rdi, msg_erro_abrir_arquivo
    jmp fim