module Polyglot

using LoggingExtras
using Dates
using TOML

const POLYGLOT_LANG = String["en"]
const POLYGLOT_LOG_DICT = [Dict()]

include("constants.jl")
include("logger.jl")
include("logs.jl")

end
