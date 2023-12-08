# Direct logs
function debug(msg::AbstractString; level::Integer = -1000)
    @assert Logging.Debug <= Logging.LogLevel(level) < Logging.Info
    @logmsg Logging.LogLevel(level) msg
    return nothing
end

function info(msg::AbstractString)
    @info msg
    return nothing
end

function warn(msg::AbstractString)
    @warn msg
    return nothing
end

function non_fatal_error(msg::AbstractString)
    @error msg
    return nothing
end

function fatal_error(
    msg::AbstractString;
    exception::Exception = ErrorException("Fatal error"),
)
    logger = Logging.global_logger()
    close_polyglot_logger(logger)

    @logmsg FatalErrorLevel msg
    throw(exception)
    return nothing
end

# logs via code and language
function get_raw_message(dict::Dict, code::Integer, lang::AbstractString)
    if haskey(dict, code) # Code could be an Int
        langs_dict = dict[code]
        if haskey(langs_dict, lang)
            return langs_dict[lang]
        else
            error("Message of code $code does not have the language $lang.")
        end
    elseif haskey(dict, "$code") # Code could also be a string that parses to Int
        langs_dict = dict[code]
        if haskey(langs_dict, lang)
            return langs_dict[lang]
        else
            error("Message of code $code does not have the language $lang.")
        end
    else
        error("Message of code $code does not exist.")
    end
end

function prepare_msg(code::Integer, replacements...)
    dict = get_dict()
    lang = get_language()
    raw_message = get_raw_message(dict, code, lang)
    treated_message = treat_message(raw_message, replacements...)
    return treated_message
end

function treat_message(raw_message::AbstractString, replacements...)
    splitted_message = split(raw_message, "@@@")
    num_correct_replacements = length(splitted_message) - 1
    # If the is no @@@ in the message we can return the raw_message
    if num_correct_replacements == 0
        return raw_message
    end
    if num_correct_replacements != length(replacements)
        error("Invalid interpolation, log should have $num_correct_replacements args.")
    end
    treated_message = ""
    for i in 1:num_correct_replacements
        treated_message *= string(splitted_message[i], replacements[i])
    end
    treated_message *= splitted_message[end]
    return treated_message
end

function debug(code::Integer, replacements...; level::Integer = -1000)
    msg = prepare_msg(code, replacements...)
    debug(msg; level)
    return nothing
end

function info(code::Integer, replacements...)
    msg = prepare_msg(code, replacements...)
    info(msg)
    return nothing
end

function warn(code::Integer, replacements...)
    msg = prepare_msg(code, replacements...)
    warn(msg)
    return nothing
end

function non_fatal_error(code::Integer, replacements...)
    msg = prepare_msg(code, replacements...)
    non_fatal_error(msg)
    return nothing
end

function fatal_error(
    code::Integer,
    replacements...;
    exception::Exception = ErrorException("Fatal error"),
)
    msg = prepare_msg(code, replacements...)
    fatal_error(msg; exception = exception)
    return nothing
end
