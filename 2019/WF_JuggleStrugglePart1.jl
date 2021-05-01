
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

function getquad(x::I,y::I)::I
    return (y == 0 && x >= 0) ? 0 : (x > 0 && y > 0) ? 1 :
           (x == 0 && y > 0)  ? 2 : (x < 0 && y > 0) ? 3 :
           (x <  0 && y == 0) ? 4 : (x < 0 && y < 0) ? 5 :
           (x == 0 && y < 0)  ? 6 : 7
end

function findMatch(pts::Vector{TI})::I
    n = length(pts) # n here will be odd
    targn::I = (n-1)>>1
    j = 1
    for i in 1:n
        if j == i-1; j = i; end
        nxtj = j + 1; if nxtj > n; nxtj -= n; end
        while (nxtj != i)
            if pts[i][1]*pts[nxtj][2]-pts[i][2]*pts[nxtj][1] <= 0; break; end
            j = nxtj; nxtj += 1; if nxtj > n; nxtj -= n; end
        end
        numpts::I = j >= i ? j-i : n + j - i
        if targn == numpts; return pts[i][3]; end
    end
    ## Should not get here
    @assert false
end

function mycmp(a::TI,b::TI)::Bool
    x1::I,y1::I = a[1],a[2]
    x2::I,y2::I = b[1],b[2]
    q1::I = getquad(x1,y1)
    q2::I = getquad(x2,y2)
    if q1 != q2; return q1 < q2; end
    cp::I = x1*y2-y1*x2
    return cp > 0
end

function solveSmall(N::I,X::VI,Y::VI)::VI
    ans::VI = fill(-1,2N)
    for i in 1:2N
        if ans[i] > 0; continue; end
        pts::Vector{TI} = [(X[j]-X[i],Y[j]-Y[i],j) for j in 1:2N if j != i && ans[j] < 0]
        sort!(pts,lt=mycmp)
        k = findMatch(pts)
        ans[i] = k; ans[k] = i
    end
    return ans
end

function mycmp2(a::QI,b::QI)::Bool
    x1::I,y1::I = a[1],a[2]
    x2::I,y2::I = b[1],b[2]
    q1::I = getquad(x1,y1)
    q2::I = getquad(x2,y2)
    if q1 != q2; return q1 < q2; end
    cp::I = x1*y2-y1*x2
    return cp > 0
end

function dnc(ans::VI,X::VI,Y::VI,s1::VI,s2::VI,first::Bool)
    ## Pick a point to match randomly
    n = length(s1) + length(s2)
    ## Base cases
    if n == 0; return; end
    if n == 2; x = vcat(s1,s2); ans[x[1]] = x[2]; ans[x[2]] = x[1]; return; end

    ## Randomly pick a point
    xxx = rand(1:n)
    idx = xxx <= length(s1) ? s1[xxx] : s2[xxx-length(s1)]
    #print("DBG: n:$n s1:$s1 s2:$s2 idx:$idx\n")
    ## Build up the list of points
    pts::Vector{QI} = []
    for i in s1; if i != idx; push!(pts,(X[i]-X[idx],Y[i]-Y[idx],i,1)); end; end
    for i in s2; if i != idx; push!(pts,(X[i]-X[idx],Y[i]-Y[idx],i,2)); end; end
    #print("DBG: pts:$pts\n")
    ## Sort the points
    sort!(pts,lt=mycmp2)
    ## Now we find the match, but we need to keep track of the pointers 
    ii::I = 1; jj::I = 1; nxtjj::I = 2; targn::I = (n-2)>>1
    while(true)
        if jj == ii-1; jj = ii; end
        nxtjj = jj + 1; if nxtjj > n-1; nxtjj -= (n-1); end
        while (nxtjj != ii)
            if pts[ii][1]*pts[nxtjj][2]-pts[ii][2]*pts[nxtjj][1] <= 0; break; end
            jj = nxtjj; nxtjj += 1; if nxtjj > n-1; nxtjj -= n-1; end
        end
        numpts::I = jj >= ii ? jj - ii : (n-1) + jj - ii
        if targn == numpts; break; end
        ii += 1
    end
    x,y = idx,pts[ii][3]
    ans[x] = y; ans[y] = x
    
    ## Now we need to sort the residuals into four groups depending on both the incoming division
    ## and the division we just made
    state::I = 1
    s11::VI = []; s12::VI = []; s21::VI = []; s22::VI = []
    for adder::I in 1:n-2
        i = ii + adder; if i > n-1; i -= n-1; end
        if state == 1 && pts[i][4] == 1;     push!(s11,pts[i][3])
        elseif state == 1 && pts[i][4] == 2; push!(s12,pts[i][3])
        elseif state == 2 && pts[i][4] == 1; push!(s21,pts[i][3])
        else;                                push!(s22,pts[i][3])
        end
        if i == jj; state = 2; end
    end
    #print("DBG: x:$x y:$y s11:$s11 s12:$s12 s21:$s21 s22:$s22\n")
    if first
        dnc(ans,X,Y,vcat(s11,s12),vcat(s21,s22),false)
    else 
        dnc(ans,X,Y,s11,s22,false)
        dnc(ans,X,Y,s12,s21,false)
    end
