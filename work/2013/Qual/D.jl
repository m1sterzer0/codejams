
## Patterns of zero free square roots (which are palindromes are)
## 3, 2, 22, 121, 212, 11211, 11, 111, 1111, 11111, 111111, 1111111, 11111111, 111111111

function prework()::Vector{BigInt}
    numbers::Vector{BigInt} = []
    function fillit(a::AbstractVector{Char})
        n::BigInt = parse(BigInt,join(a,""))
        push!(numbers,n*n)
    end
    ## Pattern 1
    fillit(['1'])
    fillit(['2'])
    fillit(['3'])
    ## Now do the ones with an even number of nonzero digits
    for midz in 0:48
        a1 = fill('0',midz)
        fillit(vcat(['1'], a1, ['1']))
        fillit(vcat(['2'], a1, ['2']))
        for z1 in 0:((50-4-midz)÷2)
            a2 = fill('0',z1)
            fillit(vcat(['1'],a2,['1'],a1,['1'],a2,['1']))
            for z2 in 0:((50-6-midz-2*z1)÷2)
                a3 = fill('0',z2)
                fillit(vcat(['1'],a3,['1'],a2,['1'],a1,['1'],a2,['1'],a3,['1']))
                for z3 in 0:((50-8-midz-2*z1-2*z2)÷2)
                    a4 = fill('0',z3)
                    fillit(vcat(['1'],a4,['1'],a3,['1'],a2,['1'],a1,['1'],a2,['1'],a3,['1'],a4,['1']))
                end
            end
        end
    end

    ## Now do the ones with an odd number of nonzero digits
    for z1 in 0:((50-3)÷2)
        a1 = fill('0',z1)
        fillit(vcat(['1'],a1,['1'],a1,['1']))
        fillit(vcat(['1'],a1,['2'],a1,['1']))
        fillit(vcat(['2'],a1,['1'],a1,['2']))
        for z2 in 0:((50-5-2*z1)÷2)
            a2 = fill('0',z2)
            fillit(vcat(['1'],a2,['1'],a1,['1'],a1,['1'],a2,['1']))
            fillit(vcat(['1'],a2,['1'],a1,['2'],a1,['1'],a2,['1']))
            for z3 in 0:((50-7-2*z1-2*z2)÷2)
                a3 = fill('0',z3)
                fillit(vcat(['1'],a3,['1'],a2,['1'],a1,['1'],a1,['1'],a2,['1'],a3,['1']))
                for z4 in 0:((50-9-2*z1-2*z2-2*z3)÷2)
                    a4 = fill('0',z4)
                    fillit(vcat(['1'],a4,['1'],a3,['1'],a2,['1'],a1,['1'],a1,['1'],a2,['1'],a3,['1'],a4,['1'],))
                end
            end
        end
    end
    sort!(numbers)
    return numbers
end

function numlt(numbers,a)
    u = length(numbers)
    if numbers[u] < a; return u; end
    l = 0
    while (u-l) > 1
        m = (u+l)÷2
        if numbers[m] < a; l = m; else; u = m; end
    end
    return l
end

function main(infn="")
    numbers::Vector{BigInt} = prework()
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        ##N = parse(Int64,rstrip(readline(infile)))
        ans = numlt(numbers,B+1)-numlt(numbers,A)
        print("$ans\n")
    end
end
    
main()

