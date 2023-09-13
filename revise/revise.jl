import Pkg
Pkg.instantiate()

using Revise

dir_path = dirname(@__DIR__)

Pkg.activate(dir_path)
Pkg.instantiate()

using Polyglot

@info("""
Polyglot
""")
