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

function solve(events::Vector{Event},state::Vector{String},conflicts::Vector{Int64})::Float64
    choicenum = 1
    for e in events
        if e.type == 0
            for c::Int64 in (e.fc,e.sc)
                conflicts[c] -= 1
                if conflicts[c] == 0; state[c] = "."; end
            end
        else
            for c::Int64 in (e.fc,e.sc); conflicts[c] += 1; end
            if state[e.fc] == state[e.sc]
                if state[e.fc] == "."
                    state[e.fc] = "S$choicenum"
                    state[e.sc] = "D$choicenum"
                    choicenum += 1
                else
                    return e.t
                end
            else
                c1,c2 = e.fc,e.sc
                if state[c1] == "."; (c1,c2) = (c2,c1); end
                if state[c2] == "."
                    state[c2] = state[c1][1] == 'L' ? "R" :
                                state[c1][1] == 'R' ? "L" :
                                state[c1][1] == 'S' ? "D"*state[c1][2:end] :
                                                      "S"*state[c1][2:end]
                elseif state[c1][1] in "LR" && state[c2][1] in "LR"
                    continue
                elseif state[c2][1] in "LR"
                    otherstate = state[c2] == "L" ? "R" : "L"
                    mergestate(state,state[c1],otherstate)
                elseif state[c1][1] in "LR"
                    otherstate = state[c1] == "L" ? "R" : "L"
                    mergestate(state,state[c2],otherstate)
                else
                    antistate(state,state[c1],state[c2])
                end
            end
        end
    end
    return 1e99
end

function mergestate(state::Vector{String},s1::String,s2::String)
    (to1,to2) = ("L","R")
    (from1,from2) = ("S"*s1[2:end],"D"*s1[2:end])
    if s2 == "R"; (to1,to2) = (to2,to1); end
    if s1[1] == 'D'; (from1,from2) = (from2,from1); end
    for i in 1:length(state)
        if state[i] == from1; state[i] = to1; end
        if state[i] == from2; state[i] = to2; end
    end
end

function antistate(state::Vector{String},s1::String,s2::String)
    (to1,to2)    = ("D"*s1[2:end],"S"*s1[2:end])
    (from1,from2) = ("S"*s2[2:end],"D"*s2[2:end])
    if s1[1] == 'D'; (to1,to2) = (to2,to1); end
    if s2[1] == 'D'; (from1,from2) = (from2,from1); end
    for i in 1:length(state)
        if state[i] == from1; state[i] = to1; end
        if state[i] == from2; state[i] = to2; end
    end
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
        state::Vector{String} = fill(".",N)
        for i in 1:N
            if conflicts[i] > 0; state[i] = string(L[i]); end
        end
        x = solve(events,state,conflicts)
        if x == 1e99; print("Possible\n"); else; print("$x\n"); end
    end
end

main()
