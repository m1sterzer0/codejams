
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


function gencase(Nmin::I,Nmax::I,Kmin::I,Kmax::I,Emin::I,Emax::I)
    N::I = rand(Nmin:Nmax)
    K::I = rand(Kmin:Kmax)
    E::I = rand(Emin:Emax)
    CK::Vector{VI} = [VI() for i in 1:N]
    keysupersetsize::I = rand(Kmin:Kmax)
    skeys::SI = SI()
    while length(skeys) < keysupersetsize; push!(skeys,rand(1:200)); end
    lkeys::VI = [x for x in skeys]
    T::VI = rand(lkeys,N)
    KK::VI = rand(lkeys,K)

    keys2distribute::VI = []
    for i in 1:N-1; push!(keys2distribute,0); end

    if rand() > 0.80
        ## Here we only allocate what we need
        keycount::VI = fill(0,200)
        for i in T; keycount[i] += 1; end
        for i in KK; keycount[i] -= 1; end
        for i in 1:200
            if keycount[i] <= 0; continue;; end
            for j in 1:keycount[i]; push!(keys2distribute,i); end
        end
        for i in 1:E
            push!(keys2distribute,rand(lkeys))
        end
    else
        numkeys = rand(N:3N)
        for i in numkeys; push!(keys2distribute,i); end
    end

    shuffle!(keys2distribute)
    cptr::I = 1
    for i in keys2distribute
        if i == 0; cptr += 1; continue; end
        push!(CK[cptr],i)
    end

    return (K,N,KK,T,CK)
end


function test(ntc::I,Nmin::I,Nmax::I,Kmin::I,Kmax::I,Emin::I,Emax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (K,N,KK,T,CK) = gencase(Nmin,Nmax,Kmin,Kmax,Emin,Emax)
        ans2 = solveLarge(K,N,KK,T,CK)
        if check
            ans1 = solveBruteForce(K,N,KK,T,CK)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                print("K:$K N:$N KK:$KK T:$T CK:$CK\n")
                ans1 = solveBruteForce(K,N,KK,T,CK)
                ans2 = solveLarge(K,N,KK,T,CK)
            end
            #print("Case $ttt: $ans2\n")
        else
            print("Case $ttt: $ans2\n")
        end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function dosearch(cnt::I,N::I,keycount::VI,used::Vector{Bool},T::VI,CK::Vector{VI})::VI
    for i in 1:N
        if used[i] || keycount[T[i]] == 0; continue; end
        if cnt+1 == N; return [i]; end
        used[i] = true; keycount[T[i]] -= 1; for j in CK[i]; keycount[j] += 1; end
        ans = dosearch(cnt+1,N,keycount,used,T,CK)
        if length(ans) > 0; pushfirst!(ans,i); return ans; end
        used[i] = false; keycount[T[i]] += 1; for j in CK[i]; keycount[j] -= 1; end
    end
    return []
end

function solveBruteForce(K::I,N::I,KK::VI,T::VI,CK::Vector{VI})::VI
    keycount::VI = fill(0,200); for k in KK; keycount[k] += 1; end
    used::Vector{Bool} = fill(false,N)
    return dosearch(0,N,keycount,used,T,CK)
end

function findallkeys(keycount::VI,T::VI,CK::Vector{VI},KC::Vector{VI},
                     used::Vector{Bool},keysneeded::VI,N::I)::Bool
    visited::Vector{Bool} = copy(used)
    q::VI = []
    for i in 1:N; 
        if used[i] || keycount[T[i]] == 0; continue; end
        visited[i] = true
        push!(q,i)
    end

    keysfound::VI = fill(0,200)
    while !(isempty(q))
        c = popfirst!(q)
        for k in CK[c]
            keysfound[k] += 1
            for j in KC[k]
                if visited[j]; continue; end
                visited[j] = true; push!(q,j)
            end
        end
    end

    for k in 1:200
        if keysneeded[k] > 0 && keysfound[k] == 0; return false; end
    end
    return true
end

function solveLarge(K::I,N::I,KK::VI,T::VI,CK::Vector{VI})::VI
    KC::Vector{VI} = [VI() for i in 1:200]
    for i in 1:N; push!(KC[T[i]],i); end
    keycount::VI = fill(0,200); for k in KK; keycount[k] += 1; end
    keysneeded::VI = [length(KC[x])-keycount[x] for x in 1:200]
    keysavailable::VI = fill(0,200)
    for i in 1:N; for j in CK[i]; keysavailable[j] += 1; end; end
    for i in 1:200; if keysneeded[i] > keysavailable[i]; return []; end; end
    used::Vector{Bool} = fill(false,N)
    if !findallkeys(keycount,T,CK,KC,used,keysneeded,N); return []; end
    ans = []
    for i in 1:N
        for j in 1:N
            if used[j] || keycount[T[j]] == 0; continue; end
            used[j] = true; keycount[T[j]] -= 1    
            for k in CK[j]; keycount[k] += 1; keysneeded[k] -= 1; end
            if findallkeys(keycount,T,CK,KC,used,keysneeded,N); push!(ans,j); break; end
            for k in CK[j]; keycount[k] -= 1; keysneeded[k] += 1; end
            used[j] = false; keycount[T[j]] += 1
        end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        K,N = gis()
        KK = gis()
        CK::Vector{VI} = [VI() for i in 1:N]
        T::VI = fill(0,N)
        for i in 1:N; CK[i] = gis(); T[i] = popfirst!(CK[i]); popfirst!(CK[i]); end
        #ans = solveBruteForce(K,N,KK,T,CK)
        ans = solveLarge(K,N,KK,T,CK)
        ansstr = length(ans) == 0 ? "IMPOSSIBLE" : join(ans," ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
main()
#test(100,1,10,1,20,0,5)
#test(1000,1,10,1,20,0,5)
#test(10000,1,10,1,20,0,5)

