import LoggingPolyglot

using Aqua
using Test

function testall()
@testset "Aqua.jl" begin
    @testset "Ambiguities" begin
        Aqua.test_ambiguities(LoggingPolyglot, recursive = false)
    end
    Aqua.test_all(LoggingPolyglot, ambiguities = false)
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