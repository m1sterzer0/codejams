
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

function solveSmall(N::I,A::VI,B::VI)
    ineq::SPI = SPI()
    lastnode::VI = fill(-1,N)
    for i in 1:N
        if A[i] > 1; jn = lastnode[A[i]-1]; push!(ineq,(i,jn)); end
        lastnode[A[i]] = i
        for j in i+1:N
            if A[i] >= A[j]; push!(ineq,(i,j)); end
        end
    end
    fill!(lastnode,-1)
    for i in N:-1:1
        if B[i] > 1; jn = lastnode[B[i]-1]; push!(ineq,(i,jn)); end
        lastnode[B[i]] = i
        for j in 1:i-1
            if B[i] >= B[j]; push!(ineq,(i,j)); end
        end
    end

    gtlist::VVI = [VI() for x in 1:N]
    ltlist::VVI = [VI() for x in 1:N]
    for (i,j) in ineq; push!(gtlist[i],j); push!(ltlist[j],i); end

    ## Now just implement a backtracking search with the inequality graph and 
    used = fill(false,N)
    ans = fill(-1,N)
    function doit(pos::I)::Bool
        minj = 1+length(gtlist[pos])
        maxj = N-length(ltlist[pos])
        for pos2 in gtlist[pos]
            if pos2 < pos; minj = max(minj,ans[pos2]+1); end
        end
        for pos2 in ltlist[pos]
            if pos2 < pos; maxj = min(maxj,ans[pos2]-1); end
        end
        for x in minj:maxj
            if used[x]; continue; end
            used[x] = true
            ans[pos] = x
            if pos == N; return true; end
            aa = doit(pos+1)
            if aa; return true; end
            ans[pos] = -1
            used[x] = false
        end
        return false
    end
    doit(1)
    return ans
end

function solveLarge(N::I,A::VI,B::VI)
    ineq::SPI = SPI()
    lastnode::VI = fill(-1,N)
    for i in 1:N
        if A[i] > 1; jn = lastnode[A[i]-1]; push!(ineq,(i,jn)); end
        lastnode[A[i]] = i
        for j in i+1:N
            if A[i] >= A[j]; push!(ineq,(i,j)); end
        end
    end
    fill!(lastnode,-1)
    for i in N:-1:1
        if B[i] > 1; jn = lastnode[B[i]-1]; push!(ineq,(i,jn)); end
        lastnode[B[i]] = i
        for j in 1:i-1
            if B[i] >= B[j]; push!(ineq,(i,j)); end
        end
    end

    gtlist::VVI = [VI() for x in 1:N]
    for (i,j) in ineq; push!(gtlist[i],j); end
    ans::VI = fill(-1,N)
    used::VB = fill(false,N)
    trav::VI = []
    visited::VB = fill(false,N)

    function doit(n::I)
        if ans[n] >= 0; return; end
        qq::VI = [n]
        fill!(visited,false)
        visited[n] = true
        while !isempty(qq)
            nn = popfirst!(qq)
            push!(trav,nn)
            for cc in gtlist[nn]
                if !visited[cc] && ans[cc] < 0
                    visited[cc] = true
                    push!(qq,cc)
                end
            end
        end
        lt = length(trav)
        cnt = 0
        for i in 1:N
            if used[i]; continue; end
            cnt += 1
            if cnt == lt; ans[n] = i; used[i] = true; break; end
        end
        popfirst!(trav)
        sort!(trav,rev=true)
    end

    q::Vector{Int64} = collect(N:-1:1)
    while !isempty(q)
        nn = pop!(q)
        doit(nn)
        for nn in trav; push!(q,nn); end
        empty!(trav)
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        A::VI = gis()
        B::VI = gis()
        #ans = solveSmall(N,A,B)
        ans = solveLarge(N,A,B)
        ansstr = join(ans," ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

