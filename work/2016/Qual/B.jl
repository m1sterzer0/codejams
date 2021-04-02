using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### We consider "groups" of contiguously faced pancakes, and we can count the number of contiguous groups
### in the stack
##
### We make two observations:
###    * The "best" we can do is to reduce the number of contiguously grouped pancakes by one on each "flip"
###    * If the bottom of the stack is faced incorrectly, we have to flip the whole stack, and that doesn't
###      reduce the number of continuous groups
###
### Thus, the "best" we can do is for #(contiguous groups) - 1, and we have to add 1 if the bottom pancake 
### is facing the wrong way.
###
### We note that this is realizable with the simple strategy of just flipping the top contiguous group.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        flips = sum([1 for x in 1:length(S)-1 if S[x] != S[x+1]])
        if S[end] == '-'; flips += 1; end
        print("$flips\n")
    end
end

main()