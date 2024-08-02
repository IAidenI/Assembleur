; ############## DEFINE ##############
; #      Canaux de communication     #
%define STDIN  0
%define STDOUT 1

; #       Syscall for x86 arch       #
%define SYS_EXIT  1
%define SYS_READ  3
%define SYS_WRITE 4

; #        Some useful define        #
%define BUFFER_SIZE 20

section .data
	prompt    db 'Veuillez vous identifier : ', 0xA ; Stock dans prompt le prompt
	promptLen equ $-prompt                          ; Calcule automatiquement la longueur du prompt

	user   db '(username)> ' ; Stock dans user l'instruction à faire
	userLen equ $-user       ; Calcule automatiquement la longueur du nom d'utilisateur

	passwd    db '(password)> ' ; Stock dans passwd l'instruction suivant
	passwdLen equ $-passwd      ; Calcule automatiquement la longueur du mot de passe

	secret     db 'Secret'  ; Stock une donnée secrète
	secretLen  equ $-secret ; Calcule automatiquement la longueur du secret

	loggedPart1    db 0xA, 'Bon retour '  ; Stock dans loggedPart1 la première partie du message de log
	loggedPart1Len equ $-loggedPart1 ; Calcule automatiquement la longueur du message

	loggedPart2    db ' vous êtes désormais connecté.' ; Stock dans loggedPart1 la deuxième partie du message de log
	loggedPart2Len equ $-loggedPart2                   ; Calcule automatiquement la longueur du message

	loose    db 0xA, 'Mauvais mot de passe, vous avez saisi :', 0xA ; Stock dans loose le message en cas de mauvais mot de passe
	looseLen equ $-loose                                            ; Calcule automatiquement la longueur du message

section .bss
        username       resb BUFFER_SIZE ; Crée un buffer d'une taille spécifique pour stocker l'username
	password       resb BUFFER_SIZE ; Crée un buffer d'une taille spécifique pour stocker le password
	inputUserLen   resd 1           ; Stockage pour la longueur que l'utilisateur aura saisie (alloue 4 octets)
        inputPasswdLen resd 1           ; Stockage pour la longueur que l'utilisateur aura saisie (alloue 4 octets) voir https://stackoverflow.com/questions/44860003/how-many-bytes-do-resb-resw-resd-resq-allocate-in-nasm

section .text
	global _start ; Equivalent à un main()

