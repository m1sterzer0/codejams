

## lazy and tree here end up being identical, but i've kept
## both for a good seg tree reference
mutable struct Wall
    maxc::Int64
    tree::Vector{Int32}
    lazy::Vector{Int32}
end

function _proplazy(w::Wall,idx::Int64,ss::Int64,se::Int64)
    if ss != se
        for j in [2*idx,2*idx+1]
            w.tree[j] = max(w.tree[j],w.lazy[idx]) 
            w.lazy[j] = max(w.lazy[j],w.lazy[idx])
        end
    end
    w.lazy[idx] = 0
end

function _rmq(w::Wall,idx::Int64,ss::Int64,se::Int64,qs::Int64,qe::Int64)::Int64
    if w.lazy[idx] != 0; _proplazy(w,idx,ss,se); end
    if qe < ss || se < qs; return 1_000_000_000_000_000_000; end
    if qs <= ss && se <= qe; return w.tree[idx]; end
    m = (ss+se)÷2
    v1 = _rmq(w,2*idx,ss,m,qs,qe)
    v2 = _rmq(w,2*idx+1,m+1,se,qs,qe)
    return min(v1,v2)
end

function _update(w::Wall,idx::Int64,ss::Int64,se::Int64,us::Int64,ue::Int64,v::Int32)
    if w.lazy[idx] != 0; _proplazy(w,idx,ss,se); end
    if ue < ss || se < us; return; end
    if us <= ss && se <= ue  ## Whole segment is in the update range
        w.tree[idx] = max(w.tree[idx],v)
        if ss != se; w.lazy[idx] = max(w.lazy[idx],v); end
    else 
    ## Need to update both halves and recalculate ourself
        m = (ss+se)÷2
        _update(w,2*idx,ss,m,us,ue,v)
        _update(w,2*idx+1,m+1,se,us,ue,v)
        w.tree[idx] = min(w.tree[2*idx],w.tree[2*idx+1])
    end
end 

update(w::Wall,a::Int64,b::Int64,v::Int32) = _update(w,1,1,w.maxc,2*a-1,2*b-1,v)
rmq(w::Wall,a::Int64,b::Int64) = _rmq(w,1,1,w.maxc,2*a-1,2*b-1)

function coordinateCompression(events::Vector{Tuple{Int64,Int64,Int64,Int64}})
    cc = Set{Int64}()
    for (d,s,e,w) in events; push!(cc,e); push!(cc,w); end
    ccl::Vector{Int64} = [x for x in cc]
    sort!(ccl)
    old2new = Dict{Int64,Int64}()
    for (i,c) in enumerate(ccl); old2new[c] = i; end
    events2 = Vector{Tuple{Int64,Int64,Int64,Int64}}()
    for (d,s,e,w) in events; push!(events2, (d,s,old2new[e],old2new[w])); end
    return events2,length(ccl)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ans = 0
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        events::Vector{Tuple{Int64,Int64,Int64,Int64}} = []
        for i in 1:N
            d,n,w,e,s,dd,dp,ds = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            for j in 1:n
                push!(events,(d,s,w,e))
                d += dd; w += dp; e += dp; s += ds
            end
        end
        events2,maxc = coordinateCompression(events)

        numnodes = 2*maxc-1
        nn = 1; while nn < numnodes; nn *=2; end
        segtreesize = 2*nn
        ww = Wall(numnodes,fill(0,2*nn),fill(0,2*nn))

        sort!(events2)
        last,le = 0,length(events2)
        while (last != le)
            last += 1
            start = last
            d = events2[last][1]
            while last < le && events2[last+1][1] == d; last += 1; end
            for i in start:last
                (_d,s,e,w) = events2[i]
                rr = rmq(ww,e,w)
                #print("DBG: i:$i rmq(ww,$e,$w) = $rr\n")
                if rr < s; ans += 1; end
            end
            for i in start:last
                (_d,s,e,w) = events2[i]
                #print("DBG: i:$i update(ww,$e,$w,$s)\n")
                update(ww,e,w,Int32(s))
            end
        end
        print("$ans\n")
    end
end

main()

