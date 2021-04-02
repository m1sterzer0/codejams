
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C::Int64 = parse(Int64,rstrip(readline(infile)))
        X::Int64,N::Int64 = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        board::Array{Char,2} = fill('.',2*N,2*X+2)
        pl::Int64,tl::Int64 = 2*N,2*X+1
        for i in 1:C
            s,e,t = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            (xx::Int64,tt::Int64,ee::Int64) = (2*s,2*t+1,2*e)
            board[xx,tt] = 'x'
            while true
                xx += 1; tt += 1
                if xx > pl; xx = 1; end
                board[xx,tt] = 'x'
                if xx == ee || tt >= tl; break; end
            end
        end
        best = 0
        for x in 1:N
            for t in 0:X-1
                (xx,tt) = 2*x, 2*t+1
                if board[xx,tt] == 'x'; continue; end
                l::Int64 = 0
                while true
                    xx -= 1; tt += 1
                    if xx <= 0; xx = 2*N; end
                    if board[xx,tt] == 'x'; break; end
                    l += 1
                    if tt == tl; break; end
                end
                best = max(best,l÷2)
            end
        end
        print("$best\n")
    end
end

main()
        
