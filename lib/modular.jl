const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

function modinv(a::Int64,p::Int64)
    ans::Int64, factor::Int64, e::Int64 = [1,a,p-2]
    while (e > 0) 
        if e & 1 ≠ 0; ans = (ans * factor) % p; end
        factor = (factor * factor) % p
        e = e >> 1
    end
    return ans
end

mmul(a::Int64,b::Int64)::Int64 = (a*b) % 1000000007
function mfact(a::Int64)
    ans = 1
    for i in 1:a; ans = mmul(ans,i); end
    return ans
end


function modadd(a::Int64,b::Int64)::Int64
    s::Int64 = a + b; return s >= 1000000007 ? s-1000000007 : s
end

function modsub(a::Int64,b::Int64)::Int64
    s::Int64 = a - b; return s < 0 ? s + 1000000007 : s
end

function modmul(a::Int64,b::Int64)::Int64
    return (a*b) % 1000000007
end

function modinv(a::Int64)::Int64
    ans::Int64 = 1
    factor::Int64 = a
    e::Int64 = 1000000007-2
    while (e > 0)
        if e & 1 ≠ 0; ans = modmul(ans,factor); end
        factor = modmul(factor,factor)
        e = e >> 1
    end
    return ans
end