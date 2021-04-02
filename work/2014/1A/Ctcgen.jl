using Random
Random.seed!(8675309)

function goodperm()
    a = [x for x in 0:999]
    for i in 1:1000
        p = Random.rand(i:1000)
        a[i],a[p] = a[p],a[i]
    end
    return a
end

function badperm()
    a = [x for x in 0:999]
    for i in 1:1000
        p = Random.rand(1:1000)
        a[i],a[p] = a[p],a[i]
    end
    return a
end

print("120\n")
for i in 1:120
    print("1000\n")
    x = Random.rand()
    p = x < 0.5 ? goodperm() : badperm()
    pstr = join(p, " ")
    print("$pstr\n")
end