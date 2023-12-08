const FatalErrorLevel = Logging.LogLevel(3000)

function set_language(language::AbstractString)
    POLYGLOT_LANGUAGE[1] = language
    return language
end

function get_language()
    return POLYGLOT_LANGUAGE[1]
end

function is_valid_dict(dict::Dict)::Bool
    if isempty(dict)
        println("Dictionary of codes and languages is empty.")
        return false
    else
        codes = dict |> keys |> collect
        for code in codes
            if isa(code, Int)
                continue
            end
            if isa(code, String) && !isnothing(tryparse(Int, code))
                continue
            end
            println(
                "Dictionary of codes and languages has a code that is not an Int representation.",
            )
            return false
        end
        for v in values(dict)
            if !isa(v, Dict)
                println("Dictionary of codes and languages has invalid structure, the ")
            end
            for ks in keys(v)
                if !isa(ks, String)
                    println(
                        "Dictionary of codes and languages has a language that is not a String.",
                    )
                    return false
                elseif isempty(ks)
                    println(
                        "Dictionary of codes and languages has a language that is an empty String.",
                    )
                    return false
                end
            end
        end
    end
    return true
end

function set_dict(dict::Dict)
    if !is_valid_dict(dict)
        error("The dictionary of codes and language is invalid.")
    end
    POLYGLOT_LOG_DICT[1] = dict
    return dict
end

function set_dict(toml_dict_path::AbstractString)
    dict = toml_file_to_dict(toml_dict_path)
    if !is_valid_dict(dict)
        error("The dictionary of codes and language is invalid.")
    end
    POLYGLOT_LOG_DICT[1] = dict
    return dict
end

function get_dict()
    return POLYGLOT_LOG_DICT[1]
end

function toml_file_to_dict(path::AbstractString)
    @assert isfile(path)
    toml_dict = TOML.parsefile(path)
    new_dict = Dict{Int, Dict{String, String}}()
    for (k, v) in toml_dict
        new_key = parse(Int, k)
        new_dict[new_key] = Dict{String, String}()
        for (ksub, vsub) in toml_dict[k]
            new_dict[new_key][string(ksub)] = string(vsub)
        end
    end
    return new_dict
end
