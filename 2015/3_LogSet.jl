
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

function solveSmall(P::I,E::VI,F::VI)::String
    ## Calc number of elements of S
    Fsum = sum(F)
    N,Npset = 1,2
    while(Npset < Fsum); N += 1; Npset *= 2; end

    D::Dict{I,I} = Dict{I,I}()
    for i in 1:P; D[E[i]] = F[i]; end
    EE = reverse(E)

    magnitudes::VI = []
    idx1::I = 1
    for i in 1:N
        while D[EE[idx1]] == 0
            idx1 += 1
        end
        idx2::I = idx1
        while (D[EE[idx2]] == 0) || (idx1==idx2 && D[EE[idx1]]==1)
            idx2 += 1
        end
        mag::I = EE[idx1] - EE[idx2]
        for j in 1:length(EE)
            if D[EE[j]] == 0; continue; end
            if mag == 0
                D[EE[j]] ÷= 2
            else
                D[EE[j]-mag] -= D[EE[j]]
            end
        end
        push!(magnitudes,mag)
    end
    sort!(magnitudes)
    return join(magnitudes, " ")
end

function solveLarge(P::I,E::VI,F::VI)::String
    ## Calc number of elements of S
    Fsum = sum(F)
    N,Npset = 1,2
    while(Npset < Fsum); N += 1; Npset *= 2; end

    D::Dict{I,I} = Dict{I,I}()
    for i in 1:P; D[E[i]] = F[i]; end
    EE = reverse(E)

    magnitudes = []
    idx1 = 1
    for i in 1:N
        while D[EE[idx1]] == 0
            idx1 += 1
        end
        idx2 = idx1
        while (D[EE[idx2]] == 0) || (idx1==idx2 && D[EE[idx1]]==1)
            idx2 += 1
        end
        mag = EE[idx1] - EE[idx2]
        for j in 1:length(EE)
            if D[EE[j]] == 0; continue; end
            if mag == 0
                D[EE[j]] ÷= 2
            else
                D[EE[j]-mag] -= D[EE[j]]
            end
        end
        push!(magnitudes,mag)
    end

    ## Now for the subset sum part
    ## This moves from NP-complete to tractable given that we have a short list of the allowable sums of powerset entries
    if EE[end] >= 0
        sort!(magnitudes)
        return join(magnitudes," ")
    elseif EE[1] <= 0
        mm = [-1*x for x in magnitudes]
        sort!(mm)
        return join(mm," ")
    else
        magnonzero = [x for x in magnitudes if x != 0]
        target = EE[1]
        sums = sort([x for x in Set([y for y in EE if y >=0])])
        sb = fill(Int8(0),length(magnonzero),length(sums))
        lookup::Dict{I,I} = Dict{I,I}()
        for i in 1:length(sums); lookup[sums[i]] = i; end
        for i in 1:length(magnonzero)
            m = magnonzero[i]
            sb[i,1] = 1  ## Can always get zero
            if haskey(lookup,m); sb[i,lookup[m]] = 1; end
            if i == 1; continue; end
            for j in 1:length(sums)
                if sb[i-1,j] == 0; continue; end
                sb[i,j] = 1  ## Can always not use the current element
                if !haskey(lookup,sums[j]+m); continue; end
                sb[i,lookup[sums[j]+m]] = 1
            end
        end
        ## Now we have a scoreboard of which sums can be made from the N smallest non-zero magnitudes
        ## Now we make the positive target from the smallest magnitudes possible, leaving the larger magnitudes for negative numbers
        while target > 0
            j = lookup[target]
            for i in 1:length(magnonzero)
                if sb[i,j] == 1
                    target -= magnonzero[i]
                    magnonzero[i] *= -1
                    break
                end
            end
        end
        magnonzero::VI = [-1*x for x in magnonzero]
        magneg::VI = [x for x in magnonzero if x < 0]
        magzero::VI = [x for x in magnitudes if x == 0]
        magpos::VI = [x for x in magnonzero if x > 0]
        mm::VI = vcat(sort(magneg),magzero,sort(magpos))
        out = join(["$x " for x in mm])[1:end-1]
        return out
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        P = gi()
        E::VI = gis()
        F::VI = gis()
        #ans = solveSmall(P,E,F)
        ans = solveLarge(P,E,F)
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

