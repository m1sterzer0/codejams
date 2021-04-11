
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

ispalindrome(n::I) = string(n) == reverse(string(n))
prework()::VI = [i*i for i in 1:10_000_000 if ispalindrome(i) && ispalindrome(i*i)]

## Patterns of zero free square roots (which are palindromes are)
## 1 digit: 3,2,1    2 digit: 11, 22        3 digit: 121, 212, 111
## 4 digit: 1111     5 digit: 11211, 11111  6 digit: 111111
## 7 digit: 1111111  8 digit: 11111111      9 digit: 111111111
function prework2()::Vector{BigInt}
    strs::Vector{String} = Vector{String}()
    ## We push a few to many on, but it doesn't matter
    push!(strs,"1"); push!(strs,"2"); push!(strs,"3")
    for z1 in 0:50
        push!(strs,"1"*"0"^z1*"1")
        push!(strs,"2"*"0"^z1*"2")
        push!(strs,"1"*"0"^z1*"1"*"0"^z1*"1")
        push!(strs,"1"*"0"^z1*"2"*"0"^z1*"1")
        push!(strs,"2"*"0"^z1*"1"*"0"^z1*"2")
        for z2 in 0:(50-z1)÷2
            push!(strs,"1"*"0"^z2*"1"*"0"^z1*"1"*"0"^z2*"1");
            push!(strs,"1"*"0"^z2*"1"*"0"^z1*"1"*"0"^z1*"1"*"0"^z2*"1")
            push!(strs,"1"*"0"^z2*"1"*"0"^z1*"2"*"0"^z1*"1"*"0"^z2*"1")
            for z3 in 0:(50-z1-2*z2)÷2
                push!(strs,"1"*"0"^z3*"1"*"0"^z2*"1"*"0"^z1*"1"*"0"^z2*"1"*"0"^z3*"1")
                push!(strs,"1"*"0"^z3*"1"*"0"^z2*"1"*"0"^z1*"1"*"0"^z1*"1"*"0"^z2*"1"*"0"^z3*"1")
                for z4 in 0:(50-z1-2*z2-2*z3)÷2
                    push!(strs,"1"*"0"^z4*"1"*"0"^z3*"1"*"0"^z2*"1"*"0"^z1*"1"*"0"^z2*"1"*"0"^z3*"1"*"0"^z4*"1")
                    push!(strs,"1"*"0"^z4*"1"*"0"^z3*"1"*"0"^z2*"1"*"0"^z1*"1"*"0"^z1*"1"*"0"^z2*"1"*"0"^z3*"1"*"0"^z4*"1")
                end
            end
        end
    end
    arr::Vector{BigInt} = []
    for s in strs; x = parse(BigInt,s); push!(arr,x*x); end
    sort!(arr); return arr
end

## searchsortedlast gives you the number of elements lessthan or equal to
## the search term
function solveSmall(A::BigInt,B::BigInt,arr::VI)
    a::I = Int64(A); b::I = Int64(B)
    return searchsortedlast(arr,b)-searchsortedlast(arr,a-1)
end

function solveLarge(A::BigInt,B::BigInt,arr::Vector{BigInt})
    return searchsortedlast(arr,BigInt(B))-searchsortedlast(arr,BigInt(A-1))
end

function gencase(Maxdig::I)
    M = BigInt(10)^rand(1:Maxdig)
    A = rand(BigInt(1):M)
    B = rand(BigInt(1):M)
    if A > B; (A,B) = (B,A); end
    return (A,B)
end

function test(ntc::I,Maxdig::I,check::Bool=true)
    arr::VI = prework()
    arr2::Vector{BigInt} = prework2()
    pass = 0
    for ttt in 1:ntc
        (A,B) = gencase(Maxdig)
        ans2 = solveLarge(A,B,arr2)
        if check
            ans1 = solveSmall(A,B,arr)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(A,B,arr)
                ans2 = solveLarge(A,B,arr2)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    arr::VI = prework()
    arr2::Vector{BigInt} = prework2()

    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(BigInt,x) for x in gss()]
        ans = solveSmall(A,B,arr)
        #ans = solveLarge(A,B,arr2)
        print("$ans\n")
    end
end


Random.seed!(8675309)
main()
#test(1000,14)
#test(1000,100,false)

