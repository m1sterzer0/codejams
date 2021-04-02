using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### Observations
###    * Lets consider the 'L' blocks as "False", and the "G" blocks as "True"
###    * Looking at the 2, 3, cases gives us some intuition
###      2 case:
###          a,b -->
###          a|a, a|b, b|a, b|b --> 
###          a|a|a, a|a|b, ... --> 
###          a|a|a|a, a|a|a|b, ... -->
###
###      3 case:
###          a,b,c -->
###          a|a, a|b, a|c, b|a, b|b, b|c, c|a, c|b, c|c -->
###          a|a|a, a|a|b, a|a|c, a|b|a, a|b|b, a|b|c, a|c|a, a|c|b, a|c|c, ... -->
###          a|a|a|a, a|a|a|b, a|a|a|c, a|a|b|a, a|a|b|b, a|a|b|c, ... -->
###
###    * Key points
###      -- Each layer we add gives us blocks with potentially more information.  For example, Layer 2 gives us information on all ordered pairs of blocks,
###         layer 3 gives us information about all ordered triples of blocks.
###      -- We can each block index (starting with zero) of layer X as a base K number of length X.  The digits in this number tell us which blocks we are
###         getting information about in that index.
###
###  Thus, to solve the problem, we need to do two things
###      -- Check to see if S * C >= K.  If not, this is impossible.
###      -- It if is not impossible, we just emit ceil(K // C) numbers base k, ensuring that each digit is represented in the collection
###      -- we have to deal with "1-indexing", so we cannot forget to add 1
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        K,C,S = [parse(Int64,x) for x in split(readline(infile))]
        if S * C < K
            print("IMPOSSIBLE\n")
        else 
            pvs = [K^i for i in 0:C-1]
            totalnumbers = (K + (C-1)) ÷ C
            digits = vcat(collect(0:K-1),zeros(Int64,totalnumbers*C - K))
            digits = reshape(digits,C,totalnumbers)
            indices = [c' * pvs + 1 for c in eachcol(digits)]
            outstr = join(indices," ")
            print("$outstr\n")
        end
    end
end

main()