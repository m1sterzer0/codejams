using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### Observations
###    * (x)^n % x+1 = ((x+1)-1)^n % (x+1) = (-1)^n % (x+1).  This is 1 -1 1 -1 1 -1 ,... for the various place values.
###    * This suggests that if we balance our 1's between the even indices and odd indices,
###      each number will be divisible by its (base + 1)
###
### Thus, we aim to construct our numbers with the same number of 1s in the even places vs. the odd places.
###    * For our solutions, We will used EXACTLY 6 1's.  This ensures we have enough to meet the required 'J' numbers
###    * 3 ones need to come from the even numbered digits
###    * 3 ones need to come from the odd numbered digits
###
### SMALL CASE:
###    * We are forced to have a 1 in the first and 16th place.
###    * This means we need to pick 
###      -- two places amongst [2,4,6,8,10,12,14]
###      -- two places amongst [3,5,7,9,11,13,15]
###    * Note comb(7,2) = 21, so this gives us 21*21 = 441 -- plenty
###
### LARGE CASE:
###    * We are forced to have a 1 in the first and 32nd place
###    * This means we need to pick 
###      -- two places amongst [2,4,6,8,10,12,14,...,30]
###      -- two places amongst [3,5,7,9,11,13,15,...,31]
###    * Note comb(15,2) = 21, so this gives us 105*105 = 11025, which is certainly plenty
###
######################################################################################################
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        N,J = [parse(Int64,x) for x in split(readline(infile))]
        evenpairs = [(x,y) for x in 2:2:N-1 for y in x+2:2:N-1]
        oddpairs  = [(x,y) for x in 3:2:N-1 for y in x+2:2:N-1]    
        for (i,(ep,op)) in enumerate(Iterators.product(evenpairs,oddpairs))
            ans = prod([x in (1,N) || x in ep || x in op ? '1' : '0' for x in N:-1:1])
            print("$ans 3 4 5 6 7 8 9 10 11\n")
            if i >= J; break; end
        end
    end
end

main()