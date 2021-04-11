
mutable struct State
    cards::Set{Int64}
    used::Vector{Int64}
    empty::Vector{Bool}
    curstate::Char
    curidx::Int64
    horiztarg::Int64
end

gs()::String = rstrip(readline(stdin))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function doPrework()::Dict{Int128,Tuple{Float64,Char}}
    db::Dict{Int128,Tuple{Float64,Char}} = Dict{Int128,Tuple{Float64,Char}}()
    k::Int128 = Int128(2^15-1)
    solveState(db,k)
    return db
end

function solveState(db::Dict{Int128,Tuple{Float64,Char}},k::Int128)::Tuple{Float64,Char}
    if !haskey(db,k)
        cbitset::Int128 = k & 0xffff
        used::Int128 = (k >> 16)
        cnt::Int128 = 0
        sumcards::Int128 = 0
        lowestcard::Int64 = -1
        for i in 0:14
            if cbitset & (1 << i) != 0
                cnt += 1
                sumcards += i
                if lowestcard < 0; lowestcard = i; end
            end
        end

        if cnt == 2
            score::Int128 = sumcards - ((k >> 16) & 0xf) - ((k >> 20) & 0xf)
            winp = score >= 15 ? 1.00 : 0.00
            db[k] = (winp,'P')
        else
            newused = used >> 4
            newcbitset::Int128 = cbitset ⊻ (1 << lowestcard)
            replcnt::Int128 = lowestcard+1

            ## Case 1: Wipe out the lowest card
            p1::Float64 = 0.00
            for i in 0:14;
                cmask = (Int128(1) << i)
                if cmask & cbitset == 0; continue; end
                newk::Int128 = (cbitset ⊻ cmask) | (newused << 16) 
                (x,y) = solveState(db,newk)
                p1 += x
            end

            ## Case 2: Search for and wipe out the lowest numbered card
            p2::Float64 = 0.00
            replmask::Int128 = 0
            replvalue::Int128 = 0
            for i in 1:cnt
                newk::Int128 = newcbitset | (newused & ~replmask | replvalue) << 16
                (x,y) = solveState(db,newk)
                p2 += x
                replvalue = (replvalue << 4) | replcnt
                replmask = (replmask << 4) | 0xf
            end
            ## Searching for, and wiping out, the lowest numbered card
            db[k] = (p1 >= p2) ? (p1/cnt,'A') : (p2/cnt,'B')
        end
    end
    return db[k]
end

function doNextState(db::Dict{Int128,Tuple{Float64,Char}},st::State)
    k = encodeState(st)
    (w,c) = solveState(db,k)
    st.curstate = c
    st.curidx = 1; while st.empty[st.curidx]; st.curidx += 1; end
    if c == 'B'
        lowestcard = 0
        for i in 0:15; if i in st.cards; lowestcard = i; break; end; end
        st.horiztarg = lowestcard+1
    end
end

function encodeState(st::State)
    k::Int128 = 0; offset = 16
    for i in 0:14; if i in st.cards; k |= (1 << i); end; end
    for i in 1:15; if !st.empty[i]; k |= (st.used[i] << offset); offset += 4; end; end
    return k
end

function main(infn="")
    db::Dict{Int128,Tuple{Float64,Char}} = doPrework()
    T,N,C = gis()

    states::Vector{State} = []
    for i in 1:T
        push!(states,State(Set{Int64}(collect(0:14)),fill(0,15),fill(false,15),'A',1,0))
    end
    numRounds::Int64 = N*(N+1)÷2
    plays::Vector{Int64} = []
    for i in 1:numRounds
        empty!(plays)
        for (j,st) in enumerate(states)
            if st.curstate == 'A';     push!(plays,st.curidx); st.used[st.curidx] += 1
            elseif st.curstate == 'B'; push!(plays,st.curidx); st.used[st.curidx] += 1
            else;                      push!(plays,0)
            end
        end
        statestr = join(plays," ")
        print("$statestr\n"); flush(stdout)
        if sum(plays) == 0; break; end
        res::Vector{Int64} = gis()
        for (j,st) in enumerate(states)
            if res[j] == 0 && (st.curstate == 'A' || st.curstate == 'B')
                st.empty[st.curidx] = true
                delete!(st.cards,st.used[st.curidx]-1)
                doNextState(db,st)
            elseif st.curstate == 'B' && st.used[st.curidx] == st.horiztarg
                st.curidx += 1
                while st.empty[st.curidx]; st.curidx += 1; end
            end
        end
    end
    ans::Vector{Int64} = []
    for (j,st) in enumerate(states)
        pens = [x for x in 1:15 if !st.empty[x]]
        push!(ans,pens[end-1])
        push!(ans,pens[end])
    end
    ansstr = join(ans," ")
    print("$ansstr\n"); flush(stdout)
end

function runPrework()
    db::Dict{Int128,Tuple{Float64,Char}} = Dict{Int128,Tuple{Float64,Char}}()
    k::Int128 = Int128(2^15-1)
    (w,c) = solveState(db,k)
    print("$w $c\n")
end

#runPrework()
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main()
#Profile.clear()
#@profilehtml main()
