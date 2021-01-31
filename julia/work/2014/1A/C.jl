######################################################################################################
### BEGIN MAIN PROGRAM
### KEY INSIGHT:
###  The BAD permuation has a propensity to push high numbered cards to earlier spots in the permutation
###  Experimenting, we see that the mean number of cards greater than their position value is around
###  528 for the BAD algorithm and is around 499.5 for the good algorithm, this should be good enough to
###  solve the problem.
######################################################################################################

function metric(p::Vector{Int64})
    ans = 0
    for i in 1:1000
        if p[i] > i; ans += 1; end
    end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        perm = [parse(Int64,x)+1 for x in split(readline(infile))]
        m = metric(perm)
        print(m >= 514 ? "BAD\n" : "GOOD\n")
    end
end

main()
