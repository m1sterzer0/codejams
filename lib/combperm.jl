const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

comb(n::Int64,k::Int64)::BigInt = k < 0 ? 0 : 
                                  k == 0 ? 1 :
                                  k == 1 ? n :
                                  k < n ? comb(n,k-1) * (n-k+1) ÷ k :
                                  k == n ? 1 : 0  