_start:
	; Affichage du prompt
	mov eax, SYS_WRITE ; Charge le syscall write
	mov ebx, STDOUT    ; Charge le flux de sortie
	mov ecx, prompt    ; Charge le texte à afficher
	mov edx, promptLen ; Charge longueur du texte à afficher
	int 0x80           ; Appelle du syscall

	; Afficher l'instruction (username)>
	mov eax, SYS_WRITE ; Charge le syscall write
	mov ebx, STDOUT    ; Charge le flux de sortie
	mov ecx, user      ; Charge le texte à afficher
	mov edx, userLen   ; Charge longueur du texte à afficher
	int 0x80           ; Appelle du syscall

	; Récupération le nom d'utilisateur
	mov eax, SYS_READ       ; Charge le syscall read
	mov ebx, STDIN          ; Charge le flux d'entrée
	mov ecx, username       ; Charge le buffer qui va stocker la saisie utilisateur
	mov edx, BUFFER_SIZE    ; Charge la taille du buffer dans lequelle on va stocker la saisie utilisateur
	int 0x80                ; Appelle du syscall
	mov [inputUserLen], eax ; Charge la longueur de la saisie utilisateur

        ; Enlève le \n
	mov eax, [inputUserLen]   ; Charge la taille de la saisie
	mov ecx, username         ; Charge la saisie utilisateur
	dec eax                   ; Décrement l'eax (donc la longueur de la saisie) de 1
	mov byte [ecx, eax], 0    ; On va à ecx[eax] --> le dernier caractère de la chaîne que lon remplace par 0
	mov [inputUserLen], eax ; Met à jour la longueur

	; Affiche l'instruction (password)>
        mov eax, SYS_WRITE        ; Charge le syscall write
        mov ebx, STDOUT           ; Charge le flux de sortie
        mov ecx, passwd           ; Charge le texte à afficher
        mov edx, passwdLen        ; Charge longueur du texte à afficher
        int 0x80                  ; Appelle du syscall

        ; Récupération du mot de passe
        mov eax, SYS_READ         ; Charge le syscall read
        mov ebx, STDIN            ; Charge le flux d'entrée
        mov ecx, password         ; Charge le buffer qui va stocker la saisie utilisateur
        mov edx, BUFFER_SIZE      ; Charge la taille du buffer dans lequelle on va stocker la saisie utilisateur
        int 0x80                  ; Appelle du syscall
	mov [inputPasswdLen], eax ; Charge la longueur de la saisie utilisateur

	; Enlève le \n
	mov eax, [inputPasswdLen] ; Charge la taille de la saisie
	mov ecx, password         ; Charge la saisie utilisateur
	dec eax                   ; Décrement l'eax (donc la longueur de la saisie) de 1
	mov byte [ecx, eax], 0    ; On va à ecx[eax] --> le dernier caractère de la chaîne que lon remplace par 0
	mov [inputPasswdLen], eax ; Met à jour la longueur

	; Vérifie que le mot de passe est correct
	mov esi, password  ; Charge la saisie utilisateur
	mov edi, secret    ; Charge la chaîne secret
	mov ecx, secretLen ; Charge la longueur de la chaine secret
	repe cmpsb         ; Compare les chaînes caractères par caractères
	jnz Looser         ; Si différente jump

	; Si les valeurs sont égales alors affichage
	mov eax, SYS_WRITE      ; Charge le syscall write
	mov ebx, STDOUT         ; Charge le flux de sortie
	mov ecx, loggedPart1    ; Charge le texte à afficher
	mov edx, loggedPart1Len ; Charge longueur du texte à afficher
	int 0x80                ; Appelle du syscall

	; Affiche le nom de l'utilisateur
	mov eax, SYS_WRITE      ; Charge le syscall write
	mov ebx, STDOUT         ; Charge le flux de sortie
	mov ecx, username       ; Charge le texte à afficher
	mov edx, [inputUserLen] ; Charge longueur du texte à afficher
	int 0x80                ; Appelle du syscall

	; Affiche la deuxième partie
	mov eax, SYS_WRITE      ; Charge le syscall write
	mov ebx, STDOUT         ; Charge le flux de sortie
	mov ecx, loggedPart2    ; Charge le texte à afficher
	mov edx, loggedPart2Len ; Charge longueur du texte à afficher
	int 0x80                ; Appelle du syscall

	; Termine le programme proprement
	jmp _end

Looser:
	; Si les valeurs ne sont pas égales alors message
	mov eax, SYS_WRITE ; Charge le syscall write
	mov ebx, STDOUT    ; Charge le flux de sortie
	mov ecx, loose     ; Charge le texte à affiche
	mov edx, looseLen  ; Charge longueur du texte à afficher
	int 0x80           ; Appelle du syscall

	; Affiche le mot de passe saisie par l'utilisateur
	mov eax, SYS_WRITE        ; Charge le syscall write
	mov ebx, STDOUT           ; Charge le flux de sortie
	mov ecx, password         ; Charge le texte à affiche
	mov edx, [inputPasswdLen] ; Charge longueur du texte à afficher
	int 0x80                  ; Appelle du syscall

	; Termine le programme proprement
	jmp _end

_end:
	; Permet de sortir proprement du programme
	mov eax, SYS_EXIT ; Charge dans l'eax le syscall exit
	xor ebx, ebx      ; Charge dans l'ebx la valeur 0 permet d'avoir exit(0)
	int 0x80          ; Appelle du syscall
