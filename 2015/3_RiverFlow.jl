
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

function solve(N::I,D::I,Darr::VI)::String
    if N == 1; return "0"; end
    for i in 1:N-2*D
        if Darr[i] != Darr[i+2*D]; return "CHEATERS!"; end
    end

    ## We note the following
    ## [1,1,1,1,0,0,0,0] . [1,0,0,1,-1,0,0,-1] = 2
    ## [0,1,1,1,1,0,0,0] . [1,0,0,1,-1,0,0,-1] = 0
    ## [0,0,1,1,1,1,0,0] . [1,0,0,1,-1,0,0,-1] = 0
    ## [0,0,0,1,1,1,1,0] . [1,0,0,1,-1,0,0,-1] = 0
    ## [a,b,c,d,a,b,c,d] . [1,0,0,1,-1,0,0,-1] = 0

    ## This gives rise to the following idea
    ## Assume max period is 2^k
    ## For i in k downto 1
    ##    Calculate the 2^(k-1) coefficients with the dot product scheme above
    ##    Adjust the sequence
    ##    Confirm it now has periodicity 2^(k-1) (not really needed)

    maxperiod = 2
    while 2*maxperiod <= 2*D; maxperiod *= 2; end
    w::VI = Darr[1:maxperiod]
    ans = 0
    while maxperiod > 1
        hp = maxperiod ÷ 2
        for i in 1:hp
            x = w[i] + w[i+hp-1] - w[i+hp] - w[i == 1 ? maxperiod : i-1]
            if x % 2 == 1
                return "CHEATERS!"
            elseif x > 0
                inc = x ÷ 2
                ans += inc
                for j in i+hp:i+2*hp-1
                    ii = j > maxperiod ? j - maxperiod : j
                    w[ii] += inc ## Add the water diverted by the farmers back into the river
                end
            elseif x < 0
                inc = -x ÷ 2
                ans += inc
                for j in i:i+hp-1
                    w[j] += inc ## Add the water diverted by the farmers back into the river
                end
            end
        end
        for i in 1:hp
            if w[i] != w[i+hp]; return "CHEATERS!"; end
        end
        maxperiod ÷= 2
    end
    ## Final check, need to ensure that the total amount of water in the river is >= number of farmers
    ## For example 5 0 1 0 5 0 1 0 ... requires 7 farmers to balance, but after balancing river only has
    ##     5 units of water, so it doesn't work
    return w[1] >= ans ? "$ans" : "CHEATERS!"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,D = gis()
        Darr::VI = gis()
        ans = solve(N::I,D::I,Darr::VI)
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

