
function solveSmall(N::Int64,M::Array{Int64,2})::Tuple{Int64,Int64,Int64}
    k = sum(M[i,i] for i in 1:N)
    r,c = 0,0
    for i in 1:N
        if length(Set(M[i,:])) < N; r += 1; end
        if length(Set(M[:,i])) < N; c += 1; end
    end
    return (k,r,c)
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
        M::Array{Int64,2} = fill(0,N,N)
        for i in 1:N; M[i,:] = gis(); end
        (k,r,c) = solveSmall(N,M)
        print("$k $r $c\n")
    end
end

main("A.in")
