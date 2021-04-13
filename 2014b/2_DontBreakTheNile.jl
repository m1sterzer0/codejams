
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

function denseDijkstra(s::I,d::VI,p::VI,adjm::Array{I,2})
    n = length(d)
    inf::I = 1000000006
    fill!(d,inf)
    fill!(p,-1)
    u::VB = fill(false,n)
    d[s] = 0
    for i in 1:n
        v::I = -1
        for j in 1:n
            if (!u[j] && (v==-1 || d[j] < d[v])); v = j; end
        end
        if d[v] == inf; break; end
        u[v] = true
        for j in 1:n
            if j == v; continue; end
            if d[j] > d[v] + adjm[v,j]
                d[j] = d[v] + adjm[v,j]
                p[j] = v
            end
        end
    end
end

function solve(W::I,H::I,B::I,buildings::Array{I,2})::I
    adjm::Array{I,2} = fill(0,B+2,B+2)
    for i in 1:B
        adjm[i,B+1] = adjm[B+1,i] = buildings[i,1]
        adjm[i,B+2] = adjm[B+2,i] = W-1-buildings[i,3]
        for j in i+1:B
            dx = buildings[i,3] < buildings[j,1] ? buildings[j,1]-buildings[i,3]-1 : buildings[j,3] < buildings[i,1] ? buildings[i,1]-buildings[j,3]-1 : 0
            dy = buildings[i,4] < buildings[j,2] ? buildings[j,2]-buildings[i,4]-1 : buildings[j,4] < buildings[i,2] ? buildings[i,2]-buildings[j,4]-1 : 0
            dd = max(dx,dy)
            adjm[i,j]=adjm[j,i] = dd
        end
    end
    adjm[B+1,B+2] = adjm[B+2,B+1] = W
    d::VI = fill(0,B+2)
    p::VI = fill(-1,B+2)
    denseDijkstra(B+1,d,p,adjm)
    return d[B+2]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        W,H,B = gis()
        buildings::Array{I,2} = fill(0,B,4)
        for i in 1:B
            buildings[i,:] = gis()
        end
        ans = solve(W,H,B,buildings)
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

