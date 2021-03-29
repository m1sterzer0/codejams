
using Random

function solveBruteForce(X::Int64,Y::Int64,C::String)::Int64
    N = length(C)
    best = 1_000_000_000_000_000_000
    for i in 0:2^N-1
        running = 0; bad = false
        lastlet = i & 1 == 0 ? 'C' : 'J'
        for j in 0:N-1
            curlet = i & (1 << j) == 0 ? 'C' : 'J'
            if curlet == 'C' && C[j+1] == 'J'; bad = true; break; end
            if curlet == 'J' && C[j+1] == 'C'; bad = true; break; end
            if curlet == lastlet; continue; end
            if lastlet == 'C'; running += X; else; running += Y; end
            lastlet = curlet
        end
        if bad; continue; end
        best = min(best,running)
    end
    return best
end

function solveSmall(X::Int64,Y::Int64,C::String)::Int64
    N = length(C)
    ans = 0
    if 'C' ∉ C && 'J' ∉ C; return 0; end
    ii = 1; while C[ii] == '?'; ii += 1; end; lastval = C[ii]
    for i in 1:N
        if C[i] == '?'; continue; end
        if C[i] != lastval; ans += lastval == 'C' ? X : Y; lastval = C[i]; end
    end
    return ans
end

function solveLarge(X::Int64,Y::Int64,C::String)::Int64
    N = length(C)
    if N == 1; return 0; end
    ans = 0
    ## Full string of "?"
    if 'C' ∉ C && 'J' ∉ C
        ans = min(0,X,Y)
        if N % 2 == 0; ans = min(ans,(X+Y) * (N-2)÷2 + min(X,Y)); end
        if N % 2 == 1; ans = min(ans,(X+Y) * (N-1)÷2); end
        if N % 2 == 1; ans = min(ans,(X+Y) * (N-3)÷2 + min(X,Y)); end
        return ans
    end

    firstidx = 1; while C[firstidx] == '?'; firstidx += 1; end
    lastidx = N; while C[lastidx] == '?'; lastidx -= 1; end
    if firstidx > 1; ans += doPrefix(C[firstidx],firstidx-1,X,Y); end
    if lastidx < N; ans += doSuffix(C[lastidx],N-lastidx,X,Y); end
    while firstidx != lastidx
        if C[firstidx+1] != '?'
            if C[firstidx+1] != C[firstidx]; ans += C[firstidx] == 'C' ? X : Y; end
            firstidx += 1
        else
            n = firstidx+1
            while C[n] == '?'; n += 1; end
            ans += doGap(C[firstidx],C[n],n-firstidx-1,X,Y)
            firstidx = n
        end
    end
    return ans
end 

function doPrefix(c::Char,l::Int64,X::Int64,Y::Int64)
    if X >= 0 && Y >= 0; return 0; end
    if X+Y >= 0; return min(0,c == 'J' ? X : Y); end
    if l % 2 == 1
        return (l-1)÷2 * (X+Y) + min(0, c == 'J' ? X : Y)
    else
        return (l-2)÷2 * (X+Y) + min(X+Y, c == 'J' ? X : Y)
    end
end

function doSuffix(c::Char,l::Int64,X::Int64,Y::Int64)
    if X >= 0 && Y >= 0; return 0; end
    if X+Y >= 0; return min(0,c == 'C' ? X : Y); end
    if l % 2 == 1
        return (l-1)÷2 * (X+Y) + min(0, c == 'C' ? X : Y)
    else
        return (l-2)÷2 * (X+Y) + min(X+Y, c == 'C' ? X : Y)
    end
end

function doGap(c1::Char,c2::Char,l::Int64,X::Int64,Y::Int64)
    ans = 0
    if c1 != c2; l -= 1; ans += c1 == 'C' ? X : Y; end
    if X+Y >= 0; return ans; end
    ans += (X+Y) * ((l+1)÷2)
    return ans
end
    

function test1(ntc::Int64,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        #Slen = rand() < 0.1 ? rand(1:10) : rand(11:1000)
        Slen = rand(1:16)
        qprob = rand()
        cprob = rand()
        carr = []
        for i in 1:Slen
            if rand() < qprob; push!(carr,'?'); elseif rand() <= cprob; push!(carr,'C'); else; push!(carr,'J'); end
        end
        C = join(carr,"")
        X = rand(1:100)
        Y = rand(1:100)
        ans2 = solveBruteForce(X,Y,C)
        ans3 = solveLarge(X,Y,C)
        if !check
            print("$ttt\n")
        else
            ans1 = solveSmall(X,Y,C)
            if ans1 == ans2 && ans1 == ans3
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2 ans3:$ans3\n")
                ans1 = solveSmall(X,Y,C)
                ans2 = solveBruteForce(X,Y,C)
                ans3 = solveLarge(X,Y,C)
            end
        end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function test2(ntc::Int64,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        #Slen = rand() < 0.1 ? rand(1:10) : rand(11:1000)
        Slen = rand(1:16)
        qprob = rand()
        cprob = rand()
        carr = []
        for i in 1:Slen
            if rand() < qprob; push!(carr,'?'); elseif rand() <= cprob; push!(carr,'C'); else; push!(carr,'J'); end
        end
        C = join(carr,"")
        X = rand(-100:100)
        Y = rand(-100:100)
        ans2 = solveLarge(X,Y,C)
        if !check
            print("$ttt\n")
        else
            ans1 = solveBruteForce(X,Y,C)
            if ans1 == ans2
                 pass += 1
                 #print("Pass ans1:$ans1 ans2:$ans2\n")
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveBruteForce(X,Y,C)
                ans2 = solveLarge(X,Y,C)
            end
        end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
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
        sX,sY,C = gss()
        X = parse(Int64,sX)
        Y = parse(Int64,sY)
        #ans = solveSmall(X,Y,C)
        ans = solveLarge(X,Y,C)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test1(10000)
#test2(100000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

