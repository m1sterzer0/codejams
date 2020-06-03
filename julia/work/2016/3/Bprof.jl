using Printf
using Random

######################################################################################################
### 1) Since each course has at most one prerequisite, we end up with a forest.
### 2) The allowed error for the problem suggests a random algorithm is intended.
### 3) There are "correct" and incorrect ways to randomly pick the next course
###    -- You should NOT pick uniformly from the currently available options
###    -- You SHOULD weight each of the choices by the total number of nodes in its subtree 
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

        numIter = 10000
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

using Profile
@profile main("B.in2")
Profile.print(format=:flat)
#Profile.print(format=":flat")