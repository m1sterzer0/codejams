
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
### BEGIN MINHEAP CODE
######################################################################################################

function _bubbleUpMinHeap(vt::AbstractVector{T},i::Int64) where {T}
    if i == 1; return; end
    j::Int64 = i >> 1
    if vt[j] > vt[i]; vt[i],vt[j] = vt[j],vt[i]; _bubbleUpMinHeap(vt,j); end
end

function _bubbleDownMinHeap(vt::AbstractVector{T},i::Int64) where {T}
    len::Int64 = length(vt)
    l::Int64 = i << 1; r::Int64 = l + 1
    res1::Bool = l > len || vt[i] <= vt[l]
    res2::Bool = r > len || vt[i] <= vt[r]
    if res1 && res2; return;
    elseif res1; vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMinHeap(vt,r)
    elseif res2; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMinHeap(vt,l)
    elseif vt[l] <= vt[r]; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMinHeap(vt,l)
    else   vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMinHeap(vt,r)
    end
end

function _minHeapify(vt::AbstractVector{T}) where {T}
    len = length(vt)
    for i in 2:len; _bubbleUpMinHeap(vt,i); end
end

mutable struct MinHeap{T}
    valtree::Vector{T}
    MinHeap{T}() where {T} = new{T}(Vector{T}())
    function MinHeap{T}(xs::AbstractVector{T}) where {T}
        valtree = copy(xs)
        _minHeapify(valtree)
        new{T}(valtree)
    end
end
Base.length(h::MinHeap)  = length(h.valtree)
Base.isempty(h::MinHeap) = isempty(h.valtree)
top(h::MinHeap{T}) where {T} = h.valtree[1]
function Base.sizehint!(h::MinHeap{T},s::Integer) where {T}
    sizehint!(h.valtree,s); return h
end

function Base.push!(h::MinHeap{T},v::T) where {T} 
    push!(h.valtree,v)
    _bubbleUpMinHeap(h.valtree,length(h.valtree))
    return h
end

function Base.pop!(h::MinHeap{T}) where {T}
    v = h.valtree[1]
    xx = pop!(h.valtree)
    if length(h.valtree) >= 1
        h.valtree[1] = xx
        _bubbleDownMinHeap(h.valtree,1)
    end
    return v
end

######################################################################################################
### BEGIN END CODE
######################################################################################################

function solveSmall(R::I,C::I,N::I,D::I,RR::VI,CC::VI,BB::VI)::String
    for i in 1:N-1
        for j in i+1:N
            if abs(BB[i]-BB[j]) > D * (abs(RR[i]-RR[j]) + abs(CC[i]-CC[j]))
                return "IMPOSSIBLE"
            end
        end
    end
    myinf = 10^18
    d::Array{I,2} = fill(myinf,R,C)
    mh = MinHeap{TI}()
    for i in 1:N;
        push!(mh,(BB[i],RR[i],CC[i]))
    end
    while !isempty(mh)
        (v,i,j) = pop!(mh)
        if d[i,j] < myinf; continue; end
        d[i,j] = v
        if i > 1; push!(mh,(v+D,i-1,j)); end
        if j > 1; push!(mh,(v+D,i,j-1)); end
        if i < R; push!(mh,(v+D,i+1,j)); end
        if j < C; push!(mh,(v+D,i,j+1)); end
    end
    return string(sum(d) % 1_000_000_007)
end

