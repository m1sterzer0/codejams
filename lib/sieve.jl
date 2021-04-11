const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

function mobiusSieve(n::Int64)
    mu = fill(Int8(1),n)
    isPrime = fill(true,n)

    ### Do the evens
    isPrime[4:2:n] .= false
    for i in 2:2:n; mu[i] = -mu[i]; end
    for i in 4:4:n; mu[i] = 0; end

    for i in 3:2:n
        if !isPrime[i]; continue; end
        for j in i*i:2*i:n; isPrime[j] = false; end
        for j in i:i:n;     mu[j] = -mu[j];     end
        for j in i*i:i*i:n; mu[j] = 0;          end
    end

    return mu
end