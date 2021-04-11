
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
### BEGIN MaxHeapEnh -- Enhance MinHeap with decrease key implemented by just running pop again
######################################################################################################

struct MaxHeapNodeEnh; n::I; v::I; end
Base.isless(a::MaxHeapNodeEnh,b::MaxHeapNodeEnh) = a.v < b.v

struct MaxHeapEnh
    valtree::Vector{MaxHeapNodeEnh}; pos::VI
    MaxHeapEnh(N::I) = new([],fill(0,N))
end

function _swap(h::MaxHeapEnh,i::I,j::I)
    (n1::I,n2::I) = (h.valtree[i].n,h.valtree[j].n)
    h.pos[n2],h.pos[n1] = i,j
    h.valtree[i],h.valtree[j] = h.valtree[j],h.valtree[i]
end

function _bubbleUp(h::MaxHeapEnh, i::I)
    if i == 1; return; end
    j::I = i >> 1; if h.valtree[i] > h.valtree[j]; _swap(h,i,j); _bubbleUp(h,j); end
end

function _bubbleDown(h::MaxHeapEnh,i::I)
    len::I = length(h.valtree); l::I = i << 1; r::I = l + 1
    res1::Bool = l > len || !(h.valtree[i] < h.valtree[l])
    res2::Bool = r > len || !(h.valtree[i] < h.valtree[r])
    if res1 && res2; return
    elseif res2 || !res1 && !(h.valtree[l] < h.valtree[r]); _swap(h,i,l); _bubbleDown(h,l)
    else; _swap(h,i,r); _bubbleDown(h,r)
    end
end

function Base.push!(h::MaxHeapEnh,node::MaxHeapNodeEnh)
    n::I = node.n; idx::I = h.pos[n]
    if idx == 0; push!(h.valtree,node); idx = length(h.valtree); h.pos[n] = idx
    elseif h.valtree[idx] < node; h.valtree[idx] = node
    end
    _bubbleUp(h,idx)
end

function Base.pop!(h::MaxHeapEnh)
    ans::MaxHeapNodeEnh = h.valtree[1]; h.pos[ans.n] = 0
    node2::MaxHeapNodeEnh = pop!(h.valtree)
    if length(h.valtree) >= 1; h.pos[node2.n] = 1; h.valtree[1] = node2; _bubbleDown(h,1); end
    return ans
end

Base.isempty(h::MaxHeapEnh) = isempty(h.valtree)

######################################################################################################
### END MaxHeapEnh
######################################################################################################

## Main idea here is that the length down on a vine where we are depends only
## on which vine we came from.  As such, we can encode a node as an ordered
## pair of previous vine and current vine, and that uniquely determines our state.
## We can use BFS from the starting position to see if we can reach any node with
## second coordinate (i.e. "current vine") as N
## Num Nodes: N^2.  Num Edges:(N^3).  Complexity: O(N^3)  Storage: O(N^2)

function solveSmall(N::I,preDD::VI,preLL::VI,D::I)::String
    DD::VI = copy(preDD)
    LL::VI = copy(preLL)
    ## Add a vine at the end
    if DD[end] < D; push!(DD,D); push!(LL,1); N+=1; end
    sb::Array{Bool,2} = fill(false,N,N)
    q::Vector{TI} = [(1,1,DD[1])]
    for i in 1:N; sb[i,i] = true; end
    while !isempty(q)
        (prev::I,cur::I,l::I) = popfirst!(q)
        for i in 1:N
            newd::I = abs(DD[i] - DD[cur])
            if newd > l || sb[cur,i]; continue; end
            newl = min(LL[i],newd)
            sb[cur,i] = true; push!(q,(cur,i,newl))
        end
    end
    for i in 1:N-1; if sb[i,N]; return "YES"; end; end
    return "NO"
end

## Improving on the idea from the small, we notice that the our distance from the top
## of the vines is non-increasing.  Thus, we really only want to process each node
## once from the point of maximal distance from the top that is achievable.
## The non-decreasing nature of this length suggests that we can use a MaxHeap
## (complete with increase_key) to process the nodes in correct order.
## Num Nodes: N  Num Edges:N^2  Complexity: O(N^2 * logN)  Storage: O(N)

function solveMedium(N::I,preDD::VI,preLL::VI,D::I)::String
    DD::VI = copy(preDD)
    LL::VI = copy(preLL)
    ## Add a vine at the end
    if DD[end] < D; push!(DD,D); push!(LL,1); N+=1; end
    h::MaxHeapEnh = MaxHeapEnh(N)
    push!(h,MaxHeapNodeEnh(1,DD[1]))
    darr::VI = fill(-1,N)
    while !isempty(h);
        a::MaxHeapNodeEnh = pop!(h)
        n::I = a.n; l::I = a.v; darr[n] = l;
        for i in 1:N
            if darr[i] > 0; continue; end
            if l < abs(DD[n]-DD[i]); continue; end
            newl = min(LL[i],abs(DD[n]-DD[i]))
            push!(h,MaxHeapNodeEnh(i,newl))
        end
    end
    return darr[N] > 0 ? "YES" : "NO"
end

## Finally, it turns out that if you can reach the end, you can do so without
## ever going backwards.  This seems quite easy to assume, but is quite difficult
## to prove.  As such, I figure that several people "got lucky" and assumed this
## and got the (likely) optimum answer.  The simplification over the solution above
## is that you can just process the nodes in order, and you only need to look right
## for potential intercepts.  This avoids the need for the MaxHeap w/ increase_key.  
## Num Nodes: N  Num Edges:N^2  Complexity: O(N^2)  Storage: O(N)

function solveLarge(N::I,preDD::VI,preLL::VI,D::I)::String
    DD::VI = copy(preDD)
    LL::VI = copy(preLL)
    ## Add a vine at the end
    if DD[end] < D; push!(DD,D); push!(LL,1); N+=1; end
    larr = fill(0,N); larr[1] = DD[1]
    for i in 1:N
        if larr[i] == 0; continue; end
        l::I = larr[i]
        for j in i+1:N
            if DD[j]-DD[i] > l; break; end
            newl = min(DD[j]-DD[i],LL[j])
            larr[j] = max(larr[j],newl)
        end
    end
    return larr[N] > 0 ? "YES" : "NO"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N::I = gi()
        DD::VI = fill(0,N)
        LL::VI = fill(0,N)
        for i in 1:N; DD[i],LL[i] = gis(); end
        D::I = gi()
        #ans = solveSmall(N,DD,LL,D)
        #ans = solveMedium(N,DD,LL,D)
        ans = solveLarge(N,DD,LL,D)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
