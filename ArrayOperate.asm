.data
	Array: .space 4000
	HeadMenu: .asciiz "\n############### MENU ###############\n"
	str0: .asciiz "Nhap so phan tu (n > 0): "
	stri: .asciiz "Nhap phan tu thu "
	strii: .asciiz "  "
	str1: .asciiz "1 - Xuat ra cac phan tu.\n"
	str2: .asciiz "2 - Tinh tong cac phan tu.\n"
	str22: .asciiz "Tong = "
	str3: .asciiz "3 - Liet ke cac phan tu la so nguyen to.\n"
	str33: .asciiz  "Cac phan tu la so nguyen to: "
	str4: .asciiz  "4 - Tim max.\n"
	str44: .asciiz  "Max = "
	str5: .asciiz "5 - Tim phan tu co gia tri X trong mang.\n"
	str55: .asciiz "Nhap gia tri X: "
	str551: .asciiz "Vi tri cua phan tu X trong mang la: "
	str550: .asciiz "Gia tri X khong ton tai.\n"
	str6: .asciiz "6 - Thoat chuong trinh.\n############### MENU ###############\n"
	str: .asciiz "Xin hay chon chuc nang (1-6): "
.text 
.globl main
main:	
	# Input N 
	jal GetN
	la $t0, Array
	sw $v0, 0($t0)
	# Input Array
	jal GetArray
	j Menu
return:
	jr $ra
EndProgram:
	addi $v0, $0, 10
	syscall
GetN:
	#Print str0 "
	addi $v0, $0, 4 
	la $a0, str0
	syscall 
	#Read N
	addi $v0, $0, 5
	syscall 
	#Check if N < 1
	slti $t0, $v0, 1
	#If N<1 goto Loop
	beq $t0, 1, GetN
	jr $ra

GetArray:
	la $s3, Array
	lw $s0, 0($s3) # $s0 = n
	addi $s1, $0, 0 # counter = 0
	addi $s3, $s3, 4 # first 4 byte store N
	Loop:	
		#---------------------  print strings
		addi $v0, $0, 4
		la $a0, stri
		syscall	
		#
		addi $v0, $0, 1
		add $a0, $s1, $0
		syscall 
		#
		addi $v0, $0, 4
		la $a0, strii
		syscall 
		#-------------------- read a[i]
		addi $v0, $0, 5
		syscall 
		#--------------------- store a[i]
		sw $v0, 0($s3)
		addi $s3, $s3, 4
		addi $s1, $s1, 1
		#--------------------
		blt $s1, $s0, Loop
	jr $ra

PrintArray:
	la $s3, Array 	# *a
	lw $s0, 0($s3)	# n
	addi $s1, $0, 0 # counter = 0
	addi $s3, $s3, 4
	Loop2:	
		#-----------
		addi $v0, $0, 1
		lw $a0, 0($s3)
		syscall
		#-----------
		addi $v0, $0, 4
		la $a0, strii
		syscall
		#-----------
		addi $s3, $s3, 4
		addi $s1, $s1, 1
		blt $s1, $s0, Loop2
	jr $ra
CalSumOfArray: # return result = v0
	la $s3, Array	# *a
	lw $s0, 0($s3)	# n
	addi $s1, $0, 0 # counter = 0
	addi $s3, $s3, 4
	addi $v0, $0, 0 # sum
	Loop3: 
		lw $t1, 0($s3) # get a[i]
		add $v0, $v0, $t1 # sum = sum + a[i]
		addi $s3, $s3, 4
		addi $s1, $s1, 1 # counter = counter + 1
		blt $s1, $s0, Loop3 # if counter < n, goto Loop3
	jr $ra	
FindMaxOfArray: # return result = v0
	la $s3, Array	# *a
	lw $s0, 0($s3)	# n
	addi $s1, $0, 0 # counter = 0
	addi $s3, $s3, 4
	lw $t1, 0($s3) # get a[0]
	addi $v0, $t1, 0 # max = a[0]
	move $s2, $ra
	Loop4:
		lw $t1, 0($s3) # get a[i]
		jal ChangeMax
		addi $s3, $s3, 4
		addi $s1, $s1, 1 # counter = counter + 1
		blt $s1, $s0, Loop4 # if counter < n, goto Loop4
	move $ra, $s2
	jr $ra
ChangeMax:
	blt $t1, $v0, return
	addi $v0, $t1, 0
	jr $ra
PrintPrimeNumbersOfArray:
	la $s3, Array	# s3 = *a
	lw $s0, 0($s3)	# s0 = n
	addi $s1, $0, 0 # s1 = counter = 0
	addi $s3, $s3, 4
	move $s2, $ra
	Loop5:
		lw $a0, 0($s3) # get a[i]
		#Check is a[i] a Prime number
		addi $v0, $0, 1 # is_prime = true
		jal CheckPrime
		jal PrintPrime
		addi $s3, $s3, 4
		addi $s1, $s1, 1 # counter = counter + 1
		blt $s1, $s0, Loop5
	move $ra, $s2
	jr $ra
