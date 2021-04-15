
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

function solveSmall(N::I,num::I,digits::VI)
    onesCount::VI = fill(0,N)
    c::I = 0
    for i in 1:N; c += digits[i]; onesCount[i] = c; end
    bestnum::I,bestdenom::I = 10,1
    targnum::I,targdenom::I = num,1000000
    best::I = 1
    for start::I in 1:N
        prevOnes::I = start == 1 ? 0 : onesCount[start-1]
        for j::I in start:N
            num::I = onesCount[j]-prevOnes
            den::I = j - start + 1
            diffnum::I   = den * targnum - num * targdenom
            diffdenom::I = targdenom * den
            if diffnum < 0; diffnum = -diffnum; end
            if bestdenom * diffnum < bestnum * diffdenom
                bestnum,bestdenom,best = diffnum,diffdenom,start
            end
        end
    end
    return best-1
end

function solveLarge(N::I,num::I,digits::VI)
    ## Consider the set of N+1 points defined by (0,0) joined with the n terms
    ## (prefix length,prefix ones).  We are looking for the two points here
    ## defining the line segement with slope closest to F.  We can normalize out
    ## the slope by subtracting the line segment y=Fx from the points above.  This
    ## turns the problem into looking for the two points with minimum
    ## absolute value slope.  Finally, it is hard to see, but easy to prove, that the 
    ## optimal answer occurs between two adjacent points when the list is sorted by
    ## y coordinate.  The rest is details...
    
    pts::VPI = fill((0,0),N+1)
    for i in 1:N; pts[i+1] = (i,pts[i][2]+digits[i]); end
    pts2::VPI = [(x[1],1000000*x[2]-num*x[1]) for x in pts]
    sort!(pts2,by=x->x[2])
    best::I,bestnum::I,bestdenom::I= -1,1000001,1
    for i in 1:N
        diffx::I,diffy::I = pts2[i+1][1]-pts2[i][1], pts2[i+1][2]-pts2[i][2]
        if diffx < 0; diffx = -diffx; end
        if diffy < 0; diffy = -diffy; end
        minx::I = min(pts2[i][1],pts2[i+1][1])
        v::I = diffy*bestdenom - diffx*bestnum; 
        if (v < 0 || (v == 0 && minx < best))
            best,bestnum,bestdenom = minx,diffy,diffx
        end
    end
    return best
end

function gencase(Nmin::I,Nmax::I)
    N = rand(Nmin:Nmax)
    num::I = rand(0:1000000)
    onechance = rand()
    digits::VI = [rand() < onechance ? 1 : 0 for i in 1:N]
    return (N,num,digits)
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,num,digits) = gencase(Nmin,Nmax)
        ans2 = solveLarge(N,num,digits)
        if check
            ans1 = solveSmall(N,num,digits)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,num,digits)
                ans2 = solveLarge(N,num,digits)
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
        xx::VS = gss()
        N = parse(Int64,xx[1])
        num::I = xx[2][1] == '1' ? 1_000_000 : parse(Int64,xx[2][3:end])
        digits::VI = [parse(Int64,x) for x in gs()]
        #ans = solveSmall(N,num,digits)
        ans = solveLarge(N,num,digits)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1,1,1000)
#test(10,1,1000)
#test(100,1,1000)
#test(1000,1,1000)
#test(200,499900,500000,false)



#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