######################################################################################################
### a) One key observation is that every square x is limited by min(B(vi) + D(vi,x)) where D is the
###    Manhattan distance.  This is a necessary condition.
###
### b) It isn't too hard to see that if all of the fixed values are consistent with this minimum
###    (i.e. they are limited by this brightness value), then the necessary condition is also a
###    sufficient condition, for the condition guarantees that adjacent squared cannot differ by
###    more than D.
###
### c) For the small, we merely need to check the pairs to see if they are compatible, and then we
###    construct the array of distances.  O(R*C*N)
###
### d) We can improve on the runetime by computing a "min distance" from a root node, where each fixed
###    cell has its distance fixed and the edge cost to adjacent cells is D.  This is functionaly
###    equivalent to the other approach, but it is slightly more efficient using Dijkstra.  Here
###    we are O(RC*log(RC))
###
### e) For the "large" we need a few more observations.
###    Key observation: If we chop up the grid into rectangles such that the influencing squares only
###    live on the corners, we can formulistically sum up large rectangels, and use a bit of
###    inclusion/exclusion.
###
### f) To calculate the values of the subgrid, we can either use either the exhaustive O(N^3)
##     calculation, or we can do another "mini-Dijkstra" O(N^2 log(N^2)). 
###
### g) This means the complexity is really just around calculating the contribution of a
###    square/row/efficient defined by 4 corners.  This can be done by seeing a quad is really
###    broken up into 5 rectangular regions that can be determined by examining the behavior along
###    the borders.
###
###    +------------------------------+-------------------------------------------------+
###    |A                             |                                                B|
###    |                              |                                                 |
###    | Limited by A                 |              Limited by B                       |
###    |                              |                                                 |
###    + -----------------------------+-------------------------------------------------+
###    |                                                                                |
###    |                    Either limited by B+C or A+D                                |
###    |                                                                                |
###    |                                                                                |
###    |                                                                                |
###    +----------------------------------------------------+---------------------------+
###    |                                                    |                           |
###    |              Limited by C                          |    Limited by D           |
###    |C                                                   |                          D|
###    +----------------------------------------------------+---------------------------+
###
### h) For the regions influenced by a single corner, the trick is in just summing up the 
###    additional D terms.  To solve the 2-D problem, we can simple break apart the D-terms required
###    to be added for horizontal and vertical displacements from the corner separately, which means
###    we can use simple arithmetic series math just replicated in the opposite dimension.  This turns
###    into this very compact formula:
###                   ans = A * R * C + D * C * (R)*(R-1)/2 + D * R * (C)*(C-1)/2
###
### i) For a isoceles triangular region influenced by one corner,
###   I admittedly didnt immediately recognize the sequence
###       0 + (1+1) + (2+2+2) + (3+3+3+3) + (4+4+4+4) + ...
###   needed for the D terms, but OEIS ot the rescue  --> 2 * binom(n+c,3), where c depends
###   on how you index. your sequence.  OEIS is an invaluable resource for things like this.
###   The equation then boils down to the following
###                   ans = A * (S) * (S+1) / 2 + 2 * D * (S-1) * (S) * (S+1) / 6
###
##  j) Finally, for the regions influenced by 2 corners, they will look something like this.
###    + -------------------------------------------------------------------------------+
###    |                           \                                                   F|
###    |                            \                                                   |
###    |                             \                                                  |
###    |                              \                                                 |
###    |E                              \                                                |
###    +--------------------------------------------------------------------------------+
###   Where each region can be decomposed further into up to 0-2 single-influenced rectangles
###   plus 0-1 single-influenced triangles. You can find the breakpoint by considering the
###   two edged bath from E to F (along the left/top for example) as a single line and examining
###   it the same way you determined the break points for the sides of the quad.
###    
######################################################################################################

function findLineIdx(C::I,e1::I,e2::I,D::I)::I
    return min(C-1,1 + (D * (C-1) + e2 - e1) ÷ (2D))
end

function solveLine(C::I,e1::I,e2::I,D::I)::Int128
    lb = findLineIdx(C,e1,e2,D)
    res =  Int128(e1) * Int128(lb) + Int128(e2) * Int128(C-lb) + Int128(D) * (Int128( (lb-1) * lb ÷ 2) + Int128( (C-lb-1) * (C-lb) ÷ 2))
    return res
end 

function solve1DCase(CCIs::VI,BBIs::VI,D::I)::Int128
    ans::Int128 = Int128(0)
    for i::I in 1:length(CCIs)-1
        ans += solveLine(CCIs[i+1]-CCIs[i]+1,BBIs[i],BBIs[i+1],D)
    end
    for i::I in 2:length(CCIs)-1
        ans -= BBIs[i]
    end
    return ans
end

function solveSingleQuad(R::I,C::I,e1::I,D::I)::Int128
    return Int128(R*C) * Int128(e1) + Int128((R-1)*R ÷ 2) * Int128(C) * Int128(D) + Int128((C-1)*C ÷ 2) * Int128(R) * Int128(D)
end

