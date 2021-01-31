
using Random
#Random.seed!(8675309)
Random.seed!(8765)

using Statistics

function goodperm()
    a = [x for x in 1:1000]
    for i in 1:1000
        p = Random.rand(i:1000)
        a[i],a[p] = a[p],a[i]
    end
    return a
end

function badperm()
    a = [x for x in 1:1000]
    for i in 1:1000
        p = Random.rand(1:1000)
        a[i],a[p] = a[p],a[i]
    end
    return a
end

function metric(p::Vector{Int64})
    ans = 0
    for i in 1:1000
        if p[i] > i; ans += 1; end
    end
    return ans
end

function metric2(p::Vector{Int64})
    return sum([(p[i]-i) for i in 1:100])
end


goodperms = [goodperm() for i in 1:100000]
badperms  = [badperm() for i in 1:100000]

goodmetrics = [metric(x) for x in goodperms]
badmetrics  = [metric(x) for x in badperms]
print("GOOD: mean:$(mean(goodmetrics)) std:$(std(goodmetrics))\n")
print("BAD:  mean:$(mean(badmetrics))  std:$(std(badmetrics))\n")
cutline = 0.5 * (mean(goodmetrics) + mean(badmetrics))
print("CUTLINE: $cutline\n")

goodmetrics2 = [metric2(x) for x in goodperms]
badmetrics2  = [metric2(x) for x in badperms]
print("GOOD: mean:$(mean(goodmetrics2)) std:$(std(goodmetrics2))\n")
print("BAD:  mean:$(mean(badmetrics2))  std:$(std(badmetrics2))\n")
cutline = 0.5 * (mean(goodmetrics2) + mean(badmetrics2))
print("CUTLINE: $cutline\n")


