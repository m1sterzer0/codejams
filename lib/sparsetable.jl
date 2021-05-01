const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

struct STRMQ; t::Array{I,2}; logt::VI; end
function genSparseTable(a::VI)::STRMQ
    n::I = length(a); k::I = 1; kl::I = 1
    while kl < length(a); k += 1; kl *= 2; end
    t::Array{I,2} = fill(0,n,k)
    for i in 1:n; t[i,1] = a[i]; end
    for j in 2:k
        sz::I = 1 << (j-2)
        for i in 1:n
            i2 = min(i+sz,n)
            t[i,j] = min(t[i,j-1],t[i2,j-1])
        end
    end
    logt::VI = fill(0,n)
    logt[1] = 1
    for i in 2:n; logt[i] = logt[i>>1] + 1; end
    return STRMQ(t,logt)
end

function rmq(t::STRMQ,l::I,r::I)
    idx::I = t.logt[r-l+1]
    return min(t.t[l,idx],t.t[r+1-(1<<(idx-1)),idx])
end

function test()
    a::VI = [1,8,3,9,5,0,2,7,4,6,7,4,3]
    t = genSparseTable(a)
    for l in 1:13
        for r in l:13
            print("l:$l r:$r a:$a min(l,r):$(rmq(t,l,r))\n")
        end
    end
end

test()

