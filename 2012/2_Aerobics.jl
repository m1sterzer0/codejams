
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


function checkgood(i::I,X::VI,Y::VI,N::I,W::I,L::I,R::VI)
    for j in 1:N
        if j == i || X[j] == -1; continue; end
        dx::I = X[i]-X[j]; dy::I = Y[i]-Y[j]
        if dx*dx+dy*dy < (R[i]+R[j])^2; return false; end
    end
    return true
end

# There is a LOT of room on the mat, but the details are a bit tedious to do
# this manually.  Random seems like a reasonable way to go.  We simply sort
# the people from largest-smallest radius and try several times to place them
# randomly on the mat.

function solve(N::I,W::I,L::I,R::VI)::VI
    X::VI = fill(0,N); Y::VI = fill(0,N)
    ri::VPI = [(R[i],i) for i in 1:N]
    sort!(ri,rev=true)
    indices::VI = [x[2] for x in ri]
    while(true)
        good = true
        for i in (indices)
            for j in 1:2000
                X[i] = rand(0:W); Y[i] = rand(0:L)
                if checkgood(i,X,Y,N,W,L,R); break; end
                if j == 2000; good = false; end
            end
            if !good; break; end
        end
        if good; break; end
    end
    ansarr::VI = []
    for i in 1:N; push!(ansarr,X[i]); push!(ansarr,Y[i]); end
    return ansarr
end

function gencase(Nmin::I,Nmax::I,Rmin::I,Rmax::I)
    N = rand(Nmin:Nmax)
    R::VI = rand(Rmin:Rmax,N)
    ## approximate 5pi as 15 for internal testing stuff
    totArea::I = 15*sum(x*x for x in R)  ## W/ Rmax of 10^5, this maxes out at 15*1000*10^10 < 10^15
    Lmin::I = (totArea + 999_999_999) ÷ 1_000_000_000
    l,u = 1,1_000_000_000
    while (u-l) > 1; m = (l+u) >> 1; if m*m > totArea; u = m; else; l = m; end; end
    Lmax::I = l
    L = rand(Lmin:Lmax)
    W = (totArea + L - 1) ÷ L
    if rand() < 0.5; (L,W) = (W,L); end
    return (N,W,L,R)
end

function test(ntc::I,Nmin::I,Nmax::I,Rmin::I,Rmax::I)
    pass = 0
    for ttt in 1:ntc
        (N,W,L,R) = gencase(Nmin,Nmax,Rmin,Rmax)
        sumrsq = sum(x*x for x in R)
        print("DBG: ttt:$ttt N:$N W:$W L:$L sumrsq:$sumrsq\n")
        ansarr = solve(N,W,L,R)
        ansstr = join(ansarr," ")
        #print("Case #$ttt: $ansstr\n")
        print("Case #$ttt: done\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,W,L = gis()
        R::VI = gis()
        ans = solve(N,W,L,R)
        ansstr = join(ans," ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,1,10,1,100000)
#test(1000,900,1000,1,100000)
#test(1000,900,1000,9,10)
#test(1000,900,1000,90000,100000)




#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