PrintPrime:
	beq $v0, 0, isqrt_return
	addi $v0, $0, 1
	syscall	
	addi $v0, $0, 4
	la $a0, strii
	syscall
	jr $ra 
CheckPrime:
	slti $t1, $a0, 2 # a[i] < 2
	addi $v0, $0, 0	# is_prime = false
	beq $t1, 1, return	
	move $t4, $ra
	jal isqrt
	move $ra, $t4
	addi $t1, $v0, 0 # t1 = v0 = sqrt(a0) = sqrt(a[i])
	addi $t2, $0, 2	# t2 = counter = 2
	addi $v0, $0, 1	# is_prime = true
	CheckLoop:
		slt $t3, $t1, $t2 # sqrt(a[i]) < counter
		beq $t3, 1, return 
		div $a0, $t2 
		mfhi $t3 # t3 = a[i] mod counter
		addi $v0, $0, 0	# is_prime = false
		beq $t3, 0, return # a[i] mod counter = 0
		addi $v0, $0, 1	# is_prime = true
		addi $t2, $t2, 1 # counter = counter + 1
		j CheckLoop
isqrt:
  # v0 - return / root
  # t0 - bit
  # t1 - num
  # t2,t3 - temps
  move  $v0, $zero        # initalize return
  move  $t1, $a0          # move a0 to t1

  addi  $t0, $zero, 1
  sll   $t0, $t0, 30      # shift to second-to-top bit

isqrt_bit:
  slt   $t2, $t1, $t0     # num < bit
  beq   $t2, $zero, isqrt_loop

  srl   $t0, $t0, 2       # bit >> 2
  j     isqrt_bit

isqrt_loop:
  beq   $t0, $zero, isqrt_return

  add   $t3, $v0, $t0     # t3 = return + bit
  slt   $t2, $t1, $t3
  beq   $t2, $zero, isqrt_else

  srl   $v0, $v0, 1       # return >> 1
  j     isqrt_loop_end

isqrt_else:
  sub   $t1, $t1, $t3     # num -= return + bit
  srl   $v0, $v0, 1       # return >> 1
  add   $v0, $v0, $t0     # return + bit

isqrt_loop_end:
  srl   $t0, $t0, 2       # bit >> 2
  j     isqrt_loop

isqrt_return:
  jr  $ra
FindElementOfArray: # return result = v0, a0 = X
	la $s0, Array 	# s0 = *a
	lw $s1, 0($s0)	# s1 = n = a[0]
	addi $s2, $0, 0 # s2 = counter = 0
	addi $s0, $s0, 4
	Loop6:
		lw $t1, 0($s0) # get a[i]
		addi $v0, $s2, 0 # v0 = i
		beq $a0,$t1, return # X = a[i], return i
		addi $s0, $s0, 4
		addi $s2, $s2, 1
		blt $s2, $s1, Loop6
	addi $v0, $0, -1
	jr $ra
PrintOptions:
	addi $v0, $0, 4
	la $a0, str1
	syscall
	addi $v0, $0, 4
	la $a0, str2
	syscall
	addi $v0, $0, 4
	la $a0, str3
	syscall
	addi $v0, $0, 4
	la $a0, str4
	syscall
	addi $v0, $0, 4
	la $a0, str5
	syscall
	addi $v0, $0, 4
	la $a0, str6
	syscall
	addi $v0, $0, 4
	la $a0, str
	syscall
	jr $ra
Menu:
	addi $v0, $0, 4
	la $a0, HeadMenu
	syscall
	jal PrintOptions
	#------------
	addi $v0, $0, 5
	syscall
	#------------
	beq $v0, 1, Option1
	beq $v0, 2, Option2
	beq $v0, 3, Option3
	beq $v0, 4, Option4
	beq $v0, 5, Option5
	beq $v0, 6, Option6
	j Menu
Option1:	
	jal PrintArray
	j Menu
Option2:
	jal CalSumOfArray
	addi $t0, $v0, 0
	addi $v0, $0, 4
	la $a0, str22
	syscall
	addi $v0, $0, 1
	addi $a0, $t0, 0
	syscall
	j Menu
Option3:
	addi $v0, $0, 4
	la $a0, str33
	syscall
	jal PrintPrimeNumbersOfArray 
	j Menu
Option4:
	jal FindMaxOfArray
	addi $t0, $v0, 0
	addi $v0, $0, 4
	la $a0, str44
	syscall
	addi $v0, $0, 1
	addi $a0, $t0, 0
	syscall
	j Menu
Option5:
	addi $v0, $0, 4
	la $a0, str55
	syscall
	addi $v0, $0, 5
	syscall
	addi $a0, $v0, 0
	jal FindElementOfArray
	addi $t0, $v0, 0
	beq $t0, -1, NotExist
	addi $v0, $0, 4
	la $a0, str551
	syscall
	addi $v0, $0, 1
	addi $a0, $t0, 0
	syscall
	j Menu
NotExist:
	addi $v0, $0, 4
	la $a0, str550
	syscall
	j Menu
Option6:
	j EndProgram
	
