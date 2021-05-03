
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

const gameState = Tuple{I,I,Char}

function solve(N::Int64,M::VI,C::VI,d::Dict{gameState,Char})::PI
    board::VI = fill(-1,N)
    rem::VI = fill(1,N)
    done::Bool = false
    winningPlayer = 'A'
    aMistakes = 0
    bMistakes = 0
    (player,antiplayer) = ('A','B')
    for i in 1:N
        rem[M[i]] = -1
        board[C[i]] = M[i]
        if checkWinning(N,board); newWinningPlayer = 'A'; done = true; end
        if !done; newWinningPlayer = solvepos(N,antiplayer,copy(board),copy(rem),d); end
        if player == 'A' && winningPlayer != newWinningPlayer; aMistakes += 1; end
        if player == 'B' && winningPlayer != newWinningPlayer; bMistakes += 1; end
        #print("DBG: i:$i player:$player board:$board rem:$rem winningPlayer:$winningPlayer newWinningPlayer:$newWinningPlayer\n")
        winningPlayer = newWinningPlayer
        (player,antiplayer) = (antiplayer,player)
    end
    return (aMistakes,bMistakes)
end

function winningOnBoard(N::I,board::VI,rem::VI)::Tuple{VI,VI}
    wpos = fill(0,N)
    wval = fill(0,N)
    for i in 1:N
        if board[i] < 0; continue; end
        if i < N && board[i+1] < 0 && board[i] < N && rem[board[i]+1] > 0; wpos[i+1] = 1; wval[board[i]+1] = 1; end
        if i < N && board[i+1] < 0 && board[i] > 1 && board[i] <= N && rem[board[i]-1] > 0; wpos[i+1] = 1; wval[board[i]-1] = 1; end
        if i > 1 && board[i-1] < 0 && board[i] < N && rem[board[i]+1] > 0; wpos[i-1] = 1; wval[board[i]+1] = 1; end
        if i > 1 && board[i-1] < 0 && board[i] > 1 && board[i] <= N && rem[board[i]-1] > 0; wpos[i-1] = 1; wval[board[i]-1] = 1; end
    end
    return ([x for x in 1:N if wpos[x] == 1],[x for x in 1:N if wval[x] == 1])
end

function checkWinning(N::I,board::VI)::Bool
    for i in 1:N-1; if abs(board[i]-board[i+1]) == 1; return true; end; end
    return false
end

function encodeBoardRem(N::I,board::VI,boardFlag::Bool=true)::Tuple{I,VI,I,VI,VI}
    runs::VI = []
    v = 0
    for i in 1:N
        if boardFlag
            if board[i] > 0 && v > 0; push!(runs,v); v = 0
            elseif board[i] < 0; v += 1
            end
        else
            if board[i] < 0 && v > 0; push!(runs,v); v = 0
            elseif board[i] > 0; v += 1
            end
        end
    end
    if v > 0; push!(runs,v); end
    sort!(runs,rev=true)
    nn = sum(runs) + length(runs)-1
    vv = (1 << nn) - 1; p = 0
    for r in runs[1:end-1]; vv ⊻= (1 << (p+r)); p += r+1; end
    p = 1; lr = 100; moves::VI = []
    for r in runs
        if r == lr; p += r+1; continue; end
        lr = r
        for i in 1:(r+1)>>1; push!(moves,p+i-1); end
        p += r+1
    end

    newboard = boardFlag ? fill(100,nn) : fill(-1,nn)
    p = 1
    for r in runs
        for i in 1:r; newboard[p] = boardFlag ? -1 : 1; p += 1; end; p += 1
    end
    return (vv,moves,nn,newboard,runs)
end

function trymoves(marr::VI,varr::VI,player::Char,antiplayer::Char,N::I,stdBoard::VI,stdRem::VI,d::Dict{gameState,Char})::Char
    win = false
    for mm in marr
        for vv in varr
            stdBoard[mm] = vv
            stdRem[vv] = -1
            lwin = solvepos(N,antiplayer,stdBoard,stdRem,d)
            stdRem[vv] = 1
            stdBoard[mm] = -1
            if lwin == player; win = true; break; end
        end
        if win; break; end
    end
    return win ? player : antiplayer
end

function solvepos(N::I,player::Char,board::VI,rem::VI,d::Dict{gameState,Char})::Char
    antiplayer = player == 'A' ? 'B' : 'A'
    if 1 ∉ rem; return checkWinning(N,board) ? 'A' : 'B'; end
    if checkWinning(N,board); return 'A'; end
    (wpos,wval) = winningOnBoard(N,board,rem)
    #if length(wpos) > 1 && length(wval) > 1; return 'A'; end
    if length(wpos) > 0
        if player == 'A'; return 'A'; end
        marr = [x for x in 1:N if board[x] < 0]
        varr = [x for x in 1:N if rem[x] > 0]
        v1 = trymoves(wpos,varr,'B','A',N,board,rem,d)
        if v1 == 'B'; return 'B'; end
        v2 = trymoves(marr,wval,'B','A',N,board,rem,d)
        return v2
    end
    (encb,marr,n2,stdBoard,runsa) = encodeBoardRem(N,board,true)
    (encr,varr,n3,stdRem,runsb)   = encodeBoardRem(N,rem,false)
    if n2 < n3; for i in n2+1:n3; push!(stdBoard,100); end; end
    if n3 < n2; for i in n3+1:n2; push!(stdRem,-1); end; end
    if !haskey(d,(encb,encr,player))
        if runsa[1] == 1 || runsb[1] == 1
            d[(encb,encr,player)] = 'B'
        elseif player == 'A' && encb & 0x7 == 7 && encr & 0x7 == 7
            d[(encb,encr,player)] = 'A'
        else
            #print("DBG: marr:$marr varr:$varr player:$player\n")
            d[(encb,encr,player)] = trymoves(marr,varr,player,antiplayer,max(n2,n3),stdBoard,stdRem,d)
        end
    end
    return d[(encb,encr,player)]
end

function test(ntc::I,Nmin::I,Nmax::I)
    d = Dict{gameState,Char}()
    pass = 0
    for ttt in 1:ntc
        N = rand(Nmin:Nmax)
        M = collect(1:N)
        C = collect(1:N)
        for i in 1:N-1
            j = rand(i+1:N)
            M[i],M[j] = M[j],M[i]
            j = rand(i+1:N)
            C[i],C[j] = C[j],C[i]
        end
        if ttt % 100 == 0; print("ttt:$ttt\n"); end
        solve(N,M,C,d)
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = gi()
    d = Dict{gameState,Char}()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        M::VI = fill(0,N)
        C::VI = fill(0,N)
        for i in 1:N
            M[i],C[i] = gis()
        end
        ans = solve(N,M,C,d)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()
#test(10000,49,50)


#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

