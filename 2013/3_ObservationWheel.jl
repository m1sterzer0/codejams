
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

function presolveSmall()
    pre::Vector{VF} = []
    for i in 1:20
        l = 2^i
        ans::VF = fill(0.00,l)
        work::VI = fill(0,i)
        oneoveri = 1.0 / i
        for key in l-1:-1:0
            lans::Float64 = 0.00
            if key == 0
                lans = i + ans[1+1]
            elseif key < l-1
                next::I = -1
                for j in 1:i
                    if key & (1 << (j-1)) == 0; next = i+j; break; end
                end
                for j in i:-1:1
                    if key & (1 << (j-1)) == 0; next = j; end
                    gap::I = next-j
                    nkey::I = key | 1 << ((next > i ? next-i : next) - 1)
                    lans += (i-gap) + ans[nkey+1]
                end
                lans *= oneoveri
            end
            ans[key+1] = lans
        end
        push!(pre,ans)
    end
    return (pre,)
end

function solveSmall(S::String,working)::F
    (presolvearr,) = working
    key::I = 0
    for i in 1:length(S)
        if S[i] == 'X'; key |= (1 << (i-1)); end
    end
    ans = presolvearr[length(S)][key+1]
    return ans
end

function preworkLarge()
    c::Array{Float64,2} = fill(0.0,201,201)
    for i in 0:200
        for j in 0:i
            c[i+1,j+1] = (j == 0 || j == i) ? 1.0 : c[i,j]+c[i,j+1]
        end
    end
    E::Array{F,2} = fill(0.00,201,201)
    P::Array{F,2} = fill(0.00,201,201)
    numEmpty::Array{I,2} = fill(0,201,201)
    return (c,E,P,numEmpty)
end

function solveLarge(S::String,working)::F
    (c::Array{F,2},E::Array{F,2},P::Array{F,2},numEmpty::Array{I,2}) = working
    comb(a::I,b::I) = c[a+1,b+1]
    N = length(S)

    ans::Float64 = -1.00
    if '.' ∉ S; ans = 0.00; elseif S == "."; ans = 1.00; end
    if ans >= 0; return ans; end

    for delta in 0:N-1
        for i::I in 1:N
            j::I = i+delta
            if j > N; j -= N; end
            pj::I = j - 1
            if pj == 0; pj = N; end
            numEmpty[i,j] = (i == j ? 0 : numEmpty[i,pj]) + (S[j] == 'X' ? 0 : 1) 
            ## Base cases
            if S[j] == 'X'; P[i,j] = 0.00; E[i,j] = 0.00; continue; end
            if numEmpty[i,j] == 1; P[i,j] = 1.00; E[i,j] = 0; continue; end
            ## Now the interesting case, we cycle through the "next to last" options
            P[i,j] = 0.00
            E[i,j] = 0.00
            k::I = i
            while (k != j)
                nk = (k == N) ? 1 : k+1
                if S[k] == 'X'; k = nk; continue; end
                ne1 = numEmpty[i,k]
                ne2 = numEmpty[nk,j]
                width1 = k-i+1;  if width1 <= 0; width1 += N; end
                width2 = j-nk+1; if width2 <= 0; width2 += N; end
                widthtot = width1+width2
                ## Need ne1-1 balls to go left, then ne2-1 balls to go right, then 1 ball to go left
                pcase::F = 1.00
                if ne1+ne2 > 2; pcase *= comb(ne1+ne2-2,ne1-1); end
                if ne1 > 1; pcase *= (width1 / widthtot) ^ (ne1-1); end
                if ne2 > 1; pcase *= (width2 / widthtot) ^ (ne2-1); end
                pcase *= (width1 / widthtot) ## Final ball going to the left
                pcase *= P[i,k]
                pcase *= P[nk,j]
                if pcase > 0
                    ecase = E[i,k] + E[nk,j] + N - 0.5 * (width1-1)
                    P[i,j] += pcase
                    E[i,j] += pcase*ecase
                end
                k = nk
            end
            E[i,j] /= P[i,j]  ## P[i,j] should never be zero, since we have at least 2 empty slots
        end
    end

    ans = 0.5 * (N+1)  ## This is for the final person 
    for i in 1:N
        pi = i==1 ? N : i-1
        ans += P[i,pi] * E[i,pi]
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    workingSmall = presolveSmall()
    workingLarge = preworkLarge()
    for qq in 1:tt
        print("Case #$qq: ")
        S = gs()
        #ans = solveSmall(S,workingSmall)
        ans = solveLarge(S,workingLarge)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()


