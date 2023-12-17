.data
mazeFilename:    .asciiz "input_1.txt"
buffer:          .space 4096
victoryMessage:  .asciiz "You have won the game!"

instructions: .asciiz "Before you start, carefully read the instructions. You will interact with the game using your keyboard to navigate through the map."
instructions2: .asciiz "Valid inputs include:"
instructions3: .asciiz "'z' for upward movement"
instructions4: .asciiz"'s' for downward movement"
instructions5: .asciiz "'q' for leftward movement"
instructions6: .asciiz"'d' for rightward movement"
instructions7: .asciiz "If you enter a character that is not one of the specified inputs, the player won't move, and you will receive the following message: Unknown input!. However, you can still continue with the game by using a valid character. You cannot move through walls. If you attempt to do so, you will receive the following message: 'Invalid next position!' Continue by moving to a location that is not a wall. The game will automatically conclude once you reach the endpoint. Enjoy the game!"
instructions8: .asciiz "You can now begin by providing inputs to move your player. Your inputs will be displayed here"
instructions9: .asciiz "Inputs:"
instructionx: .asciiz "'x' used to manually end the game"


UP_OUTPUT:       .asciiz " up\n"
DOWN_OUTPUT:     .asciiz " down\n"
LEFT_OUTPUT:     .asciiz " left\n"
RIGHT_OUTPUT:    .asciiz " right\n"
UNKNOWN_OUTPUT:  .asciiz " Unknown input! Valid inputs: z s q d x\n"
Ongeldige_positie: .asciiz " Invalid next postion! \n"
Congratulations: .asciiz "Thank you for playing! Until next time."
newline:    .asciiz "\n"

# Definieer de kleuren
wallColor:       .word 0x004286F4    # Kleur voor muren (blauw)
passageColor:    .word 0x00000000    # Kleur voor doorgangen (zwart)
playerColor:     .word 0x00FFFF00    # Kleur voor speler (geel)
exitColor:       .word 0x0000FF00    # Kleur voor uitgang (groen)

# Definieer de letters voor de verschillende vakjes
wallLetter:      .asciiz "w"         # Letter voor muren
passageLetter:   .asciiz "p"         # Letter voor doorgangen
playerLetter:    .asciiz "s"         # Letter voor speler
exitLetter:      .asciiz "u"         # Letter voor uitgang

# Houd de positie van de speler bij
playerRij:       .word 0
playerKolom:     .word 0

.text

    li $v0, 4
    la $a0, instructions
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions2
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions3
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions4
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions5
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions6
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructionx
    syscall 
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions7
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions8
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, instructions9
    syscall


    
main: #  deze functie om code te structureren en andere functie op te roepen, ga na een functie ALTIJD terug naar hier, dit doe je met "jr $ra"
    jal spel_openen
    jal Geheugenadres
    jal loop
    

main_loop: 
    
    # Vraag de gebruiker om input
    li $v0, 8
    la $a0, buffer
    li $a1, 256
    syscall

    la $t2, buffer
    beq $t2, 122, move_up        # 'z'
    beq $t2, 115, move_down      # 's'
    beq $t2, 113, move_left      # 'q'
    beq $t2, 100, move_right     # 'd'
    beq $t2, 120, end_program    # 'x'

    # Wacht 60ms met behulp van de "sleep" syscall
    li $v0, 32      # syscall voor sleep
    li $a0, 60      # aantal milliseconden om te slapen
    syscall

    j main_loop

