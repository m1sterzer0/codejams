
function ispalindrome(n::Int64)
    nn = string(n)
    i,j = 1,length(nn)
    while (i<j)
        if nn[i] != nn[j]; return false; end
        i += 1; j -= 1
    end
    return true
end

function prework()
    numbers = []
    for i in 1:10_000_000
        if ispalindrome(i)
            n = i*i
            if ispalindrome(n)
                push!(numbers,n)
            end
        end
    end
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
    numbers = prework()
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ##N = parse(Int64,rstrip(readline(infile)))
        ans = numlt(numbers,B+1)-numlt(numbers,A)
        print("$ans\n")
    end
end

main()

