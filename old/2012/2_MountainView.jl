
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::Vector{Int64} = gis()
        ans::Vector{Int64} = fill(0,N)

        ## Quick check to make sure no one goes backwards
        bad = false
        for i in 1:N-1; if X[i] <= i; bad = true; break; end; end
        if bad; print("Impossible\n"); continue; end

        ## Main observation is that if i see peak b from peak a, then any peak
        ## between a & b can't see beyond peak b.  This leads to a quick divide and conquer
        function solve(i::Int64,j::Int64)::Bool
            if j-i <= 1; return true; end
            chain::Vector{Int64} = []
            xx = i+1; push!(chain,xx); while (xx < j); xx = X[xx]; push!(chain,xx); end
            if xx != j; return false; end
            num = ans[j]-ans[i]; denom = j-i  ## num should always be >= 0
            for ii in length(chain)-1:-1:1
                xx = chain[ii]; xx2 = chain[ii+1]
                ## Need yy < yy2 - num/denom*(xx2-xx) <=> denom * yy < denom * yy2 - num * (xx2-xx) 
                ## if xx2 is j, we also can't have equality
                ans[xx] = ans[xx2] - num * (xx2-xx) ÷ denom  ## Upper bound
                if denom * ans[xx] > ans[xx2]*denom - num * (xx2-xx); ans[xx] -= 1; end
                if xx2 == j && denom * ans[xx] == ans[xx2]*denom - num * (xx2-xx); ans[xx] -= 1; end
                num = ans[xx2] - ans[xx]
                denom = xx2-xx
            end
            for ii in 1:length(chain)-1; if !solve(chain[ii],chain[ii+1]); return false; end; end
            return true
        end

        ## For the initial conditions, we chain our search from mountain 1 and then just set all of those
        ## to 1_000_000_000 and then recurse
        chain2::Vector{Int64} = []
        xx = 1; push!(chain2,xx); while (xx < N); xx = X[xx]; push!(chain2,xx); end
        for c in chain2; ans[c] = 1_000_000_000; end
        good = true; for i in 1:length(chain2)-1; good &= solve(chain2[i],chain2[i+1]); end
        minx = minimum(ans); for i in 1:N; ans[i] -= (minx-1); end
        ansstr = good ? join(ans," ") : "Impossible" 
        print("$ansstr\n")
    end
end

main()