spel_openen:


    li $v0, 13                   # Systeemoproepnummer voor het openen van een bestand
    la $a0, mazeFilename         # Adres van de bestandsnaam
    li $a1, 0                    # Modus "read-only"
    li $a2, 0
    syscall                      # Voer de systeemoproep uit
    move $s6, $v0                # Bewaar het bestandsdescriptor

    li $v0, 14                   # Systeemoproepnummer voor het lezen van een bestand
    move $a0, $s6                # Bestandsdescriptor
    la $a1, buffer               # Adres van de buffer
    li $a2, 4096                 # Aantal te lezen bytes
    syscall                      # Voer de systeemoproep uit

    # Lees het bestand opnieuw
    li $v0, 14
    move $a0, $s6
    la $a1, buffer
    li $a2, 4096
    syscall

    # Initialiseren van rij- en kolomtellers
    li $t0, 0                    # Rijteller
    li $t1, 0                # Kolomteller
    la $t9, buffer               # Pointer naar het begin van de buffer
    
    jr $ra #dit toevoegen aan einde functie, om teurg te gaan naar waar je deze had opgeroepen "jal"
    
    
Geheugenadres:
    lw $s0, playerRij           # Ingevoerde rijnummer in $s0
    li $s2, 32                   # Breedte van het scherm
    mul $s1, $s0, $s2            # $s1 = $s0 * 32 (rijnummer * breedte van het scherm)


    lw $s0, playerKolom         # Ingevoerde kolomnummer in $s0
    add $s1, $s1, $s0            # $s1 = $s1 + $s0 (geheugenadres = rijnummer * breedte + kolomnummer)
    mul $s1, $s1, 4              # Elke pixel is 32 bits, dus vermenigvuldig met 4 voor het geheugenadres
    add $s1, $s1, $gp            # $s1 bevat nu het uiteindelijke geheugenadres
    


    # Uitlijnen naar het volgende woord
    addi $s1, $s1, 3
    andi $s1, $s1, -4
    
    jr $ra # teruggaan naar waar de functie was opgeroepen

# Begin de loop om het doolhof te verwerken
loop: 
    lb $t2, ($t9)                # Laad het huidige karakter van de buffer

    # Controleer het einde van de buffer
    beqz $t2, speler_beweging

    # Controleer op een nieuwe regel
    li $t3, 10                   # ASCII voor newline
    beq $t2, $t3, new_line

    # Verwerk het vakje
    beq $t2, 119, is_wall        # 'w'
    beq $t2, 112, is_passage     # 'p'
    beq $t2, 115, is_player      # 's'
    beq $t2, 117, is_exit        # 'u'
    
    
	volgende_byte:
    		addi $t9, $t9, 1             # Verhoog de bufferpointer
    		addi $t1, $t1, 1             # Verhoog de kolomteller
    		j loop

	is_wall:
    		lw $t3, wallColor
    		sw $t3, 0($s1)               # Bewaar de ingevoerde kleur op het geheugenadres
    		addi $s1, $s1, 4             # Verhoog het geheugenadres met 4
    		j volgende_byte

	is_passage:
    		lw $t3, passageColor
    		sw $t3, 0($s1)               # Bewaar de ingevoerde kleur op het geheugenadres
    		addi $s1, $s1, 4             # Verhoog het geheugenadres met 4
    		j volgende_byte

	is_player:
	
    		# Store the current position of the player
    		subi $t1, $t1, 1
    		sw $t0, playerRij     # Save the current row
    		sw $t1, playerKolom   # Save the current column


    		# Load the color of the player
    		la $t3, playerColor
    		lw $t6, 0($t3)         # Load the color value of playerColor into $t6

    		# Save the color value at the current memory address
    		sw $t6, 0($s1)         # Save the color value at the current memory address
    		addi $s1, $s1, 4       # Increment the memory address by 4

    		# Continue to the next byte
    		j volgende_byte


	is_exit:
    		lw $t3, exitColor
    		sw $t3, 0($s1)               # Bewaar de ingevoerde kleur op het geheugenadres
    		addi $s1, $s1, 4             # Verhoog het geheugenadres met 4
    		j volgende_byte

		
	new_line:
    		li $t1, 0                    # Zet de kolomteller op 0
    		addi $t0, $t0, 1             # Verhoog de rijteller
    		j volgende_byte              # Spring naar het label volgende_byte

    


