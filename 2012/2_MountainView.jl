
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

## Main idea
## * First, trace the chain of peaks from the first element to the last element,
##   and set them to the max.  Now we just need to solve each of the subproblems
##   beneath these "goal posts"
## * For each subproblem problem, we repeat the process of chasing chain.
##   We then process the heights in reverse chain order, keeping the chosen heights
##   just below the line between line joining the last two peaks assigned (or between
##   the goalpoasts if processing the first in the chain).  We then keep recursing

function solvey(dy::I,dx::I, y1::I, x1::I, x0::I )::I
    ## need y0 < y1 - (x1-x0)*(dy/dx)
    return (dx*y1 - (x1-x0)*dy - 1) ÷ dx
end

function solveInterval(l::I,r::I,N::I,X::VI,ans::VI,first::Bool)
    if r == l+1; return; end
    chain::VI = [l+1]; n::I = l+1
    while n < r; n = X[n]; push!(chain,n); end
    if n != r; for i in l+1:r-1; ans[i] = -1; end; return; end
    if first
        for i in chain; ans[i] = 1_000_000_000; end
    else
        for j in length(chain)-1:-1:1
            x0 = chain[j]; x1 = chain[j+1]; y1 = ans[x1]
            if j == length(chain)-1; ans[x0] = solvey(ans[r]-ans[l],r-l,y1,x1,x0)
            else; ans[x0] = solvey(ans[chain[j+2]]-ans[chain[j+1]],chain[j+2]-chain[j+1],y1,x1,x0)
            end
        end
    end
    for i in 1:length(chain)-1; solveInterval(chain[i],chain[i+1],N,X,ans,false); end
end

function solve(N::I,X::VI)::VI
    ans::Vector{Int64} = fill(0,N)
    solveInterval(0,N,N,X,ans,true)
    if -1 ∈ ans; return []; end
    ## Subtract off the minimum-1 to keep the numbers under control
    x = minimum(ans); x -= 1; ans .-= x; return ans
end

function gencase1(Nmin::I,Nmax::I)
    N::I = rand(Nmin:Nmax)
    h::VI = rand(1:1000000000,N)
    X::VI = check(N,h)
    return (N,X)
end

function check(N::I,h::VI)::VI
    X::VI = []
    for i in 1:N-1
        dy,dx,best = h[i+1]-h[i],1,i+1
        for j in i+2:N
            dy2,dx2 = h[j]-h[i],j-i
            if dy2*dx > dy*dx2; (dy,dx,best) = (dy2,dx2,j); end
        end
        push!(X,best)
    end
    return X
end

function test(ntc::I,Nmin::I,Nmax::I)
    pass = 0
    for ttt in 1:ntc
        (N,X) = gencase1(Nmin,Nmax)
        ans = solve(N,X)
        X2 = check(N,ans)
        if -1 ∉ ans && X == X2
            pass += 1
        else
            print("ERROR: ttt:$ttt N:$N X:$X ans:$ans X2:$X2\n")
            ans = solve(N,X)
        end
    end
    print("$pass/$ntc passed\n")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X = gis()
        ans = solve(N,X)
        ansstr = isempty(ans) ? "Impossible" : join(ans, " ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
main()
#test(10000,2,10)

