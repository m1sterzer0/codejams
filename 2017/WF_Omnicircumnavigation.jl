
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

struct Pt3; x::I; y::I; z::I; end
struct Pt3128; x::Int128; y::Int128; z::Int128; end
Pt3128(a::Pt3) = Pt3128(Int128(a.x),Int128(a.y),Int128(a.z))

mydot(a::Pt3,b::Pt3)::I              = a.x*b.x+a.y*b.y+a.z*b.z
mydot(a::Pt3128,b::Pt3128)::Int128   = a.x*b.x+a.y*b.y+a.z*b.z
mycross(a::Pt3,b::Pt3)::Pt3          =    Pt3(a.y*b.z-b.y*a.z, a.z*b.x-b.z*a.x,a.x*b.y-b.x*a.y)
mycross(a::Pt3128,b::Pt3128)::Pt3128 = Pt3128(a.y*b.z-b.y*a.z, a.z*b.x-b.z*a.x,a.x*b.y-b.x*a.y)

function reducePoints(points::Vector{Pt3})::Vector{Pt3}
    uniquePoints::Set{Pt3} = Set{Pt3}()
    for p in points
        factor = gcd(gcd(p.x,p.y),p.z)
        a::Pt3 = Pt3(p.x ÷ factor, p.y ÷ factor, p.z ÷ factor)
        if a in uniquePoints; continue; end
        push!(uniquePoints,a)
    end
    return collect(uniquePoints)
end

function checkCoplanar(points2::Vector{Pt3},coplanar::VI,avec::Pt3)::Bool
    ## We could do this in n log n, but there isn't a huge incentive,
    ## since we will be taking out more work than that out of the outer
    ## loop with the skipsets
    ## Note there is an overflow problem here, so we need to bump up to Int128s
    for i in coplanar
        bvec::Pt3128 = mycross(Pt3128(avec),Pt3128(points2[i]))
        posfound::Bool = false
        negfound::Bool = false
        for j in coplanar
            if i==j; continue; end
            x::Int128 = mydot(bvec,Pt3128(points2[j]))
            if x == 0; return true;  ## antipodal
            elseif x > 0; posfound = true
            else   x < 0; negfound = true
            end
            if posfound && negfound; break; end
        end
        if !posfound || !negfound; return false; end
    end
    return true
end


function solve(N::I,X::VI,Y::VI,Z::VI)::String
    points::Vector{Pt3} = [Pt3(X[i],Y[i],Z[i]) for i in 1:N]
    points2::Vector{Pt3} = reducePoints(points)
    N2::I = length(points2)
    omni::Bool = true
    coplanar::VI = []
    for i::I in 1:N2-1
        for j::I in i+1:N2
            resize!(coplanar,2)
            coplanar[1] = i
            coplanar[2] = j
            avec::Pt3 = mycross(points2[i],points2[j])
            if avec.x == avec.y == avec.z == 0; return "YES"; end ## Antipodes, since we have already removed the same point numbers
            posfound::Bool = false
            negfound::Bool = false
            for k::I in 1:N2
                if k == i || k == j; continue; end
                x::I = mydot(points2[k],avec)
                if     x > 0; posfound=true;
                elseif x < 0; negfound=true;
                else   push!(coplanar,k)
                end
                if posfound && negfound; break; end
            end
            if posfound && negfound; continue; end
            if (length(coplanar) > 2 && checkCoplanar(points2,coplanar,avec)); continue; end
            return "NO"
        end
    end
    return "YES"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        Z::VI = fill(0,N)
        for i in 1:N; X[i],Y[i],Z[i] = gis(); end
        ans = solve(N,X,Y,Z)
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

