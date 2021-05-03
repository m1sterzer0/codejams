
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

function issmallenough(num::I,denom::I,N::I,D::I,A::VI)::Bool
    sidx::I = 1
    if N >= D
        sidx = N-D+1
        if num <= denom * A[sidx]; return true; end
    end
    tot::I = 0
    for i::I in N:-1:sidx
        tot += (denom * A[i]) ÷ num
        if tot >= D; return true; end
    end
    return false
end

function countcuts(v::VI,D::I)::I
    ## Note v should alread be sorted
    cuts::I,slices::I = 0,0
    for vv::I in v
        if slices+vv > D; break; end
        slices += vv; cuts += vv-1
    end
    return cuts + (D-slices)
end

function solve(N::I,D::I,preA::VI)::I
    A::VI = sort(preA)
    d::Dict{PI,VI} = Dict{PI,I}()
    for a::I in A
        for x::I in 1:D
            g::I = gcd(a,x); num::I = a÷g; denom::I = x÷g
            if haskey(d,(num,denom)); push!(d[(num,denom)],x)
            else; d[(num,denom)] = [x]
            end
        end
    end
    myisless(a::PI,b::PI)::Bool = a[1]*b[2] < a[2]*b[1]
    dk::VPI = [x for x in keys(d)]
    sort!(dk,lt=myisless)
    l,u = 1,length(dk)
    if issmallenough(dk[end][1],dk[end][2],N,D,A); l = u; end
    while (u-l > 1)
        m = (u+l) ÷ 2
        if issmallenough(dk[m][1],dk[m][2],N,D,A); l = m; else; u = m; end
    end

    best::I = D-1
    for i in 1:l
        (num,denom) = dk[i]
        c = countcuts(d[(num,denom)],D)
        best = min(best,c)
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,D = gis()
        A::VI = gis()
        ans = solve(N,D,A)
        println(ans)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

