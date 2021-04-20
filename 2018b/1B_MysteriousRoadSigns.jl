
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
### S here is small enough to suppport an S^2 approach.
### -- We try starting at each signpost and try it two ways
### -- We keep walking until we find our first incompatible signpost
### -- We then set the other constraint
### -- Then we keep walking as far as we can
### Ironically, in Julia, this S^2 approach passes for both the Small and Large, but we still
### consider this is only a "Small" solution.
######################################################################################################

function mySearch(st::I,S::I,M::VI,N::VI)::I
    m::I = M[st]
    en::I = st
    while en < S && M[en+1] == m; en += 1; end
    if en < S
        en += 1
        n::I = N[en]
        while en < S && (M[en+1] == m || N[en+1] == n); en += 1; end
    end
    return en-st+1
end

function solveSmall(S::I,D::VI,A::VI,B::VI)::PI
    M::VI = D .+ A
    N::VI = D .- B
    best::I = 0; numbest::I = 1
    for st::I in 1:S
        if (S-st+1 < best); break; end
        mbest::I = mySearch(st,S,M,N)
        nbest::I = mySearch(st,S,N,M)
        mnbest::I = max(mbest,nbest)
        if mnbest > best; (best,numbest) = (mnbest,1)
        elseif mnbest == best; numbest += 1
        end
    end
    return (best,numbest)
end

######################################################################################################
### For the large, we're looking for either a O(S) or O(S*logS) solution.  Here we have a master
### theorem divide and conquer.  Note for NlogN, we can do linear work in the parent.  Note that
### one of our previous searches in the small was linear, so this what we do.
###
### -- We break the array into a left,center,right, where center == 1 element
### -- We recurse on the left and right side as per a typical divide and conquer solution
### -- In the parent, we calculate the largest set using the center element.  We do this
###    with 4 linear searches
###    --  (st1,en1) assming middle sets eastbound and westbound is forced by left path
###    --  (st2,en2) assming middle sets eastbound and westbound is forced by right path
###    --  (st3,en3) assming middle sets westbound and eastbound is forced by left path
###    --  (st4,en4) assming middle sets westbound and eastbound is forced by right path
######################################################################################################

function cSearch(st::I,cen::I,en::I,M::VI,N::VI,leftFirst=true)::PI
    m::I,n::I = M[cen],typemax(Int64)
    l::I,r::I = cen,cen
    if leftFirst
        while l > st && M[l-1] == m; l -= 1; end
        if l > st
            l -= 1; n = N[l]
            while l > st && (M[l-1] == m || N[l-1] == n); l -= 1; end
        end
        while r < en && (M[r+1] == m || N[r+1] == n); r += 1; end
    else
        while r < en && M[r+1] == m; r += 1; end
        if r < en
            r += 1; n = N[r]
            while r < en && (M[r+1] == m || N[r+1] == n); r += 1; end
        end
        while l > st && (M[l-1] == m || N[l-1] == n); l -= 1; end
    end
    return (l,r)
end

function dnc(st::I,en::I,M::VI,N::VI)
    if en-st <= 1; return (en-st+1,1); end  ## Cover the case of a length 1 or length 2 segment
    center::I = (st+en) ÷ 2
    (bestl::I,numBestl::I) = dnc(st,center-1,M,N)
    (bestr::I,numBestr::I) = dnc(center+1,en,M,N)
    (best::I,numbest::I) = (bestl > bestr) ? (bestl,numBestl) : (bestr > bestl) ? (bestr,numBestr) : (bestl,numBestl+numBestr)
    (l1::I,r1::I) = cSearch(st,center,en,M,N,true)
    (l2::I,r2::I) = cSearch(st,center,en,M,N,false)
    (l3::I,r3::I) = cSearch(st,center,en,N,M,true)
    (l4::I,r4::I) = cSearch(st,center,en,N,M,false)
    for (l::I,r::I) in SPI([(l1,r1),(l2,r2),(l3,r3),(l4,r4)])
        lbest::I = r-l+1
        if lbest > best; (best,numbest) = (lbest,1)
        elseif lbest == best; numbest += 1
        end
    end
    return (best,numbest)
end

function solveLarge(S::I,D::VI,A::VI,B::VI)::PI
    M::VI = D .+ A
    N::VI = D .- B
    return dnc(1,S,M,N)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S = gi()
        D::VI = fill(0,S)
        A::VI = fill(0,S)
        B::VI = fill(0,S)
        for i in 1:S; D[i],A[i],B[i] = gis(); end
        #ans = solveSmall(S,D,A,B)
        ans = solveLarge(S,D,A,B)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

