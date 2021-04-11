
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


## Two observations
## a) Optimal strategy is to sit at the top for tt seconds and then let go of the brakes
## b) It is sufficient to check intersection at each of the endpoints 
## Doing algebra, we have x = 0.5*a*(t-tt)^2.  Given the coord of the other car as (t,x), we have
## tt >= t - sqrt(2*x1/a)

function solve(D::F,N::I,A::I,T::VF,X::VF,AA::VF)::VF
    ## First, solve for the time when the other car crosses D.
    ## This is used to set a lower bound for how long I need to wait.
    td::F = 0.00
    for i in 2:N
        if X[i] >= D && X[i-1] < D
            td = T[i-1] + (T[i] - T[i-1]) * (D - X[i-1]) / (X[i] - X[i-1])
            break
        end
    end

    ## Now, we try the accelerations and see what works.
    ## This sets a lower bound for how long I need to wait.
    ansarr::VF = []
    for a::F in AA
        mytt::F = max(0.00,td-sqrt(2*D/a))
        for i in 1:N
            if X[i] > D; continue; end
            mytt = max(mytt, T[i] - sqrt(2*X[i]/a))
        end
        ans::F = mytt + sqrt(2*D/a)
        push!(ansarr,ans)
    end
    return ansarr
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        Ds,Ns,As = gss()
        D::F = parse(Float64,Ds)
        N::I = parse(Int64,Ns)
        A::I = parse(Int64,As)
        T::VF = fill(0.00,N)
        X::VF = fill(0.00,N)
        for i in 1:N; T[i],X[i] = gfs(); end
        AA::VF = gfs()
        ans = solve(D,N,A,T,X,AA)
        for a in ans; print("$a\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")
