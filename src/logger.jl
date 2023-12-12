"""
    close_polyglot_logger(logger::TeeLogger)

* `logger`: TeeLogger with console and file logs
"""
function close_polyglot_logger(logger::TeeLogger)
    # TODO use some API
    log_io_stream = logger.loggers[2].logger.stream
    if isopen(log_io_stream)
        close(log_io_stream)
    end
    return nothing
end

"""
remove_log_file_path_on_logger_creation(path::AbstractString)

* `path`: Path to log file to be removed
"""
function remove_log_file_path_on_logger_creation(path::AbstractString)
    try
        if global_logger() isa TeeLogger
            close_polyglot_logger(global_logger())
            rm(path; force = true)
        end
    catch err
        if isa(err, Base.IOError)
            error("Cannot create a logger if $path still has IOStreams open.")
        end
    end
    return nothing
end

function choose_level_to_print(level::LogLevel, level_dict::Dict)
    level_string = get_level_string(level)

    if level_string == "Debug Level"
        return string(level_dict[level_string], " ", level.level)
    else
        return string(level_dict[level_string])
    end
end

function choose_terminal_io(level::LogLevel)
    if level >= Logging.Error
        return stderr
    else
        return stdout
    end
end

function get_level_string(level::LogLevel)
    return if level == SUCCESS_LEVEL
        "Success"
    elseif level == FATAL_ERROR_LEVEL
        "Fatal Error"
    elseif Logging.Debug < level < Logging.Info
        "Debug Level"
    else
        string(level)
    end
end

function get_tag_brackets(level::LogLevel, bracket_dict::Dict)
    level_string = get_level_string(level)
    bracket = bracket_dict[level_string]

    if !isempty(bracket)
        return bracket
    else
        return ["", ""]
    end
end

function get_separator(level::LogLevel, close_bracket::AbstractString, separator_dict::Dict)
    level_string = get_level_string(level)
    separator = separator_dict[level_string]

    if level_string == "" && close_bracket == ""
        return ""
    elseif !isempty(separator)
        return separator
    else
        return " "
    end
end

