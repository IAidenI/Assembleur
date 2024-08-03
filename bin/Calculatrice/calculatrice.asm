%define SYS_EXIT  1
%define SYS_READ  3
%define SYS_WRITE 4

%define STDIN  0
%define STDOUT 1

%define BUFFER_SIZE 5

section .data
	prompt1    db "Saisir le premier nombre à additionner (entre 0 et 9) : "
	prompt1Len equ $-prompt1

	prompt2    db "Saisir le second nombre à additionner (entre 0 et 9) : "
	prompt2Len equ $-prompt2

	calculPrompt    db "Résultat de votre calcul : "
	calculPromptLen equ $-calculPrompt

	error    db 0xA "Votre nombre est trop grand.", 0xA
	errorLen equ $-error

	result    db "0"
	resultLen equ $-result

section .bss
	nb1 resb BUFFER_SIZE
	nb2 resb BUFFER_SIZE

	nb1Len resd 1
	nb2Len resd 1

section .text
	global _start

_start:
	; Affiche la demande du premier nombre
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, prompt1
	mov edx, prompt1Len
	int 0x80

	; Stock le premier nombre
	mov eax, SYS_READ
	mov ebx, STDIN
	mov ecx, nb1
	mov edx, BUFFER_SIZE
	int 0x80
	mov [nb1Len], eax

	; Enlève le \n
	mov eax, [nb1Len]
	mov ecx, nb1
	dec eax
	mov byte [ecx, eax], 0
	mov [nb1Len], eax

	; Affiche la demande du second nombre
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, prompt2
	mov edx, prompt2Len
	int 0x80

	; Stock le secon nombre
	mov eax, SYS_READ
	mov ebx, STDIN
	mov ecx, nb2
	mov edx, BUFFER_SIZE
	int 0x80
	mov [nb2Len], eax

	; Enlève le \n
	mov eax, [nb2Len]
	mov ecx, nb2
	dec eax
	mov byte [ecx, eax], 0
	mov [nb2Len], eax

	mov ax, [nb1]
	sub ax, 0x30  ; Soustrait 0x30 pour passer d'une valeur hexa par exemple 0x32 qui correspond à 2 en ascii --> 0x32 - 0x30 = 2

	mov bx, [nb2] ; Idem
	sub bx, 0x30

	; Calcul de l'addition des deux nombres
	add ax, bx

	mov bl, 10            ; Charge dans bl la valeur 10
	xor ecx, ecx          ; Met ecx à 0
	xor edx, edx          ; Met edx à 0
	call Int_To_ASCII     ; Appelle la fonction
	mov eax, [result]     ; Charge dans l'eax le résultat
	bswap eax             ; Inverse les bits pour être en little endian
	mov [result], eax     ; Charge le résultat inversé dans result_str

	; Affichage du résultat
	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, calculPrompt
	mov edx, calculPromptLen
	int 0x80

	mov eax, SYS_WRITE
	mov ebx, STDOUT
	mov ecx, result
	mov edx, 5;result_strLen
	int 0x80

	xor ebx, ebx
	call Exit

Int_To_ASCII:
	div bl                ; Divise ax (numérateur) avec bl (dénominateur), résultat Quotient (al) = 2 - Reste (ah) = 1
	mov dl, ah            ; Charge le reste dans l'edx
	add dx, 48            ; Ajoute 48 au reste
	mov [result+ecx], edx ; ajoute au ecx ème emplacement de result la valeur calculé
	xor dx, dx            ; Met le dx à 0
	mov dl, al            ; Met le quotient dans une registre temporaire
	xor ax, ax            ; Met le ax à 0
	mov al, dl            ; Remplace le numérateur par le quotient
	xor dx, dx            ; Met le dx à 0
	inc ecx               ; Incrémente l'ecx
	cmp ax,  0            ; Compare le numérateur à 0
	jnz Int_To_ASCII      ; Si différent on recommence
	ret                   ; Sinon on retourne au main

Exit:
	mov eax, SYS_EXIT
	xor ebx, ebx
	int 0x80
