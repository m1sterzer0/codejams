using Random

function solveSmall(N::Int64,L::Vector{Int64},R::Vector{Int64})
    state::Int64 = 0
    pos::Int64 = 1
    visited::BitSet = BitSet()
    cnt::Int64 = 0
    while(true)
        if pos == N; return cnt; end
        encstate = N * state + (pos-1)
        if encstate in visited; return 0; end
        push!(visited,encstate)
        clearingstate = (state >> (pos-1)) & 1
        state ⊻= (1 << (pos-1))
        pos = clearingstate == 0 ? L[pos] : R[pos]
        cnt += 1
    end
end

function solveLarge(N::Int64,L::Vector{Int64},R::Vector{Int64},ds)
    alookup::Vector{Tuple{Int32,Int8,Int32}} = ds[1]
    avisited::BitSet = ds[2]
    bvisited::BitSet = ds[3]
    fill!(alookup,(Int32(0),Int8(0),Int32(0)))
    empty!(avisited)
    empty!(bvisited)

    ## Create the graph
    adj::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:N]
    for i in 1:N-1
        push!(adj[L[i]],i)
        if L[i] != R[i]; push!(adj[R[i]],i); end
    end

    ## Find the closest N/2 nodes to B with BFS
    visited::Vector{Bool} = [false for i in 1:N]
    bset = Set{Int64}()
    q::Vector{Int64} = []
    visited[N] = true; push!(bset,N); push!(q,N)
    while length(bset) < N ÷ 2
        if isempty(q); break; end
        n = popfirst!(q)
        push!(bset,n)
        for nn in adj[n]
            if visited[nn]; continue; end
            visited[nn] = true
            push!(q,nn)
        end
    end
    bshort::Bool = length(bset) < N ÷ 2    

    ## Define the nodes in A
    aset::Vector{Bool} = fill(false,N)
    for i in 1:N; if i ∉ bset; aset[i] = true; end; end

    ## Bookkeepeing for state compression
    asize::Int64 = N - length(bset)
    bsize::Int64 = length(bset)
    anodes::Vector{Int64} = [x for x in 1:N if aset[x]]
    bnodes::Vector{Int64} = [x for x in 1:N if !aset[x]]
    n2a::Vector{Int32} = fill(Int32(0),N)
    n2b::Vector{Int32} = fill(Int32(0),N)
    for i in 1:asize; n2a[anodes[i]] = Int32(i); end 
    for i in 1:bsize; n2b[bnodes[i]] = Int32(i); end 

    ## Do the solve, caching paths through the A set
    astate::Int32,bstate::Int32,node::Int8,cnt::Int64 = (Int32(0),Int32(0),Int8(1),0)
    qq::Vector{Int32} = []
    while(true)
        if node == N; return cnt; end
        if aset[node]
            if bshort; return 0; end
            anode = n2a[node]
            encstate = astate*asize+anode
            if encstate > 20971520; print("DBUG: asize:$asize node:$node anode:$anode astate:$astate encstate:$encstate\n"); end
            (newastate,newnode,cntadd) = alookup[encstate]
            if newnode == -1
                return 0
            elseif newnode == 0
                if encstate in avisited; return 0; end
                push!(avisited,encstate)
                push!(qq,encstate)
                lstate = (astate >> (anode-1)) & 1
                node = lstate == 0 ? L[node] : R[node]
                astate ⊻= 1 << (anode-1)
                cnt += 1
            else
                astate = newastate; node = newnode; cnt += cntadd
                encstate = astate*asize+anode
                if !isempty(qq)
                    cc = 1; reverse!(qq)
                    for e in qq; alookup[e] = (astate,node,cntadd+cc); cc += 1; end
                    empty!(qq); empty!(avisited)
                end
            end
        else
            if !isempty(qq)
                cc = 1; reverse!(qq)
                for e in qq; alookup[e] = (astate,node,cc); cc += 1; end
                empty!(qq); empty!(avisited)
            end
            bnode = n2b[node]
            encstate = bstate*bsize+bnode
            if encstate in bvisited; return 0; end
            push!(bvisited,encstate)
            lstate = (bstate >> (bnode-1)) & 1
            node = lstate == 0 ? L[node] : R[node]
            bstate ⊻= 1 << (bnode-1)
            cnt += 1
        end
    end
end

function tcgen(Nmax)
    N = Random.rand(2:Nmax)
    L::Vector{Int64} = [Random.rand(1:N) for i in 1:N-1]
    R::Vector{Int64} = [Random.rand(1:N) for i in 1:N-1]
    return (N,L,R)
end

function regress(ntc::Int64,Nmax)
    alookup::Vector{Tuple{Int32,Int8,Int32}} = fill((Int32(0),Int8(0),Int32(0)),20*2^20)
    avisited::BitSet = BitSet()
    bvisited::BitSet = BitSet()
    Random.seed!(8675309)
    for i in 1:ntc
        (N,L,R) = tcgen(Nmax)
        ans1 = solveSmall(N,L,R)
        ans2 = solveLarge(N,L,R,(alookup,avisited,bvisited))
        if ans1 != ans2
            print("Case $i: ERROR! $ans1 $ans2\n")
            ans1 = solveSmall(N,L,R)
            ans2 = solveLarge(N,L,R,(alookup,avisited,bvisited))
        else
            print("Case $i: PASS $ans1 $ans2\n")
        end
    end
end

function regress2(ntc::Int64,Nmax)
    alookup::Vector{Tuple{Int32,Int8,Int32}} = fill((Int32(0),Int8(0),Int32(0)),20*2^20)
    avisited::BitSet = BitSet()
    bvisited::BitSet = BitSet()
    Random.seed!(8675309)
    for i in 1:ntc
        (N,L,R) = tcgen(Nmax)
        ans2 = solveLarge(N,L,R,(alookup,avisited,bvisited))
        print("Case $i: $ans2\n")
    end
end


function main(infn="")
    alookup::Vector{Tuple{Int32,Int8,Int32}} = fill((Int32(0),Int8(0),Int32(0)),20*2^20)
    avisited::BitSet = BitSet()
    bvisited::BitSet = BitSet()

    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        L::Vector{Int64} = fill(0,N-1)
        R::Vector{Int64} = fill(0,N-1)
        for i in 1:N-1; L[i],R[i] = gis(); end
        #ans = solveSmall(N,L,R)
        ans = solveLarge(N,L,R,(alookup,avisited,bvisited))
        if ans == 0; print("Infinity\n"); else; print("$ans\n"); end
    end
end

#regress(1000000,10)
#regress(1000,20)
#regress2(1000,40)
main()
