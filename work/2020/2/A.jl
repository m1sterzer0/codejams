
using Random

function solveSmall(L::Int64,R::Int64)::Tuple{Int64,Int64,Int64}
    i = 0
    while (i+1 <= L || i+1 <= R)
        i += 1
        if L >= R; L -= i; else; R -= i; end
    end
    return (i,L,R)
end

function solveLarge(L::Int64,R::Int64)::Tuple{Int64,Int64,Int64}
    swapped = false; if L < R; (L,R) = (R,L); swapped = true; end
    ## First, swallow up as many of L-R pancakes as we can while retaining
    ## L >= R. This means (k)(k+1)/2 <= L-R < (k+1)(k+2)/2.
    ## Use binary search to see how many orders we can get
    l,r = 0,2_000_000_000
    while r-l > 1; m = (r+l) ÷ 2; if m*m + m <= 2*(L-R); l = m; else; r=m; end; end
    L -= (l)*(l+1)÷2
    equal = false; if L == R; equal = true; end
    ## Left side will take orders
    ## (l+1) + (l+3) + ... + (l+2j-1) = (2l+2j)*j÷2 = (l+j)*j
    ## Right side will take orders
    ## (l+2) + (l+4) + (l+6) + ... + (l+2k) = (2l+2k+2)*k÷2 = (l+k+1)*k
    l1,r1 = 0,2_000_000_000
    while r1-l1 > 1; m = (r1+l1) ÷ 2; if (l+m)*m <= L;   l1 = m; else; r1 = m; end; end
    l2,r2 = 0,2_000_000_000
    while r2-l2 > 1; m = (r2+l2) ÷ 2; if (l+m+1)*m <= R; l2 = m; else; r2 = m; end; end
    j = l1; k = l2
    if k > j; k = j; elseif j > k+1; j = k+1; end ## Don't know if this is necessary
    tot = l+j+k; ; L -= (l+j)*j; R -= (l+k+1)*k
    (L,R) = (swapped && !equal) ? (R,L) : (L,R)
    return (tot,L,R)
end

function test(ntc::Int64,Lmax::Int64,Rmax::Int64)
    pass = 0
    for ttt in 1:ntc
        L = rand(1:Lmax)
        R = rand(1:Rmax)
        ans1 = solveSmall(L,R)
        ans2 = solveLarge(L,R)
        if ans1 == ans2
            pass += 1
        else
            print("ERROR Case $ttt L:$L R:$R ans1:$ans1 ans2:$ans2\n")
            ans1 = solveSmall(L,R)
            ans2 = solveLarge(L,R)
        end
    end
    print("$pass/$ntc passed\n")
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
        L,R = gis()
        #ans = solveSmall(L,R)
        ans = solveLarge(L,R)
        print("$(ans[1]) $(ans[2]) $(ans[3])\n")
    end
end

Random.seed!(8675309)
#test(1000,100,100)
#test(1000,1000,1000)
#test(1000,10000,10000)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

