
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

## Adapted/translated from cp-algorithms -- this version is O(n^2) and assumes distances in an adj matrix
function denseDijkstra(s::I,d::VI,p::VI,adjm::Array{I,2})
    n::I = length(d)
    inf::I = 10^18
    fill!(d,inf)
    fill!(p,-1)
    u::VB = fill(false,n)
    d[s] = 0
    for i::I in 1:n
        v::I = -1
        for j::I in 1:n
            if (!u[j] && (v==-1 || d[j] < d[v])); v = j; end
        end
        if d[v] == inf; break; end
        u[v] = true
        for j::I in 1:n
            if j == v; continue; end
            if adjm[v,j] >= 0 && d[j] > d[v] + adjm[v,j]
                d[j] = d[v] + adjm[v,j]
                p[j] = v
            end
        end
    end
end

function doFloydWarshallAdjMatrix(Dnew::Array{F,2})::Array{F,2}
    (R::I,C::I) = size(Dnew)
    ans::Array{F,2} = copy(Dnew)
    for i::I in 1:R; ans[i,i] = 0; end
    for k::I in 1:R
        for i::I in 1:R
            for j::I in 1:R
                ans[i,j] = min(ans[i,j],ans[i,k]+ans[k,j])
            end
        end
    end
    return ans
end

function solve(N::I,Q::I,E::VI,S::VI,D::Array{I,2},U::VI,V::VI)::String
    Dnew::Array{F,2} = fill(Inf,N,N)
    arcs::VI = fill(0,N)
    parents::VI = fill(0,N)
    finf = 10.0^50
    for i in 1:N
        denseDijkstra(i,arcs,parents,D)
        Dnew[i,:] = [i == j || arcs[j] > E[i] ? finf : arcs[j]/S[i] for j in 1:N]
    end
    anskey = doFloydWarshallAdjMatrix(Dnew)
    answers = [anskey[u,v] for (u,v) in zip(U,V)]
    return join([string(x) for x in answers]," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,Q = gis()
        E::VI = fill(0,N)
        S::VI = fill(0,N)
        for i in 1:N; E[i],S[i] = gis(); end
        D::Array{I,2} = fill(0,N,N)
        for i in 1:N; D[i,:] = gis(); end
        U::VI = fill(0,Q)
        V::VI = fill(0,Q)
        for i in 1:Q; U[i],V[i] = gis(); end
        ans = solve(N,Q,E,S,D,U,V)
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