### Used OEIS to get the formulas
function solveSingleTriangle(R::I,e1::I,D::I)::Int128
    return Int128(e1) * Int128(R * (R+1) ÷ 2) + Int128(2D) * Int128(R-1) * Int128(R) * Int128(R+1) ÷ 6
end

function solveTrapezoid(R1::I,R2::I,e1::I,D::I)::Int128
    (R1,R2) = R1 > R2 ? (R1,R2) : (R2,R1)
    H = R1-R2+1
    return solveSingleQuad(R2,H,e1,D) + solveSingleTriangle(H-1,e1+R2*D,D)
end

## To figure out where the break point is, we just consider a line wrapped around from one corner ot the other
function solveDoubleQuad(R::I,C::I,e1::I,e2::I,D::I)::Int128
    if R::I > C::I; (R,C) = (C,R); end
    m::I = findLineIdx(R+C-1,e1,e2,D)
    ans::Int128 = Int128(0)
    ## Do the first part
    if m <= R;     ans += solveSingleTriangle(m,e1,D)
    elseif m <= C; ans += solveTrapezoid(m,m-R+1,e1,D)
    else
        ans += solveSingleQuad(C,m-C,e1,D)
        ans += solveTrapezoid(C,m-R,e1+D*(m-C),D)
    end

    m = R+C-1-m
    ## Do the first part
    if m <= R;     ans += solveSingleTriangle(m,e2,D)
    elseif m <= C; ans += solveTrapezoid(m,m-R+1,e2,D)
    else
        ans += solveSingleQuad(C,m-C,e2,D)
        ans += solveTrapezoid(C,m-R,e2+D*(m-C),D)
    end
    return ans
end


function solveQuad(R::I,C::I,nw::I,ne::I,sw::I,se::I,D::I)::Int128
    nbr::I = findLineIdx(C,nw,ne,D)
    sbr::I = findLineIdx(C,sw,se,D)
    wbr::I = findLineIdx(R,nw,sw,D)
    ebr::I = findLineIdx(R,ne,se,D)

    topsize::I = min(ebr,wbr)
    botsize::I = R-max(ebr,wbr)
    midsize::I = R - (topsize+botsize)

    tnw::Int128 = solveSingleQuad(nbr,  min(ebr,wbr),nw,D)
    tne::Int128 = solveSingleQuad(C-nbr,min(ebr,wbr),ne,D)
    tsw::Int128 = solveSingleQuad(sbr,  R-max(ebr,wbr),sw,D)
    tse::Int128 = solveSingleQuad(C-sbr,R-max(ebr,wbr),se,D)

    ans::Int128 = tnw+tne+tsw+tse
    if wbr < ebr;      ans += solveDoubleQuad(midsize,C, sw + (R-max(ebr,wbr))*D, ne + min(ebr,wbr) * D, D)
    elseif ebr < wbr;  ans += solveDoubleQuad(midsize,C, se + (R-max(ebr,wbr))*D, nw + min(ebr,wbr) * D, D)
    end
    return ans
end

