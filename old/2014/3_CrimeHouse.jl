
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
### BEGIN MINHEAP CODE
######################################################################################################

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function simulate(nstart::Int64,events::Vector{Tuple{Char,Int64}},idevents::Vector{Vector{Int64}})::Bool
    inside::Vector{Bool} = fill(false,2000)
    nxt::Vector{Int64} = fill(1,2000)
    extras::Int64 = 0
    N = length(events)

    ## Assign the starting people to the named people with initial leave events who will be leaving soonest
    needEnter = MinHeap{Tuple{Int64,Int64}}()
    needLeave = MinHeap{Tuple{Int64,Int64}}()

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
    
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        events::Vector{Tuple{Char,Int64}} = []
        idevents::Vector{Vector{Int64}} = []
        for i in 1:2000; push!(idevents,[]); end
        for i in 1:N
            tokens = split(readline(infile))
            action::Char = tokens[1][1]
            id::Int64 = parse(Int64,tokens[2])
            push!(events,(action,id))
            if id != 0; push!(idevents[id],i); end
        end
        net = 0
        for i in 1:N
            net += (events[i][1] == 'E') ? 1 : -1
        end

        if simulate(0,events,idevents);     print("$net\n");       continue; end
        if !simulate(1000,events,idevents); print("CRIME TIME\n"); continue; end
        simulate(5,events,idevents)

        l,u = 0,1000
        while u-l > 1
            m = (l+u) ÷ 2
            if simulate(m,events,idevents); u=m
            else; l=m
            end
        end
        ans = net + u
        print("$ans\n")
    end
end

main()

