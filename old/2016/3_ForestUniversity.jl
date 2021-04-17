using Printf
using Random

######################################################################################################
### 1) Since each course has at most one prerequisite, we end up with a forest.
###
### 2) The allowed error for the problem suggests a random algorithm is intended.
###
### 3) There are "correct" and incorrect ways to randomly pick the next course
###    -- You should NOT pick uniformly from the currently available options
###    -- You SHOULD weight each of the available choices by the total number of nodes in its subtree 
###
### 4) How many runs to we need to run?  We can use the binomial distribution in julia to tell.
###
###    using Distributions
###    allowedErr = 0.03
###    predictions = 500
###    for n in [1000,2000,3000,4000,5000,6000,7000,8000,9000,10000]
###        for u in [0.50]
###            b = Binomial(n,u)
###            err = 1 - (cdf(b,(u+allowedErr)*n) - cdf(b,(u-allowedErr)*n))
###            totalerrchance = 1 - (1-err)^predictions
###            @printf("%7d %.3f %10.3e %10.3e\n", n, u, err, totalerrchance)
###        end
###    end
###    
###    1000 0.500  5.785e-02  1.000e+00
###    2000 0.500  7.290e-03  9.742e-01
###    3000 0.500  1.014e-03  3.978e-01
###    4000 0.500  1.475e-04  7.108e-02
###    5000 0.500  2.201e-05  1.095e-02
###    6000 0.500  3.343e-06  1.670e-03
###    7000 0.500  5.139e-07  2.569e-04
###    8000 0.500  7.971e-08  3.985e-05
###    9000 0.500  1.245e-08  6.225e-06
###   10000 0.500  1.956e-09  9.778e-07
###
### From this, it looks like 5000 iterations will give us < ~1/100 chance of failure. Since we can
### rerun if we fail with a small time penalty, this seems fine (just change the seed if we fail)   
######################################################################################################


function main(infn="")
    Random.seed!(8675309)
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        prereq = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        firstLetters = rstrip(readline(infile))
        M            = parse(Int64,readline(infile))
        coolWords    = split(rstrip(readline(infile)))


        ## Build the graph for the forest
        children = [Int[] for x in 1:N]
        for i in 1:N
            if prereq[i] > 0; push!(children[prereq[i]],i); end
        end

        ## Calculate the size of each element in the forest        
        forestRoots = Set{Int64}([x for x in 1:N if prereq[x] == 0])
        nodesizes = fill(1,N)
        function traverse(n)
            for c in children[n]
                traverse(c)
                nodesizes[n] += nodesizes[c]
            end
        end
        for n in forestRoots; traverse(n); end

        numIter = 5000
        coolWordCounts = fill(0,M)
        for i in 1:numIter
            openSet = copy(forestRoots)
            fl = Char[]

            for n in 1:N
                ridx = rand(1:N-n+1); lidx = 0; xx = 0
                for n in openSet
                    lidx += nodesizes[n]
                    if ridx <= lidx; xx=n; break; end
                end
                push!(fl,firstLetters[xx])
                pop!(openSet,xx)
                for c in children[xx]
                    push!(openSet,c)
                end
            end
            gl = join(fl,"")
            for (i,c) in enumerate(coolWords)
                if occursin(coolWords[i],gl); coolWordCounts[i] += 1; end
            end
        end
        ans = join([@sprintf("%.6f",coolWordCounts[i]/numIter) for i in 1:M]," ")
        print("$ans\n")
    end
end

main()