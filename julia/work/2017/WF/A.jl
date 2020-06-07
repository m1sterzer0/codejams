using Printf

######################################################################################################
### For this, we can solve by doing O(N) maximum bipartite matches incrementally that are each O(N)
######################################################################################################

function checkMatch(adjL::Vector{Vector{Int}}, matchR::Vector{Int}, seen::Vector{Int8}, minval::Int, maxval::Int, n::Int)
    if n == maxval; fill!(seen,0); end
    for v in adjL[n]
        if seen[v] > 0; continue; end
        seen[v] = 1
        if matchR[v] == -1; matchR[v] = n; return true; end
        if checkMatch(adjL,matchR,seen,minval,maxval,matchR[v]); matchR[v] = n; return true; end
    end
    return false
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        D = fill(-1,N,6)
        maxdig = 1
        for i in 1:N
            D[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            maxdig = max(maxdig,maximum(D[i,:]))
        end

        ## Collect the edges by value
        adjL = [Vector{Int64}() for i in 1:maxdig]
        for i in 1:N
            for j in 1:6
                push!(adjL[D[i,j]],i)
            end
        end

        ## Figure out the best possible straight we can make at each starting digits
        last = 0
        bestPossible = fill(0,maxdig)
        for i in maxdig:-1:1
            last = length(adjL[i]) == 0 ? 0 : last+1
            bestPossible[i] = last
        end
        seen = fill(zero(Int8),N)
        matchR = fill(-1,N)
        start,best = 0,1
        while(true)
            start += 1
            while start <= maxdig && bestPossible[start] <= best; start += 1; end
            if start > maxdig; break; end
            fill!(matchR,-1)
            myend = start
            #println("DEBUG: Starting search from $start")
            while bestPossible[start] > best
                if checkMatch(adjL,matchR,seen,start,myend,myend)
                    #println("DEBUG: Search $start..$myend successful, bumping up $myend to $(myend+1)")
                    myend += 1
                    best = max(best,myend-start)
                    if myend > maxdig; start = myend; break; end
                    if length(adjL[myend]) == 0; start = myend; break; end
                else
                    #println("DEBUG: Search $start..$myend failed, moving range to $(start+1)..$myend")
                    for v in adjL[start]
                        if matchR[v] == start; matchR[v] = -1; end
                    end
                    start += 1
                end
            end
        end
        print("$best\n")
    end
end

main()
