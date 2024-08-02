; ############## DEFINE ##############
; #      Canaux de communication     #
%define STDIN  0
%define STDOUT 1

; #       Syscall for x86 arch       #
%define SYS_EXIT  1
%define SYS_READ  3
%define SYS_WRITE 4

; #        Some useful define        #
%define BUFFER_SIZE 10

section .data
	prompt    db 'Saisir du text : ', 0xA ; Le texte à afficher
	promptLen equ $-prompt                        ; Calcule automatiquement la longueur du texte à afficher
	user      db 'Vous avez saisi : '             ; Le texte à afficher
	userLen   equ $-user                          ; Calcule automatiquement la longueur du texte à afficher

section .bss
        buffer   resb BUFFER_SIZE ; Crée un buffer d'une taille spécifique
        inputLen resb 1           ; Stockage pour la longueur que l'utilisateur aura saisie

section .text
	global _start ; Equivalent à un main()

_start:
	; Affichage du prompt
	mov eax, SYS_WRITE ; Charge le syscall write
	mov ebx, STDOUT    ; Charge le flux de sortie
	mov ecx, prompt    ; Charge le texte à afficher
	mov edx, promptLen ; Charge longueur du texte à afficher
	int 0x80           ; Appelle du syscall

	; Récupération de la saisie utilisateur
	mov eax, SYS_READ    ; Charge le syscall read
	mov ebx, STDIN       ; Charge le flux d'entrée
	mov ecx, buffer      ; Charge le buffer qui va stocker la saisie utilisateur
	mov edx, BUFFER_SIZE ; Charge la taille du buffer dans lequelle on va stocker la saisie utilisateur
	int 0x80             ; Appelle du syscall
	mov [inputLen], eax ; Charge la longueur de la saisie utilisateur

	; Affichage de la saisie utilisateur
	mov eax, SYS_WRITE  ; Charge le syscall read
	mov ebx, STDOUT     ; Charge le flux de sortie
	mov ecx, user       ; Charge le message à afficher
	mov edx, userLen    ; Charge la longueur du texte à afficher
	int 0x80            ; Apelle du syscall

	mov eax, SYS_WRITE  ; Charge le syscall read
	mov ebx, STDOUT     ; Charge le flux de sortie
	mov ecx, buffer     ; Charge le message à afficher
	mov edx, [inputLen] ; Charge la longueur du texte à afficher
	int 0x80            ; Appelle du syscall

	; Permet de sortir proprement du programme
	mov eax, SYS_EXIT ; Charge dans l'eax le syscall exit
	xor ebx, ebx      ; Charge dans l'ebx la valeur 0 permet d'avoir exit(0)
	int 0x80          ; Appelle du syscall
