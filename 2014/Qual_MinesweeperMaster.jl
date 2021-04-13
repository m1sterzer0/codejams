
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

function stringify(R::I,C::I,board::Array{Char,2})
    rowstrs = [join(board[i,:],"") for i in 1:R]
    return join(rowstrs,"\n")
end

function solve(R::I,C::I,M::I)
    F = R*C-M
    r = min(R,C); c = max(R,C)
    board::Array{Char,2} = fill('.',r,c)
    board[1,1] = 'c'
    if F == 1
        board = fill('*',r,c)
        board[1,1] = 'c'
    elseif r == 1
        ## We can always make 1 work
        for i in F+1:c; board[1,i] = '*'; end
    elseif r == 2
        ## We need an even number of mines
        ## Also, we can't make F==2 work
        if F==2 || M%2 == 1; return "Impossible"; end
        fc = F ÷ 2
        for i in 1:2
            for j in fc+1:c
                board[i,j] = '*'
            end
        end
    else
        if F in [2,3,5,7]; return "Impossible"; end
        if F > 2*c+1
            ## Here we can just fill them in from bottom to top, but have to watch out for the singleton left
            m,i = M,r
            while(m > 0)
                if m >= c
                    board[i,:] = ['*' for xx in 1:c]; m -= c; i -= 1
                elseif m == c-1
                    board[i,3:c] = ['*' for xx in 1:c-2]; m -= (c-2); i -= 1
                else
                    board[i,c-m+1:c] = ['*' for xx in 1:m]; m = 0
                end
            end
        else
            for i in 4:r; board[i,:] = ['*' for xx in 1:c]; end
            left = 3*c; j = c
            while (left > F)
                if left >= F+3
                    board[1:3,j] = ['*','*','*']; left -= 3; j -= 1
                else
                    board[3,j] = '*'; left -= 1; j -= 1
                end
            end
        end
    end

    return stringify(R, C, R <= C ? board : permutedims(board))
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C,M = gis()
        ans = solve(R,C,M)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

