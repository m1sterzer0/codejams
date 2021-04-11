
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

function solveSmall(A::I,B::I,P::VF)::F
    ans::F = 2 + B
    for numbs in 0:A
        nextc = A+1-numbs
        p::F = 1.0; for i in 1:A-numbs; p *= P[i]; end
        lans::F = numbs + B-A+numbs + 1 + (1.0-p) * (B+1)
        ans = min(ans,lans)
    end
    return ans
end

function solveLarge(A::I,B::I,P::VF)::F
    ans::F = 2 + B
    cump::VF = fill(0.00,A)
    p::F = 1.0; for i in 1:A; p *= P[i]; cump[i] = p; end
    ## Never makes sense to backspace to beginning, since hitting enter and retyping is always no worse
    for numbs in 0:A-1 
        lans::F = (B-A+1+2*numbs) + (1-cump[A-numbs]) * (B+1)
        ans = min(ans,lans)
    end
    return ans
end

function gencase(Amin,Amax,Bmin,Bmax,Pmin,Pmax)
    A::I = rand(Amin:Amax)
    B::I = rand(max(Bmin,A+1):Bmax)
    P::VF = [Pmin+(Pmax-Pmin)*rand() for i in 1:A]
    return (A,B,P)
end

function test(ntc::I,Amin::I,Amax::I,Bmin::I,Bmax::I,Pmin::F,Pmax::F,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (A,B,P) = gencase(Amin,Amax,Bmin,Bmax,Pmin,Pmax)
        ans2 = solveLarge(A,B,P)
        if check
            ans1 = solveSmall(A,B,P)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                #ans1 = solveSmall(A,B,P)
                ans2 = solveLarge(A,B,P)
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
        A,B = gis()
        P::VF = gfs()
        ans = solveSmall(A,B,P)
        #ans = solveLarge(A,B,P)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(100,1,10,1,100,0.0,1.0)
#test(100,1,10,1,100,0.8,1.0)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