function solveLarge(R::I,C::I,N::I,D::I,RR::VI,CC::VI,BB::VI)::String
    ## First, we get the indices of the rows and columns
    RRIs::VI = unique(sort(vcat([1,R],RR)))
    CCIs::VI = unique(sort(vcat([1,C],CC)))
    lr::I = length(RRIs)
    lc::I = length(CCIs)
    superR2idx::Dict{I,I} = Dict{I,I}()
    superC2idx::Dict{I,I} = Dict{I,I}()
    for (i::I,r::I) in enumerate(RRIs); superR2idx[r] = i; end
    for (i::I,c::I) in enumerate(CCIs); superC2idx[c] = i; end
    
    ## Use Dijkstra to calculate the values of the super coordinates
    ansarr::Array{I,2} = fill(-1,lr,lc)
    mh::MinHeap{TI} = MinHeap{TI}()
    for i in 1:N
        r::I = superR2idx[RR[i]]
        c::I = superC2idx[CC[i]]
        push!(mh,(BB[i],r,c))                
    end
    while !isempty(mh)
        (d::I,i::I,j::I) = pop!(mh)
        if ansarr[i,j] >= 0; continue; end
        ansarr[i,j] = d
        if i > 1;  push!(mh,(d+D*(RRIs[i]-RRIs[i-1]),i-1,j)); end
        if i < lr; push!(mh,(d+D*(RRIs[i+1]-RRIs[i]),i+1,j)); end
        if j > 1;  push!(mh,(d+D*(CCIs[j]-CCIs[j-1]),i,j-1)); end
        if j < lc; push!(mh,(d+D*(CCIs[j+1]-CCIs[j]),i,j+1)); end
    end

    ## Do the check for impossible conditions
    for idx in 1:N
        i,j = superR2idx[RR[idx]],superC2idx[CC[idx]]
        if ansarr[i,j] != BB[idx]; return "IMPOSSIBLE"; end
    end

    ans::Int128 = Int128(0)
    if lr == 1; ans = solve1DCase(CCIs,ansarr[1,:],D); return string(ans % 1_000_000_007); end
    if lc == 1; ans = solve1DCase(RRIs,ansarr[:,1],D); return string(ans % 1_000_000_007); end
    for i in 1:lr-1
        for j in 1:lc-1
            x = solveQuad(RRIs[i+1]-RRIs[i]+1,CCIs[j+1]-CCIs[j]+1,ansarr[i,j],ansarr[i,j+1],ansarr[i+1,j],ansarr[i+1,j+1],D)
            ans += x
        end
    end

    for i in 1:lr-1
        for j in 2:lc-1
            ans -= solveLine(RRIs[i+1]-RRIs[i]+1,ansarr[i,j],ansarr[i+1,j],D)
        end
    end

    for i in 2:lr-1
        for j in 1:lc-1
            ans -= solveLine(CCIs[j+1]-CCIs[j]+1,ansarr[i,j],ansarr[i,j+1],D)
        end
    end

    for i in 2:lr-1
        for j in 2:lc-1
            ans += ansarr[i,j]
        end
    end
    
    return string(ans % 1_000_000_007)
end


function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,N,D = gis()
        RR::VI = fill(0,N)
        CC::VI = fill(0,N)
        BB::VI = fill(0,N)
        for i in 1:N; RR[i],CC[i],BB[i] = gis(); end
        #ans = solveSmall(R,C,N,D,RR,CC,BB)
        ans = solveLarge(R,C,N,D,RR,CC,BB)
        print("$ans\n")
    end
end

function gencase(Rmin::I,Rmax::I,Cmin::I,Cmax::I,Nmin::I,Nmax::I,Dmin::I,Dmax::I,Bmin::I,Bmax::I)
    R = rand(Rmin:Rmax)
    C = rand(Cmin:Cmax)
    N = rand(Nmin:Nmax)
    D = rand(Dmin:Dmax)
    while N > R*C
        if R <= C; R += 1; else C += 1; end
    end
    pts::SPI = SPI()
    while length(pts) < N
        push!(pts,(rand(1:R),rand(1:C)))
    end
    lpts::VPI = shuffle([x for x in pts])
    RR::VI = [x[1] for x in lpts]
    CC::VI = [x[2] for x in lpts]
    BB::VI = rand(Bmin:Bmax,N)
    return (R,C,N,D,RR,CC,BB)
end

function test(ntc::I,Rmin::I,Rmax::I,Cmin::I,Cmax::I,Nmin::I,Nmax::I,Dmin::I,Dmax::I,Bmin::I,Bmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (R,C,N,D,RR,CC,BB) = gencase(Rmin,Rmax,Cmin,Cmax,Nmin,Nmax,Dmin,Dmax,Bmin,Bmax)
        ans2 = solveLarge(R,C,N,D,RR,CC,BB)
        if check
            ans1 = solveSmall(R,C,N,D,RR,CC,BB)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(R,C,N,D,RR,CC,BB)
                ans2 = solveLarge(R,C,N,D,RR,CC,BB)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

Random.seed!(8675309)
main()
#for ntc in (1,10,100,1000)
#    test(ntc,1,200,1,200,1,200,1,20,1,20)
#    test(ntc,1,200,1,200,1,200,1,1000000000,1,1000000000)
#end
#test(200,1,1000000000,1,1000000000,1,200,1,1000000000,1,1000000000,false)


