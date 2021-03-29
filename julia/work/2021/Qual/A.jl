
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function solveSmall(N::I,L::VI)
    ans::I = 0
    inf = 1_000_000_000_000_000_000
    for i in 1:N-1
        minv::I,minidx::I = inf,0
        for j in i:N
            if L[j] < minv; minv = L[j]; minidx = j; end
        end
        ans += (minidx-i+1)
        L[i:minidx] = reverse(L[i:minidx])
    end
    return ans
end

#function solveLarge()
#    return 0
#end

#function gencase()
#    return 0
#end

#function test(ntc::I,check::Bool=true)
#    pass = 0
#    for ttt in 1:ntc
#        (A) = gencase()
#        ans2 = solveLarge(A)
#        if check
#            ans1 = solveSmall(A)
#            if ans1 == ans2
#                 pass += 1
#            else
#                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
#                ans1 = solveSmall()
#                ans2 = solveLarge()
#            end
#       else
#           print("Case $ttt: $ans2\n")
#       end
#    end
#    if check; print("$pass/$ntc passed\n"); end
#end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N::I = gi()
        L::VI = gis()
        ans = solveSmall(N,L)
        #ans = solveLarge()
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

