function solveLarge(R::Int64,S::Int64)
    ans::Vector{Tuple{Int64,Int64}} = []
    cards2move = (S-1)*R ## Merging cards 2 at a time into final suit
    finalsuit::Vector{Int64} = [1 for x in 1:R]
    nextrank = 1
    while cards2move > 0
        if cards2move <= 2  ## last move
            a = S - finalsuit[R] + (cards2move-1)
            b = R*S - a - finalsuit[R]
            push!(ans,(a,b))
            return ans
        end
        np1 = nextrank == R ? 1 : nextrank + 1
        b = R*S-2-sum(finalsuit[np1:end])
        push!(ans,(2,b))
        if nextrank != R; finalsuit[nextrank] += 1; end
        finalsuit[np1] += 1
        cards2move -= 2
        nextrank += 2
        if nextrank > R; nextrank -= R; end
    end
    return ans
end

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
        R,S = gis()
        moves = solveLarge(R,S)
        print("$(length(moves))\n")
        for (a,b) in moves; print("$a $b\n"); end
    end
end

function test()
    for R in 2:5
        for S in 2:7
            deck = []
            for j in 1:S; for i in 1:R; push!(deck,i); end; end
            ntot = R*S
            moves = solveLarge(R,S)
            for (a,b) in moves
                deck = vcat(deck[a+1:a+b],deck[1:a],deck[a+b+1:end])
            end
            print("$R $S $deck\n")
        end
    end
end

#test()
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

