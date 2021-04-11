
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

function isRecycled(a::I,b::I)::Bool
    sa = string(a)
    sb = string(b)
    ndig = length(sa)
    for i in 1:ndig-1
        sa = sa[end:end]*sa[1:end-1]
        if sa == sb; return true; end
    end
    return false
end

function solveSmall(A::Int64,B::Int64)
    ans = 0
    for i in A:B-1
        for j in i+1:B
            if isRecycled(i,j); ans += 1; end
        end
    end
    return ans
end

function solveLarge(A::Int64,B::Int64)
    ans::I = 0;
    ndig::I = length(string(A))
    working::Set{String} = Set{String}()
    sB::String = string(B)
    for a in A:B-1
        empty!(working)
        sa::String = string(a)
        for i in 2:ndig
            if sa[i] < sa[1] || sa[i] > sB[1]; continue; end            
            sb::String = sa[i:end]*sa[1:i-1]
            if sa < sb <= sB; push!(working,sb); end
        end
        ans += length(working)
    end
    return ans
end

function gencase(Nmin::I,Nmax::I)
    A = 1; B = 11
    while length(string(A)) != length(string(B))
        A = rand(Nmin:Nmax)
        B = rand(Nmin:Nmax)
    end
    if B < A; (A,B) = (B,A); end
    return (A,B)
end

function test(ntc::I,Nmin::I,Nmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (A,B) = gencase(Nmin,Nmax)
        ans2 = solveLarge(A,B)
        if check
            ans1 = solveSmall(A,B)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(A,B)
                ans2 = solveLarge(A,B)
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
        #ans = solveSmall(A,B)
        ans = solveLarge(A,B)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#test(1,1,1000)
#test(10,1,1000)
#test(100,1,1000)
#test(1000,1,1000)
#test(100,1,2000000,false)
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,1,1000)
#Profile.clear()
#@profilehtml test(50,1,2000000,false)

