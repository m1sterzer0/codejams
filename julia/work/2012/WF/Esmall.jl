
function solveSmall(N::Int64,L::Vector{Int64},R::Vector{Int64})
    state::Int64 = 0
    pos::Int64 = 1
    visited::BitSet = BitSet()
    cnt::Int64 = 0
    while(true)
        if pos == N; return cnt; end
        encstate = N * state + (pos-1)
        if encstate in visited; return 0; end
        push!(visited,encstate)
        clearingstate = (state >> (pos-1)) & 1
        state ⊻= (1 << (pos-1))
        pos = clearingstate == 0 ? L[pos] : R[pos]
        cnt += 1
    end
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
        N = gi()
        L::Vector{Int64} = fill(0,N-1)
        R::Vector{Int64} = fill(0,N-1)
        for i in 1:N-1; L[i],R[i] = gis(); end
        ans = solveSmall(N,L,R)
        if ans == 0; print("Infinity\n"); else; print("$ans\n"); end
    end
end

main()
