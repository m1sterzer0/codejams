struct Event
    t::Float64
    type::Int64
    fc::Int64
    sc::Int64
end
Base.isless(a::Event,b::Event) = a.t < b.t || a.t == b.t && a.type < b.type

function doevents(events::Vector{Event},conflicts::Vector{Int64},S::Vector{Int64},P::Vector{Int64},c1::Int64,c2::Int64)
    (fc,sc) = S[c1] >= S[c2] ? (c1,c2) : (c2,c1)
    if P[fc] >= P[sc]+5; return; end
    if abs(P[fc]-P[sc]) < 5
        conflicts[fc] += 1; conflicts[sc] += 1
        if S[fc] > S[sc]
            d = P[sc]-P[fc]+5
            t = 1.0*d/(S[fc]-S[sc])
            push!(events,Event(t,0,fc,sc))
        end
    elseif S[fc] > S[sc]
        d1 = P[sc]-P[fc]-5
        d2 = d1 + 10
        t1 = 1.0*d1/(S[fc]-S[sc])
        t2 = 1.0*d2/(S[fc]-S[sc])
        push!(events,Event(t1,1,fc,sc))
        push!(events,Event(t2,0,fc,sc))
    end
end
function solve(idx::Int64,events::Vector{Event},state::Vector{Char},conflicts::Vector{Int64})::Float64
    mystate::Vector{Char} = state[:]
    myconflicts::Vector{Int64} = conflicts[:]
    while idx < length(events)
        e::Event = events[idx]
        if e.type == 0
            for c::Int64 in (e.fc,e.sc)
                myconflicts[c] -= 1
                if myconflicts[c] == 0; mystate[c] = '.'; end
            end
        else
            for c::Int64 in (e.fc,e.sc); myconflicts[c] += 1; end
            if mystate[e.fc] == mystate[e.sc]
                if mystate[e.fc] != '.'; return e.t; end
                mystate[e.fc] = 'L'; mystate[e.sc] = 'R'
                a1::Float64 = solve(idx+1,events,mystate,myconflicts)
                mystate[e.fc] = 'R'; mystate[e.sc] = 'L'
                a2::Float64 = solve(idx+1,events,mystate,myconflicts)
                return max(a1,a2)
            elseif mystate[e.fc] == '.'
                mystate[e.fc] = mystate[e.sc] == 'L' ? 'R' : 'L'
            elseif mystate[e.sc] == '.'
                mystate[e.sc] = mystate[e.fc] == 'L' ? 'R' : 'L'
            end
        end
        idx += 1
    end
    return 1e99
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        L = fill('.',N)
        S = fill(0,N)
        P = fill(0,N)
        for i in 1:N
            a,b,c = split(rstrip(readline(infile)))
            L[i] = a[1]
            S[i] = parse(Int64,b)
            P[i] = parse(Int64,c)
        end
        conflicts::Vector{Int64} = fill(0,N)
        events::Vector{Event} = []
        for i in 1:N-1
            for j in i+1:N
                doevents(events,conflicts,S,P,i,j)
            end
        end
        sort!(events)
        if length(events) == 0; print("Possible\n"); continue; end
        state::Vector{Char} = fill('.',N)
        for i in 1:N
            if conflicts[i] > 0; state[i] = L[i]; end
        end
        x = solve(1,events,state,conflicts)
        if x == 1e99; print("Possible\n"); else; print("$x\n"); end
    end
end

main()
