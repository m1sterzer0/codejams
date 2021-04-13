
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

mmul(a::I,b::I)::I = (a*b) % 1000000007
function mfact(a::I)::I
    ans = 1
    for i in 1:a; ans = mmul(ans,i); end
    return ans
end

mutable struct UnsafeIntPerm; n::I; r::I; indices::VI; cycles::VI; end
Base.eltype(iter::UnsafeIntPerm) = Vector{Int64}
function Base.length(iter::UnsafeIntPerm)
    ans::I = 1; for i in iter.n:-1:iter.n-iter.r+1; ans *= i; end
    return ans
end
function unsafeIntPerm(a::VI,r::I=-1) 
    n = length(a)
    if r < 0; r = n; end
    return UnsafeIntPerm(n,r,copy(a),collect(n:-1:n-r+1))
end
function Base.iterate(p::UnsafeIntPerm, s::I=0)
    n = p.n; r=p.r; indices = p.indices; cycles = p.cycles
    if s == 0; return(n==r ? indices : indices[1:r],s+1); end
    for i in (r==n ? n-1 : r):-1:1
        cycles[i] -= 1
        if cycles[i] == 0
            k = indices[i]; for j in i:n-1; indices[j] = indices[j+1]; end; indices[n] = k
            cycles[i] = n-i+1
        else
            j = cycles[i]
            indices[i],indices[n-j+1] = indices[n-j+1],indices[i]
            return(n==r ? indices : indices[1:r],s+1)
        end
    end
    return nothing
end

function solveSmall(N::I,trains::VS)
    sb::VB = fill(false,26)
    ans::I = 0
    for p in unsafeIntPerm(collect(1:N))
        fill!(sb,false)
        last::Char = '*'; good::Bool = true
        for i::I in p
            for c::Char in trains[i]
                x::I = c-'`'
                if c == last; continue; end
                if sb[x]; good = false; break; end
                sb[x] = true
                last = c
            end
        end
        if good; ans += 1; end
    end
    return "$ans"
end

function solveLarge(N::I,trains::VS)
    left::VI = fill(-1,26)
    right::VI = fill(-1,26)
    singletons::VI = fill(0,26)
    used::VB = fill(false,26)
    done::Bool = false
    for i in 1:N
        t = trains[i]

        ## Check for a singleton train
        if t[1] == t[end]
            for c in t
                if c != t[1]; done = true; break; end
            end
            lval = t[1] - '`'
            singletons[lval] += 1
        ## Ok, we have two different ends.  Now we need to deal with the middle
        else
            j = 1; while(t[j+1] == t[1]); j+=1; end
            k = length(t); while(t[k-1] == t[end]); k-=1; end
            for ii in j+1:k-1
                if t[ii] == t[ii-1]; continue; end
                lval = t[ii] - '`'
                if used[lval]; done=true; break; end
                used[lval] = true
            end
            if done; break; end
            leftval,rightval = Int64(t[1]-'`'),Int64(t[end]-'`')
            if left[leftval] != -1; done=true; break; end
            if right[rightval] != -1; done=true; break; end
            left[leftval] = i; right[rightval] = i
        end
    end
    if done; return "0"; end

    ## Now check to see if any of the cars inner letters match the edge letters of a different car
    for i in 1:26
        if !used[i]; continue; end
        if left[i] != -1; done=true; break; end
        if right[i] != -1; done=true; break; end
        if singletons[i] > 0; done=true; break; end
    end
    if done; return "0"; end

    ## Now we count cars
    ans = 1
    for i in 1:26
        if singletons[i] > 0; ans = mmul(ans,mfact(singletons[i])); end
    end
    ncars = 0
    scoreboard = fill(false,26)
    for i in 1:26
        if scoreboard[i]; continue; end
        if  left[i] == -1 && right[i] == -1 && singletons[i] == 0; continue; end
        if  left[i] == -1 && right[i] == -1 && singletons[i] > 0; ncars += 1; scoreboard[i] = true; continue; end

        ncars += 1
        carnum = left[i] > 0 ? left[i] : right[i]

        ## Chase left
        num,c = carnum,i
        scoreboard[c] = true
        while right[c] != -1
            num = right[c]
            c = Int64(trains[num][1] - '`')
            if scoreboard[c]; done=true; break; end
            scoreboard[c] = true
        end
        ## Chase right
        num,c = carnum,Int64(trains[carnum][end]-'`')
        scoreboard[c] = true
        while left[c] != -1
            num = left[c]
            c = Int64(trains[num][end] - '`')
            if scoreboard[c]; done=true; break; end
            scoreboard[c] = true
        end
        if done; break; end
    end
    if done; return "0"; end
    ans = mmul(ans,mfact(ncars))
    return "$ans"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        trains = gss()
        #ans = solveSmall(N,trains)
        ans = solveLarge(N,trains)
        print("$ans\n")
    end
end

function gencase(Nmin::I,Nmax::I,Wlenmax::I)
    N = rand(Nmin:Nmax)
    alphabet::VC = [x for x in "abcdefghijklmnopqrstuvwxyz"]
    trains::VS = []
    for i in 1:N
        wlen = rand(1:Wlenmax)
        push!(trains,join(rand(alphabet,wlen)))
    end
    return (N,trains)
end

function test(ntc::I,Nmin::I,Nmax::I,Wlenmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,trains) = gencase(Nmin,Nmax,Wlenmax)
        ans2 = solveLarge(N,trains)
        if check
            ans1 = solveSmall(N,trains)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt trains:$trains ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,trains)
                ans2 = solveLarge(N,trains)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

Random.seed!(8675309)
main()
#test(100,3,10,3)
#test(10000,5,10,5)
#test(10000,5,10,10)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,3,10,3)
#Profile.clear()
#@profilehtml test(100,3,10,3)