speler_beweging:
    # Stackframe voor lokale variabelen en terugkeeradres
    subu $sp, $sp, 8

    # Opslaan van lokale variabelen op de stack
    sw $t4, 0($sp)
    sw $t2, 4($sp)

    # Input vragen van de gebruiker
    li $v0, 12                   # Systeemoproepnummer voor het lezen van een teken
    la $a0, buffer               # Adres van de buffer
    li $a1, 256                  # Maximum aantal tekens om te lezen
    syscall                      # Voer de systeemoproep uit

    move $t2, $v0                # Bewaar het ingevoerde karakter in $t2

    # Vergelijken van het ingevoerde karakter met de verwachte toetsen
    beq $t2, 122, move_up        # 'z'
    beq $t2, 115, move_down      # 's'
    beq $t2, 113, move_left      # 'q'
    beq $t2, 100, move_right     # 'd'
    beq $t2, 120, end_program    # 'x'

    # Onbekende input
    j unknown_input

unknown_input:
    li $v0, 4                    # Systeemoproepnummer voor het afdrukken van een string
    la $a0, UNKNOWN_OUTPUT       # Adres van de te printen string
    syscall                      # Voer de systeemoproep uit
    j loop                       # Spring terug naar de hoofdloop

    # Herstellen van lokale variabelen vanaf de stack
    lw $t4, 0($sp)
    lw $t2, 4($sp)

    # Opruimen van het stackframe
    addu $sp, $sp, 8
    j speler_beweging            # Ga terug naar de functie speler_beweging


move_up:
    lw $t5, playerRij          # Laad het huidige rijnummer van de speler
    lw $t6, playerKolom        # Laad het huidige kolomnummer van de speler
    
    subi $t5, $t5, 1            # Verminder het rijnummer (ga omhoog)
    jal controleer_geldigheid   # Roep de functie aan om de geldigheid van de nieuwe positie te controleren
    beqz $t7, skip_move_up      # Als de nieuwe positie ongeldig is, sla de beweging over en spring naar skip_move_up
    addi $t5, $t5, 1            # Als de nieuwe positie geldig is, herstel het rijnummer en ga door
    
    jal zwart                   # Roep de functie aan om de kleur van de vorige positie naar zwart te wijzigen
    subi $t5, $t5, 1            # Verminder het rijnummer opnieuw (ga omhoog)
    sw $t5, playerRij           # Sla het nieuwe rijnummer op
    jal geel                    # Roep de functie aan om de kleur van de nieuwe positie naar geel te wijzigen

    j loop                      # Spring terug naar de hoofdloop


skip_move_up:
    li $v0, 4          # Laad syscall-nummer 4 in $v0 (print_string)
    la $a0, Ongeldige_positie  # Laad het adres van de string "Invalid next position!" in $a0
    syscall            # Roep het print_string-systeemoproep aan om de boodschap af te drukken
    j loop             # Spring terug naar de hoofdloop


move_down:
    lw $t5, playerRij          # Laad het huidige rijnummer van de speler
    lw $t6, playerKolom        # Laad het huidige kolomnummer van de speler
    
    addi $t5, $t5, 1            # Verhoog het rijnummer (ga omlaag)
    jal controleer_geldigheid   # Roep de functie aan om de geldigheid van de nieuwe positie te controleren
    beqz $t7, skip_move_down    # Als de nieuwe positie ongeldig is, sla de beweging over en spring naar skip_move_down
    subi $t5, $t5, 1            # Als de nieuwe positie geldig is, herstel het rijnummer en ga door
    
    jal zwart                   # Roep de functie aan om de kleur van de vorige positie naar zwart te wijzigen
    addi $t5, $t5, 1            # Verhoog het rijnummer opnieuw (ga omlaag)
    sw $t5, playerRij           # Sla het nieuwe rijnummer op
    jal geel                    # Roep de functie aan om de kleur van de nieuwe positie naar geel te wijzigen

    j loop                      # Spring terug naar de hoofdloop

    
