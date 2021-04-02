
using Random

function solveSmall(N::Int64,L::Vector{Int64})::Int64
    ans = 0
    for i in 1:N-1
        minv = 1_000_000_000_000_000_000; minidx = 0
        for j in i:N
            if L[j] < minv; minv = L[j]; minidx = j; end
        end
        ans += minidx-i+1
        L[i:minidx] .= reverse(L[i:minidx])
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
        N = gi()
        L = gis()
        ans = solveSmall(N,L)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

