
# Fibn.s - compute the nth Fibonacci number
#	
# C-code that this assembly code came from
#
# int fibn(void)
# {
#  int n = 8;		/* Compute nth Fibonacci number */
#  int f1 = 1, f2 = -1	/* last two Fibonacci numbers   */
#  
#  while (n != 0) {	/* count down to n = 0          */
#    f1 = f1 + f2;
#    f2 = f1 - f2;
#     n = n - 1;
#   }
#   return f1;
#  }
#
#
# Register usage: $3=n, $4=f1, $5=f2
# return value written to address 255

	
fibn:	addi $3, $0, 14	        # initialize n = 14
	addi $4, $0, 1		# initialize f1 = 1
	addi $5, $0, -1		# initialize f2 = -1
	
loop_setup:	
	beq $3, $0, loop_io	# Done with loop if n = 0, when done go to continuous I/O loop
	add $4, $4, $5		# f1 = f1 + f2
	sub $5, $4, $5		# f2 = f1 - f2
	sb $4, 128($3)		# store result at 128 + n
	addi $3, $3, -1		# n = n - 1
	j loop_setup		# repeat until done

loop_io:
#   1. read memory at I/O space (switches)
	lb $6, 192($0) # using reg $6 to store a value from memory where the address has the top two bits as 11

#   2. read value in memory at addr from step 2
	lb $6, 128($6) # -> reg $6 should contain fib number based on switch values...

#   3. write value from step 3 to I/O space
	sb $6, 192($0)

	j loop_io  # continue forever

# mars might add offset for jumps and for storing (anything requiring addressing) may need to adjust addresses
