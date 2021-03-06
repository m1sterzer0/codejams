
function solve(Z::Int64, X::Vector{Int64}, Y::Vector{Int64}, M::Vector{Int64})::Int64
    ## The 750 ms wait prevents us from overcounts a --> b --> a cases, so we can
    ## proceed w/o keeping bitmasks
    zombies::Vector{Tuple{Int64,Int64,Int64}} = sort([(M[i],X[i],Y[i]) for i in 1:Z])
    lasttime::Vector{Int64} = fill(-1,Z)
    oldlasttime::Vector{Int64} = fill(-1,Z)
    for loop in 1:Z
        found = false
        oldlasttime[:] = lasttime
        fill!(lasttime,-1)
        for st in 1:(loop==1 ? 1 : Z)
            (m1,x1,y1) = loop == 1 ? (0,0,0) : zombies[st]
            tstart = loop == 1 ? 0 : oldlasttime[st]
            if tstart < 0 ; continue; end
            for en in 1:Z
                if st == en && loop > 1; continue; end
                (m2,x2,y2) = zombies[en]
                tt = tstart + max( (loop==1 ? 0 : 750), 100*abs(x2-x1), 100*abs(y2-y1) )
                if tt > m2+1000; continue; end
                found = true
                tt = max(m2,tt)
                lasttime[en] = lasttime[en] < 0 ? tt : min(tt,lasttime[en])
            end
        end
        if !found; return loop-1; end
    end
    return Z
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
        Z = gi()
        X::Vector{Int64} = fill(0,Z)
        Y::Vector{Int64} = fill(0,Z)
        M::Vector{Int64} = fill(0,Z)
        for i in 1:Z; X[i],Y[i],M[i] = gis(); end
        ans = solve(Z,X,Y,M)
        print("$ans\n")
    end
end

main()

