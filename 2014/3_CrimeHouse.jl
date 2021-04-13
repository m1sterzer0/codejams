
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
### END MINHEAP CODE
######################################################################################################

function simulate(nstart::I,events::Vector{Tuple{Char,Int64}},idevents::VVI)::Bool
    inside::VB = fill(false,2000)
    nxt::VI = fill(1,2000)
    extras::I = 0
    N = length(events)

    ## Assign the starting people to the named people with initial leave events who will be leaving soonest
    needEnter = MinHeap{PI}()
    needLeave = MinHeap{PI}()

    for i in 1:2000
        if !isempty(idevents[i])
            first = events[idevents[i][1]]
            if first[1] == 'L'
                push!(needEnter,(idevents[i][1],i))
            end
        end
    end

    for i in 1:nstart
        if !isempty(needEnter)
            (_t,id) = pop!(needEnter)
            inside[id] = true
        else
            extras += 1
        end
    end

    for i in 1:N
        (c,id) = events[i]
        if id > 0
            if c == 'E'
                if inside[id]; return false; end
                inside[id] = true
                nxt[id] += 1
                if nxt[id] <= length(idevents[id])
                    nxtidx = idevents[id][nxt[id]]
                    if events[nxtidx][1] == 'E'; push!(needLeave,(nxtidx,id)); end
                end
            else
                if !inside[id]; return false; end
                inside[id] = false
                nxt[id] += 1
                if nxt[id] <= length(idevents[id])
                    nxtidx = idevents[id][nxt[id]]
                    if events[nxtidx][1] == 'L'; push!(needEnter,(nxtidx,id)); end
                end
            end
        else
            if c == 'E'
                if !isempty(needEnter)
                    (_t,id) = pop!(needEnter)
                    inside[id] = true
                else
                    extras += 1
                end
            else
                if !isempty(needLeave)
                    (_t,id) = pop!(needLeave)
                    inside[id] = false
                elseif extras > 0
                    extras -= 1
                else
                    ## Here we are looking for a named id in the house that has no more events
                    found = false
                    for i in 1:2000
                        if inside[i] && nxt[i] > length(idevents[i])
                            found = true
                            inside[i] = false
                            break
                        end
                    end
                    if !found
                        ## Here we are looking for someone in the house with the latest leave event, and we are hoping for an E0 to come along and pair with it
                        lid,ltime = -1,-1
                        for i in 1:2000
                            if inside[i]
                                nxtidx = idevents[i][nxt[i]]
                                if nxtidx > ltime; lid = i; ltime = nxtidx; end
                            end
                        end
                        if lid < 0; return false; end  ## There is nobody to sacrifice
                        inside[lid] = false
                        push!(needEnter,(ltime,lid))
                    end
                end
            end
        end
    end
    return true
end

function solve(N::I,dir::VC,id::VI)
    events::Vector{Tuple{Char,I}} = []
    idevents::VVI = [VI() for i in 1:2000]
    for i in 1:N
        push!(events,(dir[i],id[i]))
        if id[i] != 0; push!(idevents[id[i]],i); end
    end
    net = 0
    for i in 1:N
        net += (events[i][1] == 'E') ? 1 : -1
    end

    if simulate(0,events,idevents); return "$net"; end
    if !simulate(1000,events,idevents); return "CRIME TIME"; end
    ##simulate(5,events,idevents)

    l,u = 0,1000
    while u-l > 1
        m = (l+u) ÷ 2
        if simulate(m,events,idevents); u=m; else; l=m; end
    end
    return "$(net + u)"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        dir::VC = fill('.',N)
        id::VI = fill(0,N)
        for i in 1:N
            s::VS = gss()
            dir[i] = s[1][1]
            id[i] = parse(Int64,s[2])
        end
        ans = solve(N,dir,id)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

