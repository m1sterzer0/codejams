
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

struct Event; t::F; type::I; fc::I; sc::I; end
Base.isless(a::Event,b::Event) = a.t < b.t || a.t == b.t && a.type < b.type

function doevents(events::Vector{Event},conflicts::VI,S::VI,P::VI,c1::I,c2::I)
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

function solve(idx::I,events::Vector{Event},state::Vector{Char},conflicts::VI)::F
    mystate::Vector{Char} = state[:]
    myconflicts::VI = conflicts[:]
    while idx < length(events)
        e::Event = events[idx]
        if e.type == 0
            for c::I in (e.fc,e.sc)
                myconflicts[c] -= 1
                if myconflicts[c] == 0; mystate[c] = '.'; end
            end
        else
            for c::I in (e.fc,e.sc); myconflicts[c] += 1; end
            if mystate[e.fc] == mystate[e.sc]
                if mystate[e.fc] != '.'; return e.t; end
                mystate[e.fc] = 'L'; mystate[e.sc] = 'R'
                a1::F = solve(idx+1,events,mystate,myconflicts)
                mystate[e.fc] = 'R'; mystate[e.sc] = 'L'
                a2::F = solve(idx+1,events,mystate,myconflicts)
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

function solveSmall(N::I,C::Vector{Char},S::VI,P::VI)::F
    conflicts::VI = fill(0,N)
    events::Vector{Event} = []
    for i in 1:N-1
        for j in i+1:N
            doevents(events,conflicts,S,P,i,j)
        end
    end
    sort!(events)
    if length(events) == 0; return 1e99; end
    state::Vector{Char} = fill('.',N)
    for i in 1:N
        if conflicts[i] > 0; state[i] = C[i]; end
    end
    return solve(1,events,state,conflicts)
end

function solve2(events::Vector{Event},state::Vector{String},conflicts::VI)::F
    choicenum = 1
    for e in events
        if e.type == 0
            for c::I in (e.fc,e.sc)
                conflicts[c] -= 1
                if conflicts[c] == 0; state[c] = "."; end
            end
        else
            for c::I in (e.fc,e.sc); conflicts[c] += 1; end
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

function solveLarge(N::I,C::Vector{Char},S::VI,P::VI)::F
    conflicts::Vector{Int64} = fill(0,N)
    events::Vector{Event} = []
    for i in 1:N-1
        for j in i+1:N
            doevents(events,conflicts,S,P,i,j)
        end
    end
    sort!(events)
    if length(events) == 0; return 1e99; end
    state::Vector{String} = fill(".",N)
    for i in 1:N
        if conflicts[i] > 0; state[i] = string(C[i]); end
    end
    return solve2(events,state,conflicts)
end

function gencase(Nmin::I,Nmax::I,Smax::I,Pmax::I)
    N = rand(Nmin:Nmax)
    C::Vector{Char} = fill('.',N)
    S::VI = fill(0,N)
    P::VI = fill(0,N)
    good = false
    while !good
        good = true
        for i in 1:N; C[i] = rand(['L','R']); end
        for i in 1:N; S[i] = rand(1:Smax); end
        for i in 1:N; P[i] = rand(1:Pmax); end
        larr::VI = []; rarr::VI = []
        for i in 1:N
            if C[i] == 'L'; push!(larr,P[i]); else; push!(rarr,P[i]); end
        end
        for arr in (larr,rarr)
            sort!(arr)
            for i in 1:length(arr)-1
                if arr[i+1]-arr[i] < 5; good = false; end
            end
        end
    end
    return (N,C,S,P)
end

function test(ntc::I,Nmin::Int64,Nmax::Int64,Smax::Int64,Pmax::Int64,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,C,S,P) = gencase(Nmin,Nmax,Smax,Pmax)
        ans2 = solveLarge(N,C,S,P)
        if check
            ans1 = solveSmall(N,C,S,P)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,C,S,P)
                ans2 = solveLarge(N,C,S,P)
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
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        C::Vector{Char} = fill('.',N)
        S::VI = fill(0,N)
        P::VI = fill(0,N)
        for i in 1:N
            a,b,c = gss()
            C[i] = a[1]
            S[i] = parse(Int64,b)
            P[i] = parse(Int64,c)
        end
        #ans = solveSmall(N,C,S,P)
        ans = solveLarge(N,C,S,P)
        if ans == 1e99; print("Possible\n"); else; print("$ans\n"); end
    end
end

Random.seed!(8675309)
main()
#test(100,1,6,3,30)
#test(100,1,6,10,100)
#test(100,1,6,30,1000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

