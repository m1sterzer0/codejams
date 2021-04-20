
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

######################################################################################################
### a) The problem seems much more tractible if we do it in reverse (i.e. we start with a possible
###    end state and work backwards).
### b) The key of the problem is "given a plane that forms a 'roof' and 2 points int that plane that
###    will remain, find a third point such that the resultant plane will retain the 'roof' property
###    (i.e. remaining over all of the other columns).  The key is to minimize the angle between the
###    old and new planes, and this can be done with a linear search.
### c) Finally, finding 3 points to start can be a bit of a challenge, but we can make it easy by
###    adding additional pillars at the same height as our tallest pillar such that the plane starts
###    as a flat roof.  We just need to rememebr to discount these artificial planes in our answer.
######################################################################################################
struct Pt3; x::Int128; y::Int128; z::Int128; end
Pt3() = Pt3(Int128(0),Int128(0),Int128(0))
Base.:+(a::Pt3,b::Pt3)::Pt3 =   Pt3(a.x+b.x,a.y+b.y,a.z+b.z)
Base.:-(a::Pt3,b::Pt3)::Pt3 =   Pt3(a.x-b.x,a.y-b.y,a.z-b.z)
Base.:*(a::Int64,b::Pt3)::Pt3 = Pt3(a*b.x,a*b.y,a*b.z)
Base.:*(b::Pt3,a::Int64)::Pt3 = Pt3(a*b.x,a*b.y,a*b.z) 
cross(a::Pt3,b::Pt3)::Pt3  = Pt3(a.y*b.z-b.y*a.z,a.z*b.x-b.z*a.x,a.x*b.y-b.x*a.y)
dot(a::Pt3,b::Pt3)::Int128 = a.x*b.x + a.y*b.y + a.z*b.z

struct Pt2; x::Int128; y::Int128; end
Pt2() = Pt2(Int128(0),Int128(0))
Base.:+(a::Pt2,b::Pt2)::Pt2 =   Pt2(a.x+b.x,a.y+b.y)
Base.:-(a::Pt2,b::Pt2)::Pt2 =   Pt2(a.x-b.x,a.y-b.y)
Base.:*(a::Int64,b::Pt2)::Pt2 = Pt2(a*b.x,a*b.y)
Base.:*(b::Pt2,a::Int64)::Pt2 = Pt2(a*b.x,a*b.y) 
dot(a::Pt2,b::Pt2)::Int128 = a.x*b.x + a.y*b.y

function findNext(ptarr::Vector{Pt3},used::VB,a::Pt3,b::Pt3)::I
    best::I = -1; nvec::Pt3 = Pt3()
    for i::I in 1:length(ptarr)
        pt::Pt3 = ptarr[i]
        if !used[i] && (best == -1 || dot(nvec,pt-a) > 0) ## This means our roof crosses this pillar, so try a different point
            best = i
            nvec = cross(b-a,pt-a)
            if nvec.z < 0; nvec = -1 * nvec; end  ## Orient the normal to point to the sky
        end
    end
    return best
end

function prework(ptarr::Vector{Pt3},ansstack::VI,used::VB)
    maxh::Int128 = maximum([x.z for x in ptarr])
    maxhIndices = [i for i in 1:length(ptarr) if ptarr[i].z == maxh]
    for i in maxhIndices; used[i] = true; push!(ansstack,i); end
    
    a::Pt3 = Pt3()
    b::Pt3 = Pt3()
    if length(maxhIndices) == 1
        b = ptarr[maxhIndices[1]]
        a = Pt3(b.x+1,b.y,b.z)
    elseif length(maxhIndices) == 2
        b = ptarr[maxhIndices[2]]
        a = ptarr[maxhIndices[1]]
    else
        b = ptarr[maxhIndices[3]]
        a = ptarr[maxhIndices[2]]
    end
    return a,b
end

function solve(N::I,X::Vector{Int128},Y::Vector{Int128},H::Vector{Int128})::String
    ptarr::Vector{Pt3} = [Pt3(X[i],Y[i],H[i]) for i in 1:N]
    ansstack::VI = []
    used::VB = fill(false,N)
    a::Pt3,b::Pt3 = prework(ptarr,ansstack,used)
    ### Do more here
    while length(ansstack) < N
        idx = findNext(ptarr,used,a,b)
        (a,b) = (b,ptarr[idx])
        push!(ansstack,idx)
        used[idx] = true
    end
    return join(reverse(ansstack)," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::Vector{Int128} = fill(Int128(0),N)
        Y::Vector{Int128} = fill(Int128(0),N)
        H::Vector{Int128} = fill(Int128(0),N)
        for i in 1:N; X[i],Y[i],H[i] = [parse(Int128,x) for x in gss()]; end
        ans = solve(N,X,Y,H)
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

