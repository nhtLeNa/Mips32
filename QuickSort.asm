.data
	Input: .asciiz "D:/Deadline/C_3/KTMT&HN/asm/input_sort.txt"
	Output: .asciiz "D:/Deadline/C_3/KTMT&HN/asm/output_sort.txt"
	blank: .asciiz "  "
	output: .space 4096
	digits: .space 80
	ocounter: .word 0
	.align 4
	Array: .space 4000
	str: .asciiz ""
.text 
.globl main
main:	
	jal ReadArray
	jal Sorting
	jal PrintArray
	addu $v0, $0, 10
	syscall

PrintArray:
	la $a0, Array
	la $a1, output
	addi $t7, $ra, 0
	jal Convert
	la $a0, Output
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall
	move $a0, $v0
	li $v0, 15
	la $a1, output
	lw $a2, ocounter
	syscall
	li $v0, 16
	syscall
	addi $ra, $t7, 0
	j return
	
ReadArray:
	addi $s4, $ra, 0
	la $a0, Input
	li $v0, 13
	li $a1, 0
	li $a2, 0
	syscall
	move $a0, $v0
	li $v0, 14
	la $a1, str
	li $a2, 1024
	syscall
	li $v0, 16
	syscall
	la $s0, Array
	li $s1, 0
	la $s3, str
	la $a0, str
	jal atoi
	sw $v0, 0($s0)
	addi $s2, $v0, 0
	addi $s0, $s0, 4
	jal Token
	la $s3, 0($v0)
	Loop:
		la $a0, 0($s3)
		jal atoi
		sw $v0, 0($s0)
		addi $s1, $s1, 1
		beq $s1, $s2, End
		addi $s0, $s0, 4
		jal Token
		la $s3, 0($v0)
		j Loop
		End:
			add $ra, $s4, 0
			j return
Token:
	la $v0, 0($a0)
	li $t1, ' '
	LoopToken1:
		lb $t2, 0($v0)
		sgt $t0, $t2, $t1
		beq $t0, $1, Token1
		j LoopToken2
		Token1:
			addi $v0, $v0, 1
			j LoopToken1
	LoopToken2:
		lb $t2, 0($v0)
		seq $t0, $t2, $t1
		beq $t0, $1, Token2
		jr $ra
		Token2:	
			addi $v0, $v0, 1
			j LoopToken2

atoi:
    	or      $v0, $zero, $zero   # num = 0
    	or      $t1, $zero, $zero   # isNegative = false
    	lb      $t0, 0($a0)
    	bne     $t0, '+', Positive      # consume a positive symbol
    	addi    $a0, $a0, 1
	Positive:
    		lb      $t0, 0($a0)
    		bne     $t0, '-', CreateNumber
    		addi    $t1, $zero, 1       # isNegative = true
    		addi    $a0, $a0, 1
	CreateNumber:
    		lb      $t0, 0($a0)
    		slti    $t2, $t0, 58        # *str <= '9'
    		slti    $t3, $t0, '0'       # *str < '0'
    		beq     $t2, $zero, Finish
    		bne     $t3, $zero, Finish
    		sll     $t2, $v0, 1
    		sll     $v0, $v0, 3
    		add     $v0, $v0, $t2       # num *= 10, using: num = (num << 3) + (num << 1)
    		addi    $t0, $t0, -48
    		add     $v0, $v0, $t0       # num += (*str - '0')
    		addi    $a0, $a0, 1         # ++num
    		j   CreateNumber
	Finish:
    		beq     $t1, $zero, return    # if (isNegative) num = -num
    		sub     $v0, $zero, $v0

return:
    	jr      $ra         # return

Convert:
	lw $t4, 0($a0) #load number of elements
	addi $a0, $a0, 4
	lw $t6, ocounter
	Converting:
		lw $t0, 0($a0) #load element
		addi $t1, $0, 0 # count digits
    		la $s0, digits
    		add $s0, $s0, 20
		loopConvert:
    			div $t2, $t0, 10
    			mfhi $t2
			addi $t2, $t2, 48
    			sb $t2, 0($s0)
			addi $t1, $t1, 1
    			div $t0, $t0, 10
    			beqz $t0, MoveToOutput
			subi $s0, $s0, 1
    			b loopConvert
		MoveToOutput:
			LoopConvert:
				lb $t3, 0($s0)
				sb $t3, 0($a1)
				subi $t1, $t1, 1
				addi $t6, $t6, 1
				beqz $t1, Complete
				addi $a1, $a1, 1
				addi $s0, $s0, 1
				b LoopConvert
			Complete:
				subi $t4, $t4, 1
				sw $t6, ocounter
				beqz $t4, return
				li $t5, 32
				addi $a1, $a1, 1
				sb $t5, 0($a1)
				addi $t6, $t6, 1
				addi $a1, $a1, 1
				addi $a0, $a0, 4
				j Converting
QuickSort:
	subi $sp, $sp, 16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $ra, 8($sp)
	bge $a0, $a1, Return
	jal Partition
	addi $s0, $v0, 0
	sw $s0, 12($sp)
	lw $a0, 0($sp)
	la $a1, -4($s0)
	jal QuickSort
	lw $a1, 4($sp)
	lw $s0, 12($sp)
	la $a0, 4($s0)
	jal QuickSort
	j Return

Partition:
	lw $t0, 0($a1)
	la $t1, -4($a0)
	subi $t3, $a1, 4
	LoopPartition:
		lw $t2, 0($a0)
		ble $t2, $t0, SwapPartition
		addi $a0, $a0, 4
		ble $a0, $t3, LoopPartition
	EndPartition:
		addi $t1, $t1, 4
		lw $t4, 0($t1)
		lw $t5, 0($a1)
		sw $t5, 0($t1)
		sw $t4, 0($a1)
		la $v0, 0($t1)
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		jr $ra
	SwapPartition:
		addi $t1, $t1, 4
		lw $t4, 0($t1)
		lw $t5, 0($a0)
		sw $t5, 0($t1)
		sw $t4, 0($a0)
		addi $a0, $a0, 4
		ble $a0, $t3, LoopPartition
		j EndPartition
	

Return:
	lw $ra, 8($sp)
	addi $sp, $sp, 16
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	jr $ra
Sorting:
	la $a0, Array
	lw $t0, 0($a0)
	la $a0, 4($a0)
	la $a1, 0($a0)
	addi $s7, $ra, 0
	subi $t0, $t0, 1
	LoopSorting:
		addi $a1, $a1, 4
		subi $t0, $t0, 1
		bgtz $t0, LoopSorting
	jal QuickSort
	addi $ra, $s7, 0
	jr $ra
