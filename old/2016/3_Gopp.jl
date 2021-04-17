using Printf

######################################################################################################
### Full disclosure: I had to look at the answers for the long.
###
### For the first program, we want to make an "anti-B" sequence with                           
### questionmarks after each character
###
### The only way to get B then is to replace ALL the question-marks with a
### subsequence of the second program.  We now need to create a sequence which
### doesn't contain B as a "generalized-subsequence" (a subsequence where adjacency
### is not required).  However, its content must allow us to create all the strings in 
### G
###
### For the short case, this is easy.  A string of L-1 1's will suffice.  Note that it is
### impossible to create a string of L 1's, but every other string is possible, since
### prog 1 has L zeros.
###
### For the long case, we want a prog 2 that can emit any L-1 character string, but it
### cannot emit the entire B string. (Looking at the answers), the solution here is actually
### pretty simple.  We take the first L-1 characters of B and emit a "01" for every '1' and
### "10" for every '0'.
### -- Note since ever pair contains a 0 and a 1, every L-1 character sequence can be emitted.
### -- If we try to emit B, we chew up 2 characters for each symbol, so we run out before
###    we emit the last character.
###
### Note one special case.  When L == 1, our algorithm doesn't work, so we have to do something different.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        G = split(rstrip(readline(infile)))
        B = rstrip(readline(infile))

        if B in G; print("IMPOSSIBLE\n"); continue; end


        prog1 = join([x == '0' ? "1?" : "0?" for x in B],"")
        prog2a = B[1] == '0' ? "1" : "0"
        prog2b = join([x == '0' ? "10" : "01" for x in B[1:end-1]],"")
        if L == 1
            print("$prog1 $prog2a\n")
        else
            print("$prog1 $prog2b\n")
        end
    end
end
        
main()