import Pkg
Pkg.instantiate()

using JuliaFormatter

import Pkg
Pkg.instantiate()

using JuliaFormatter

function apply_formatter()
    # 3 times to converge formatting is an heuristic
    println("Formatting src and test folders")
    for _ in 1:2
        format(joinpath(dirname(@__DIR__), "src"))
        format(joinpath(dirname(@__DIR__), "test"))
    end
    formatted_src = format(joinpath(dirname(@__DIR__), "src"))
    formatted_test = format(joinpath(dirname(@__DIR__), "test"))
    println("src folder formatted: $formatted_src")
    println("test folder formatted: $formatted_test")
    return nothing
end

apply_formatter()