
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
### Key observations
### -- The N^2 solution is easy.  We need something better.
### -- If we go very fast, we will pass all of the hikers exactly once
### -- As we slow down, two things happen
###    --- There now will be hikers that we never pass
###    --- Some hikers will now pass us multiple times
### -- KEY: we can ignore iterating on our speed and instead just look at finish line "events"
###    -- Start with the "very fast speed" case and assume that we pass H hikers
###    -- As hikers cross the finish line, consider the case that we reduce our speed to cross the
###       finish line just after that group hikers
###    -- The first time a hiker crosses the finish line, this is a good event for us, as it prevents
###       us from passing that hiker.
###    -- Any subsequent time that same hiker crosses the finish line is bad for us, as this means the
###       hiker has crossed our path once.
### -- KEY2: There are only H good events, and an infinite number of bad events
###    -- we should never process more than 2H events, as it can't get any better.
### -- KEY3: We don't have to store all the events at once.  Instead we can use a MinHeap and 
###          add "the next lap" after we process the current event.
######################################################################################################

mutable struct MyEvent
    offset::Int64
    m::Int64
end

Base.string(a::MyEvent) = "($(a.offset) $(a.m))"
Base.:(<)(a::MyEvent,b::MyEvent)::Bool  = Int128(a.offset) * Int128(a.m) <  Int128(b.offset) * Int128(b.m)
Base.:(<=)(a::MyEvent,b::MyEvent)::Bool = Int128(a.offset) * Int128(a.m) <= Int128(b.offset) * Int128(b.m)
Base.:(==)(a::MyEvent,b::MyEvent)::Bool = Int128(a.offset) * Int128(a.m) == Int128(b.offset) * Int128(b.m)
Base.:(>)(a::MyEvent,b::MyEvent)::Bool  = Int128(a.offset) * Int128(a.m) >  Int128(b.offset) * Int128(b.m)
Base.:(>=)(a::MyEvent,b::MyEvent)::Bool = Int128(a.offset) * Int128(a.m) >= Int128(b.offset) * Int128(b.m)
Base.:(!=)(a::MyEvent,b::MyEvent)::Bool = Int128(a.offset) * Int128(a.m) != Int128(b.offset) * Int128(b.m)

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        goodEvents = MinHeap{MyEvent}()
        badEvents = MinHeap{MyEvent}()
        for i in 1:N
            D,H,M = [parse(Int64,x) for x in split(readline(infile))]
            for j in 1:H
                push!(goodEvents,MyEvent(360-D,M+j-1))
            end
        end
        numHikers = length(goodEvents)
        cur,best = numHikers,numHikers
        for i in 1:2*numHikers

            if isempty(badEvents) || (!isempty(goodEvents) && top(goodEvents) < top(badEvents))
                xx = top(goodEvents)
                cur -= 1
                push!(badEvents,MyEvent(xx.offset+360,xx.m))
                pop!(goodEvents)
            else
                xx = top(badEvents)
                cur += 1
                push!(badEvents,MyEvent(xx.offset+360,xx.m))
                pop!(badEvents)
            end
            best = min(cur,best)
        end
        print("$best\n")
    end
end

main()