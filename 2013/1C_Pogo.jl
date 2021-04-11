
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

function solveSmall(X::I,Y::I)::String
    moves::VC = []
    if X > 0; for i in 1:X; push!(moves,'W'); push!(moves,'E'); end; end
    if X < 0; for i in 1:-X; push!(moves,'E'); push!(moves,'W'); end; end
    if Y > 0; for i in 1:Y; push!(moves,'S'); push!(moves,'N'); end; end
    if Y < 0; for i in 1:-Y; push!(moves,'N'); push!(moves,'S'); end; end
    return join(moves,"")
end

function solveLarge(X::I,Y::I)::String
    needed,tot,inc = abs(X) + abs(Y),0,0
    while tot < needed || tot % 2 != needed % 2; inc += 1; tot += inc; end
    a = ['.' for i in 1:inc]
    for i in inc:-1:1
        if abs(X) >= abs(Y)
            (cc,ii) = X > 0 ? ('E',-i) : ('W',i)
            a[i] = cc; X += ii
        else
            (cc,ii) = Y > 0 ? ('N',-i) : ('S',i)
            a[i] = cc; Y += ii
        end
    end
    ans = X==0 && Y==0 ? join(a,"") : "ERROR"
    return ans
end

function gencase(Cmax::I)
    X::I = 0; Y::I = 0
    while (X,Y) == (0,0); X = rand(-Cmax:Cmax); Y = rand(-Cmax:Cmax); end
    return (X,Y)
end

function test(ntc::I,Cmax::I)
    pass = 0
    for ttt in 1:ntc
        (X,Y) = gencase(Cmax)
        ans2 = solveLarge(X,Y)
        print("Case $ttt: X:$X Y:$Y ans:$ans2\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        X,Y = gis()
        ans = solveSmall(X,Y)
        #ans = solveLarge(X,Y)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,50)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

