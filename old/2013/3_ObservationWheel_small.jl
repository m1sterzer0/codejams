
function presolve()
    pre = []
    for i in 1:20
        l = 2^i
        ans::Vector{Float64} = fill(0.00,l)
        work::Vector{Int64} = fill(0,i)
        oneoveri = 1.0 / i
        for key in l-1:-1:0
            lans::Float64 = 0.00
            if key == 0
                lans = i + ans[1+1]
            elseif key < l-1
                next::Int64 = -1
                for j in 1:i
                    if key & (1 << (j-1)) == 0; next = i+j; break; end
                end
                for j in i:-1:1
                    if key & (1 << (j-1)) == 0; next = j; end
                    gap::Int64 = next-j
                    nkey::Int64 = key | 1 << ((next > i ? next-i : next) - 1)
                    lans += (i-gap) + ans[nkey+1]
                end
                lans *= oneoveri
            end
            ans[key+1] = lans
        end
        push!(pre,ans)
    end
    return pre
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    pre::Vector{Vector{Float64}} = presolve()
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        key = 0
        for i in 1:length(S)
            if S[i] == 'X'; key |= (1 << (i-1)); end
        end
        ans = pre[length(S)][key+1]
        print("$ans\n")
    end
end

main()

