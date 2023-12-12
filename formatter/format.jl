import Pkg
Pkg.instantiate()

using JuliaFormatter

format(dirname(@__DIR__); verbose = true)