skip_move_down:
    li $v0, 4          # Laad syscall-nummer 4 in $v0 (print_string)
    la $a0, Ongeldige_positie  # Laad het adres van de string "Invalid next position!" in $a0
    syscall            # Roep het print_string-systeemoproep aan om de boodschap af te drukken
    j loop             # Spring terug naar de hoofdloop

    
    

move_left:
    lw $t6, playerKolom         # Laad het huidige kolomnummer van de speler
    lw $t5, playerRij            # Laad het huidige rijnummer van de speler
    
    subi $t6, $t6, 1             # Verminder het kolomnummer (ga naar links)
    jal controleer_geldigheid    # Controleer of de volgende positie geldig is
    beqz $t7, skip_move_left     # Als de volgende positie geen muur is, sla deze beweging over
    addi $t6, $t6, 1             # Als de volgende positie geldig is, herstel het kolomnummer en ga door
    
    jal zwart                    # Roep de functie aan om de kleur van de vorige positie naar zwart te wijzigen
    subi $t6, $t6, 1             # Verminder het kolomnummer opnieuw (ga naar links)
    sw $t6, playerKolom          # Sla het nieuwe kolomnummer op
    jal geel                     # Roep de functie aan om de kleur van de nieuwe positie naar geel te wijzigen

    j loop                       # Spring terug naar de hoofdloop

    
skip_move_left:
    li $v0, 4          # Laad syscall-nummer 4 in $v0 (print_string)
    la $a0, Ongeldige_positie  # Laad het adres van de string "Invalid next position!" in $a0
    syscall            # Roep het print_string-systeemoproep aan om de boodschap af te drukken
    j loop             # Spring terug naar de hoofdloop

    
    
move_right:
    lw $t6, playerKolom         # Laad het huidige kolomnummer van de speler
    lw $t5, playerRij            # Laad het huidige rijnummer van de speler

    addi $t6, $t6, 1             # Verhoog het kolomnummer (ga naar rechts)
    jal controleer_geldigheid    # Controleer of de volgende positie geldig is
    beqz $t7, skip_move_right    # Als de volgende positie geen muur is, sla deze beweging over
    subi $t6, $t6, 1             # Als de volgende positie geldig is, herstel het kolomnummer en ga door
    
    jal zwart                    # Kleur de huidige positie zwart
    addi $t6, $t6, 1             # Verhoog het kolomnummer opnieuw (ga naar rechts)
    sw $t6, playerKolom          # Sla het nieuwe kolomnummer op
    jal geel                     # Kleur de nieuwe positie geel

    j loop                       # Spring terug naar de hoofdloop

    
skip_move_right:
    li $v0, 4          # Laad syscall-nummer 4 in $v0 (print_string)
    la $a0, Ongeldige_positie  # Laad het adres van de string "Invalid next position!" in $a0
    syscall            # Roep het print_string-systeemoproep aan om de boodschap af te drukken
    j loop             # Spring terug naar de hoofdloop



zwart:
    # Stackframe voor lokale variabelen en terugkeeradres
    subu $sp, $sp, 16

    # Opslaan van lokale variabelen op de stack
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)

    # Bereken het geheugenadres van de huidige positie van de speler
    lw $t0, playerRij  # Laden van de waarde van playerRij in $t0
    lw $t1, playerKolom  # Laden van de waarde van playerKolom in $t1
    
    lw $s0, playerRij           # Ingevoerde rijnummer in $s0
    li $s2, 32                   # Breedte van het scherm
    mul $s1, $s0, $s2            # $s1 = $s0 * 32 (rijnummer * breedte van het scherm)
    lw $s0, playerKolom         # Ingevoerde kolomnummer in $s0
    add $s1, $s1, $s0            # $s1 = $s1 + $s0 (geheugenadres = rijnummer * breedte + kolomnummer)
    mul $s1, $s1, 4              # Elke pixel is 32 bits, dus vermenigvuldig met 4 voor het geheugenadres
    add $s1, $s1, $gp            # $s1 bevat nu het uiteindelijke geheugenadres
    
    move $t2, $s1    # Kopiëren van de waarde naar $t2

    # Update de kleur van de huidige positie naar open ruimte
    lw $t4, passageColor
    sw $t4, 0($t2)
    
    addu $sp, $sp, 16
    
    jr $ra
    