"""
    create_polyglot_logger(
        log_file_path::AbstractString; 
        min_level_console::Logging.LogLevel, 
        min_level_file::Logging.LogLevel,
        brackets,
        level_dict,
        color_dict,
        background_reverse_dict
    )

* `log_file_path`: Log file path
* `min_level_console`: Minimum level shown in console. Default: Logging.Info
* `min_level_file`: Minimum level shown in file. Default: Logging.Debug
* `append_log`: Boolean input to append logs in existing log file (if true) or overwrite/create log file (if false). Default is false
* `bracket_dict`: select the brackets for each LogLevel. As default,
    Dict(
        "Debug Level" => ["[", "]"],
        "Debug" => ["[", "]"],
        "Info" => ["[", "]"],
        "Success" => ["[", "]"],
        "Warn" => ["[", "]"],
        "Error" => ["[", "]"],
        "Fatal Error" => ["[", "]"],
    )
* `level_dict`: Dictionary to select logging tag to print. Default: 
    Dict(
        "Debug Level" => "Debug Level",
        "Debug" => "Debug",
        "Info" => "Info",
        "Success" => "Success",
        "Warn" => "Warn",
        "Error" => "Error"
    )
* `color_dict`: Dictionary to select logging tag color to print. Default: 
    Dict(
        "Debug Level" => :cyan,
        "Debug" => :cyan,
        "Info" => :cyan,
        "Success" => :green,
        "Warn" => :yellow,
        "Error" => :red,
        "Fatal Error" => :red
    )
* `background_reverse_dict`: Dictionary to select logging tag background to print. Default: 
    Dict(
        "Debug Level" => false,
        "Debug" => false,
        "Info" => false,
        "Success" => false,
        "Warn" => false,
        "Error" => false,
        "Fatal Error" => true
    )
* `separator_dict`: Dictionary to select logging tag separator to print. Default: 
    Dict(
        "Debug Level" => " ",
        "Debug" => " ",
        "Info" => " ",
        "Warn" => " ",
        "Error" => " ",
        "Fatal Error" => " "
    )
"""
function create_polyglot_logger(
    log_file_path::AbstractString;
    min_level_console::Logging.LogLevel = Logging.Info,
    min_level_file::Logging.LogLevel = Logging.Debug,
    append_log::Bool = false,
    bracket_dict::Dict = Dict(
        "Debug Level" => ["[", "]"],
        "Debug" => ["[", "]"],
        "Info" => ["[", "]"],
        "Success" => ["[", "]"],
        "Warn" => ["[", "]"],
        "Error" => ["[", "]"],
        "Fatal Error" => ["[", "]"],
    ),
    level_dict::Dict = Dict(
        "Debug Level" => "Debug Level",
        "Debug" => "Debug",
        "Info" => "Info",
        "Success" => "Success",
        "Warn" => "Warn",
        "Error" => "Error",
        "Fatal Error" => "Fatal Error",
    ),
    color_dict::Dict{String, Symbol} = Dict(
        "Debug Level" => :cyan,
        "Debug" => :cyan,
        "Info" => :cyan,
        "Success" => :green,
        "Warn" => :yellow,
        "Error" => :red,
        "Fatal Error" => :red,
    ),
    background_reverse_dict::Dict{String, Bool} = Dict(
        "Debug Level" => false,
        "Debug" => false,
        "Info" => false,
        "Success" => false,
        "Warn" => false,
        "Error" => false,
        "Fatal Error" => true,
    ),
    separator_dict::Dict = Dict(
        "Debug Level" => " ",
        "Debug" => " ",
        "Info" => " ",
        "Warn" => " ",
        "Error" => " ",
        "Fatal Error" => " ",
    ),
)
    if !append_log
        remove_log_file_path_on_logger_creation(log_file_path)
    end

    # console logger only min_level_console and up
    format_logger_console = FormatLogger() do io, args
        level_to_print = choose_level_to_print(args.level, level_dict)
        open_bracket, close_bracket = get_tag_brackets(args.level, bracket_dict)
        separator = get_separator(args.level, close_bracket, separator_dict)
        io = choose_terminal_io(args.level)

        print(io, open_bracket)
        print_colored(io, level_to_print, args.level, color_dict, background_reverse_dict)
        println(io, close_bracket, separator, args.message)
    end

    console_logger = MinLevelLogger(format_logger_console, min_level_console)

    # file logger logs min_level_file and up
    format_logger_file = FormatLogger(log_file_path; append = true) do io, args
        level_to_print = choose_level_to_print(args.level, level_dict)
        open_bracket, close_bracket = get_tag_brackets(args.level, bracket_dict)
        separator = get_separator(args.level, close_bracket, separator_dict)

        println(
            io,
            now(),
            " ",
            open_bracket,
            level_to_print,
            close_bracket,
            separator,
            args.message,
        )
    end
    file_logger = MinLevelLogger(format_logger_file, min_level_file)
    logger = TeeLogger(
        console_logger,
        file_logger,
    )
    global_logger(logger)
    return logger
end

function print_colored(
    io::IO,
    str::AbstractString,
    level::Logging.LogLevel,
    color_dict::Dict{String, Symbol},
    reverse_dict::Dict{String, Bool},
)
    level_string = get_level_string(level)

    color = color_dict[level_string]
    reverse = reverse_dict[level_string]

    print_colored(io, str; color = color, reverse = reverse)

    return nothing
end

function print_colored(
    io::IO,
    str::AbstractString;
    color::Symbol = :normal,
    reverse::Bool = false,
)
    if color == :normal && reverse == false
        print(io, str)
    else
        printstyled(io, str; color = color, reverse = reverse)
    end
    return nothing
end
