
function solveLarge(X::Int64,Y::Int64,M::String)::Int64
    d::Int64 = 0
    for (i,m) in enumerate(M)
        if m == 'W'; X -= 1; end
        if m == 'E'; X += 1; end
        if m == 'N'; Y += 1; end
        if m == 'S'; Y -= 1; end
        d += 1
        if abs(X) + abs(Y) <= d; return i; end
    end
    return -1
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
        inp = gss()
        X = parse(Int64,inp[1])
        Y = parse(Int64,inp[2])
        M = inp[3]
        ans = solveLarge(X,Y,M)
        if ans == -1; print("IMPOSSIBLE\n"); else; print("$ans\n"); end
    end
end

main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

