
function _rmq(tree::Vector{Int32}, lazy::Vector{Int32}, idx::Int64,ss::Int64,se::Int64,qs::Int64,qe::Int64)::Int32
    vv::Int32 = lazy[idx]
    if vv != 0 && ss != se
        a::Int64 = idx<<1
        b::Int64 = a+1
        _a::Int32 = tree[a]; tree[a] = _a > vv ? _a : vv
        _b::Int32 = lazy[a]; lazy[a] = _b > vv ? _b : vv
        _c::Int32 = tree[b]; tree[b] = _c > vv ? _c : vv
        _d::Int32 = lazy[b]; lazy[b] = _d > vv ? _d : vv
    end
    if qe < ss || se < qs; return 1_000_000_000; end
    if qs <= ss && se <= qe; return tree[idx]; end
    m::Int64 = (ss+se) >> 1
    v1::Int32 = qs <= m ?   _rmq(tree,lazy,2*idx,ss,m,qs,qe)     : 1_000_000_000
    v2::Int32 = qe >= m+1 ? _rmq(tree,lazy,2*idx+1,m+1,se,qs,qe) : 1_000_000_000
    return v1 < v2 ? v1 : v2
end

function _update(tree::Vector{Int32}, lazy::Vector{Int32},idx::Int64,ss::Int64,se::Int64,us::Int64,ue::Int64,v::Int32)
    vv::Int32 = lazy[idx]
    if vv != 0 && ss != se
        a::Int64 = idx<<1
        b::Int64 = a+1
        _a::Int32 = tree[a]; tree[a] = _a > vv ? _a : vv
        _b::Int32 = lazy[a]; lazy[a] = _b > vv ? _b : vv
        _c::Int32 = tree[b]; tree[b] = _c > vv ? _c : vv
        _d::Int32 = lazy[b]; lazy[b] = _d > vv ? _d : vv
    end
    if ue < ss || se < us; return; end
    if us <= ss && se <= ue  ## Whole segment is in the update range
        _g::Int32 = tree[idx]; tree[idx] = _g > v ? _g : v
        if ss != se; _h::Int32 = lazy[idx]; lazy[idx] = _h > v ? _h : v; end
    else 
    ## Need to update both halves and recalculate ourself
        m::Int64 = (ss+se) >> 1
        if us <= m;   _update(tree,lazy,2*idx,ss,m,us,ue,v); end
        if ue >= m+1; _update(tree,lazy,2*idx+1,m+1,se,us,ue,v); end
        _e::Int32 = tree[2*idx]
        _f::Int32 = tree[2*idx+1]
        tree[idx] = _e < _f ? _e : _f
    end
end 

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tree::Vector{Int32} = fill(Int32(0),2^23)
    lazy::Vector{Int32} = fill(Int32(0),2^23)
    events::Vector{Tuple{Int32,Int32,Int32,Int32}} = fill((Int32(0),Int32(0),Int32(0),Int32(0)),2^20)
    old2new::Dict{Int32,Int32} = Dict{Int32,Int32}()
    cc::Vector{Int32} = []

    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        fill!(tree,Int32(0))
        fill!(lazy,Int32(0))
        fill!(events,(Int32(0),Int32(0),Int32(0),Int32(0)))
        empty!(old2new)
        empty!(cc)
        ans = 0
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        numevents = 0
        for i in 1:N
            d,n,w,e,s,dd,dp,ds = [parse(Int32,x) for x in split(rstrip(readline(infile)))]
            for j in 1:n
                numevents += 1
                events[numevents] = (d,s,w,e)
                d += dd; w += dp; e += dp; s += ds
            end
        end

        ## Do the coordinate compressions
        for (d,s,e,w) in events; push!(cc,e); push!(cc,w); end
        unique!(sort!(cc))
        for (i,c) in enumerate(cc); old2new[c] = i; end
        events2 = Vector{Tuple{Int32,Int32,Int32,Int32}}()
        for (d,s,e,w) in events; push!(events2, (d,s,old2new[e],old2new[w])); end
        maxc = length(cc)
        numnodes = 2*maxc-1
        sort!(events2)
        last,le = 0,length(events2)

        rmq(e::Int32,w::Int32) = _rmq(tree,lazy,1,1,numnodes,2*e-1,2*w-1)
        update(e::Int32,w::Int32,v::Int32) = _update(tree,lazy,1,1,numnodes,2*e-1,2*w-1,v)

        while (last != le)
            last += 1
            start = last
            d = events2[last][1]
            while last < le && events2[last+1][1] == d; last += 1; end
            for i in start:last
                (_d,s,e,w) = events2[i]
                rr = rmq(e,w)
                #print("DBG: i:$i rmq(ww,$e,$w) = $rr\n")
                if rr < s; ans += 1; end
            end
            for i in start:last
                (_d,s,e,w) = events2[i]
                #print("DBG: i:$i update(ww,$e,$w,$s)\n")
                update(e,w,s)
            end
        end
        print("$ans\n")
    end
end

main()

