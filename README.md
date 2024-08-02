# Assembleur 
## Pour une architecture x86
### Notions importantes
<img src="./src/images/registres.png"/>

**Leçon 1 : Hello world!**  
1 - Crée un fichier `.asm` en faisant par exemple `touch helloworld.asm`  
2 - Mettre un programme ex :  
  
```asm
section .data
	message db 'Hello world!', 0xA ; création d'un message à afficher à l'écran, ici 'Hello world!' que l'on vient stocker dans message et 0xA permet d'ajouter un retour à la ligne plus ou moins équivalent à message = 'Hello world!\n'
	messageLen db equ $-message ; Calcul la longueur de la chaîne

section .text
	global _start ; Déclare la section de code, global déclare l'étiquette _start comme point d'entré du programme, un peut comme un apelle de fonction du genre : int main() { _sart(); }

_start:
	mov eax, 4 ; Apelle du syscall 4 qui correspond à sys_write voir https://github.com/torvalds/linux/blob/master/arch/x86/entry/syscalls/syscall_32.tbl pour plus d'infos
	mov ebx, 1 ; Charge le stdout dans 
	mov ecx, message ; Charge l'adresse de message dans l'ecx
	mov edx, messageLen ; Charge la longeur de la châine dans edx
	int 0x80 ; Apelle le noyau pour effectuer l'appelle au syscall sys_write

  ; Sortie propre du programme
	mov eax, 1 ; Apelle du syscall 1 qui correpond à sys_exit
	xor ebx, ebx ; Met l'ebx à 0 pour avoir un exit(0)
	int 0x80 ; Apelle le noyau pour exécuter le sys_exit
```
  
3 - Pour assembler le fichier source `helloworld.asm` en utilisant le format de sortie obj et produit un fichier objet `helloworld.o` : `nasm -f elf32 helloworld.asm -o helloworld.o`  
4 - On assemble le fichier objet en utilisant l'architecture x86 et gener un exécutable : `ld -m elf_i386 helloworld.o -o helloworld`  

**Leçon 2 : Saisie utilisateur**  
1 - Crée un fichier `.asm` en faisant par exemple `touch user.asm`  
2 - Mettre un programme ex :  
  
```asm
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
```
  
3 - Pour assembler le fichier source `user.asm` on crée un Makefile contenant :  
```make
FILE=user

Assemble:
	@echo "Compiling..."
	nasm -f elf32 $(FILE).asm -o $(FILE).o
	ld -m elf_i386 -o $(FILE) $(FILE).o
```
