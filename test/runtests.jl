import LoggingPolyglot

using Aqua
using Test

function testall()
    @testset "Aqua.jl" begin
        Aqua.test_all(LoggingPolyglot)
    end

    for file in readdir(@__DIR__)
        if file in ["runtests.jl"]
            continue
        elseif !endswith(file, ".jl")
            continue
        end
        @testset "$(file)" begin
            include(file)
        end
    end
end

testall()
