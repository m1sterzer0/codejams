
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

function solveSmall(N::I,L::VI,R::VI)::I
    state::I = 0
    pos::I = 1
    visited::BitSet = BitSet()
    cnt::I = 0
    while (true)
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

function solveLarge(N::I,L::VI,R::VI,working)::I
    alookup::Vector{Tuple{Int32,Int8,Int32}} = working[1]
    avisited::BitSet = working[2]
    bvisited::BitSet = working[3]
    fill!(alookup,(Int32(0),Int8(0),Int32(0)))
    empty!(avisited)
    empty!(bvisited)

    ## Create the graph
    adj::Vector{VI} = [VI() for i in 1:N]
    for i in 1:N-1
        push!(adj[L[i]],i)
        if L[i] != R[i]; push!(adj[R[i]],i); end
    end

    ## Find the closest N/2 nodes to B with BFS
    visited::Vector{Bool} = [false for i in 1:N]
    bset::SI = SI()
    q::VI = []
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
    asize::I = N - length(bset)
    bsize::I = length(bset)
    anodes::VI = [x for x in 1:N if aset[x]]
    bnodes::VI = [x for x in 1:N if !aset[x]]
    n2a::Vector{Int32} = fill(Int32(0),N)
    n2b::Vector{Int32} = fill(Int32(0),N)
    for i in 1:asize; n2a[anodes[i]] = Int32(i); end 
    for i in 1:bsize; n2b[bnodes[i]] = Int32(i); end 

    ## Do the solve, caching paths through the A set
    astate::Int32,bstate::Int32,node::Int8,cnt::I = (Int32(0),Int32(0),Int8(1),0)
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

function gencase(Nmin::I,Nmax::I)
    N::I = rand(Nmin:Nmax)
    L::VI = rand(1:N,N-1)
    R::VI = rand(1:N,N-1)
    return (N,L,R)
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    alookup::Vector{Tuple{Int32,Int8,Int32}} = fill((Int32(0),Int8(0),Int32(0)),20*2^20)
    avisited::BitSet = BitSet()
    bvisited::BitSet = BitSet()
    working = (alookup,avisited,bvisited)

    pass = 0
    for ttt in 1:ntc
        (N,L,R) = gencase(Nmin,Nmax)
        ans2 = solveLarge(N,L,R,working)
        if check
            ans1 = solveSmall(N,L,R)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,L,R)
                ans2 = solveLarge(N,L,R,working)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    alookup::Vector{Tuple{Int32,Int8,Int32}} = fill((Int32(0),Int8(0),Int32(0)),20*2^20)
    avisited::BitSet = BitSet()
    bvisited::BitSet = BitSet()
    working = (alookup,avisited,bvisited)
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        L::VI = fill(0,N-1)
        R::VI = fill(0,N-1)
        for i in 1:N-1; L[i],R[i] = gis(); end
        ans = solveSmall(N,L,R)
        #ans = solveLarge(N,L,R,working)
        if ans == 0; print("Infinity\n"); else; print("$ans\n"); end
    end
end

Random.seed!(8675309)
main()
#test(1,2,10)
#test(10,2,10)
#test(100,2,10)
#test(1000,2,10)
#test(60,35,40,false)