geel:
    # Stackframe voor lokale variabelen en terugkeeradres
    subu $sp, $sp, 16

    # Opslaan van lokale variabelen op de stack
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)

    # Bereken het geheugenadres van de huidige positie van de speler
    move $t0, $t5  # Laden van de waarde van playerRij in $t0
    move $t1, $t6  # Laden van de waarde van playerKolom in $t1
    
    move $s0, $t5       # Ingevoerde rijnummer in $s0
    li $s2, 32                   # Breedte van het scherm
    mul $s1, $s0, $s2            # $s1 = $s0 * 32 (rijnummer * breedte van het scherm)
    move $s0,  $t6        # Ingevoerde kolomnummer in $s0
    add $s1, $s1, $s0            # $s1 = $s1 + $s0 (geheugenadres = rijnummer * breedte + kolomnummer)
    mul $s1, $s1, 4              # Elke pixel is 32 bits, dus vermenigvuldig met 4 voor het geheugenadres
    add $s1, $s1, $gp            # $s1 bevat nu het uiteindelijke geheugenadres
    
    move $t2, $s1    # Kopiëren van de waarde naar $t2

    # Update de kleur van de nieuwe positie naar de speler
    lw $t4, playerColor   # Laad de kleur van de speler in $t4
    sw $t4, 0($t2)         # Sla de kleur op de nieuwe positie op in het geheugen

    # Opruimen van het stackframe
    addu $sp, $sp, 16      # Herstel de stackpointer om het stackframe op te ruimen
    
    jr $ra                 # Keer terug naar de aanroepende functie



controleer_geldigheid:
    move $s0, $t5           # Ingevoerde rijnummer in $s0
    
    # Breedte van het scherm
    li $s2, 32               
    
    # Bereken geheugenadres: $s1 = rijnummer * breedte van het scherm
    mul $s1, $s0, $s2        
    
    # Zet ingevoerde kolomnummer in $s0
    move $s0, $t6            
    
    # $s1 = $s1 + $s0 (geheugenadres = rijnummer * breedte + kolomnummer)
    add $s1, $s1, $s0        
    
    # Elke pixel is 32 bits, dus vermenigvuldig met 4 voor het geheugenadres
    mul $s1, $s1, 4          
    
    # $s1 bevat nu het uiteindelijke geheugenadres
    add $s1, $s1, $gp        
    
    # Laad de kleur van de volgende positie
    lw $t7, 0($s1)           
    
    # Laad de muurkleur
    lw $t3, wallColor        
    
    # Als kleur gelijk is aan muurkleur, ga naar muur_gevonden
    beq $t7, $t3, muur_gevonden
    
    # Controleer of de speler de overwinningspositie heeft bereikt
    lw $t4, exitColor         # Kleur van de overwinningspositie
    beq $t7, $t4, victory_message
    
    # Als het geen muur is, geef aan dat de volgende positie geldig is (zet $t7 op 1)
    li $t7, 1                 

# Eindig de procedure
    jr $ra
    

muur_gevonden:
    # Als het een muur is, geef aan dat de volgende positie ongeldig is
    li $t7, 0         # Laad 0 in $t7 om aan te geven dat de volgende positie ongeldig is

    jr $ra            # Keer terug naar de aanroepende functie


victory_message:

    lw $t6, playerKolom  # Laad het huidige kolomnummer van de speler
    lw $t5, playerRij    # Laad het huidige rijnummer van de speler
    
    jal zwart            # Spring naar de functie 'zwart'


# Print newline
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, victoryMessage
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    
    li $v0, 4
    la $a0, Congratulations
    syscall

end_program:
    li $v0, 10     # Laad syscall-nummer 10 in $v0 (exit)
    syscall        # Roep het exit-systeemoproep aan om het programma te beëindigen