end

function solveLarge(N::I,X::VI,Y::VI)::VI
    ans::VI = fill(-1,2N)
    dnc(ans,X,Y,collect(1:2N),VI(),true)
    return ans
end

function check3Colinear(N,X,Y)
    for i in 1:2N-2
        for j in i+1:2N-1
            for k in j+1:2N
                x1 = X[2]-X[1]; y1 = Y[2]-Y[1]
                x2 = X[3]-X[1]; y2 = Y[3]-Y[1]
                if x1*y2 == y1*x2; return true; end
            end
        end
    end
    return false
end

function gencase(Nmin::I,Nmax::I)
    N = rand(Nmin:Nmax)
    X::VI = []
    Y::VI = []
    ## Pick a point for the center for all of the lines to cross
    ## Easiest way to make a testcase
    Cx = rand(-10:10)
    Cy = rand(-10:10)
    slopes::SPI = SPI()
    while length(slopes) < N;
        x = rand(0:999000)
        y = rand(0:999000)
        if x == y == 0; continue; end
        g = gcd(x,y); x ÷= g; y ÷= g
        push!(slopes,(x,y))
    end
    lslopes::VPI = shuffle([(x,y) for (x,y) in slopes])
    for (x,y) in lslopes
        maxmul = 999000 ÷ max(x,y)
        mul1 = rand(1:maxmul)
        mul2 = rand(1:maxmul)
        if rand() < 0.5
            push!(X,Cx+mul1*x); push!(Y,Cy+mul1*y)
            push!(X,Cx-mul2*x); push!(Y,Cy-mul2*y)
        else
            push!(X,Cx+mul1*x); push!(Y,Cy-mul1*y)
            push!(X,Cx-mul2*x); push!(Y,Cy+mul2*y)
        end
    end

    if check3Colinear(N,X,Y); return gencase(Nmin,Nmax); end
    return (N,X,Y)
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,X,Y) = gencase(Nmin,Nmax)
        ans2 = solveLarge(N,X,Y)
        if check
            ans1 = solveSmall(N,X,Y)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,X,Y)
                ans2 = solveLarge(N,X,Y)
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
        X::VI = fill(0,2N)
        Y::VI = fill(0,2N)
        for i in 1:2N; X[i],Y[i] = gis(); end
        #ans = solveSmall(N,X,Y)
        ans = solveLarge(N,X,Y)
        println(join(ans," "))
    end
end

Random.seed!(8675309)
main()
#test(10,1,100)
#test(100,1,100)
#test(1000,1,100)
#test(10,5000,10000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,1,100)
#Profile.clear()
#@profilehtml test(10,5000,10000,false)

