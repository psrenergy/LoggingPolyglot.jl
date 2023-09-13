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
remove_log_file_path_on_logger_creation(log_file_path::String)

* `log_file_path`: Remove log file in path log_file_path
"""
function remove_log_file_path_on_logger_creation(log_file_path::String)
    try
        if global_logger() isa TeeLogger
            close_polyglot_logger(global_logger())
            rm(log_file_path; force = true)
        end
    catch err
        if isa(err, Base.IOError)
            error("Cannot create a logger if $log_file_path still has IOStreams open.")
        end
    end
    return nothing
end

function choose_level_to_print(level::LogLevel, level_dict::Dict)
    level_str = get_level_string(level)
    if level_str == "Debug Level"
        return string(level_dict[level_str], " ", level.level)
    else
        return string(level_dict[level_str])
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
    if Logging.Info <= level <= Logging.Error || level == Logging.Debug
        return string(level)
    elseif Logging.Debug < level < Logging.Info
        return "Debug Level"
    elseif level == FatalErrorLevel
        return "Fatal Error"
    end
end

function get_tag_brackets(level::LogLevel, brackets_dict::Dict)
    level_str = get_level_string(level)
    tag_brackets = brackets_dict[level_str]
    # If brackets are empty return empty strings
    if !isempty(tag_brackets)
        return tag_brackets
    else
        return ["", ""]
    end
end

function treat_empty_tag(level_to_print::String, close_bracket::String)
    if level_to_print == "" && close_bracket == ""
        return ""
    else
        return " "
    end
end

"""
    create_polyglot_logger(
        log_file_path::String; 
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
* `brackets_dict`: select the brackets for each LogLevel. As default,
    Dict(
        "Debug Level" => ["[", "]"],
        "Debug" => ["[", "]"],
        "Info" => ["[", "]"],
        "Warn" => ["[", "]"],
        "Error" => ["[", "]"],
        "Fatal Error" => ["[", "]"],
    )
* `level_dict`: Dictionary to select logging tag to print. Default: 
    Dict(
        "Debug Level" => "Debug Level",
        "Debug" => "Debug",
        "Info" => "Info",
        "Warn" => "Warn",
        "Error" => "Error"
    )
* `color_dict`: Dictionary to select logging tag color to print. Default: 
    Dict(
        "Debug Level" => :cyan,
        "Debug" => :cyan,
        "Info" => :cyan,
        "Warn" => :yellow,
        "Error" => :red,
        "Fatal Error" => :red
    )
* `background_reverse_dict`: Dictionary to select logging tag background to print. Default: 
    Dict(
        "Debug Level" => false,
        "Debug" => false,
        "Info" => false,
        "Warn" => false,
        "Error" => false,
        "Fatal Error" => true
    )
"""
function create_polyglot_logger(
    log_file_path::String;
    min_level_console::Logging.LogLevel = Logging.Info,
    min_level_file::Logging.LogLevel = Logging.Debug,
    append_log::Bool = false,
    brackets_dict::Dict = Dict(
        "Debug Level" => ["[", "]"],
        "Debug" => ["[", "]"],
        "Info" => ["[", "]"],
        "Warn" => ["[", "]"],
        "Error" => ["[", "]"],
        "Fatal Error" => ["[", "]"],
    ),
    level_dict::Dict = Dict(
        "Debug Level" => "Debug Level",
        "Debug" => "Debug",
        "Info" => "Info",
        "Warn" => "Warn",
        "Error" => "Error",
        "Fatal Error" => "Fatal Error",
    ),
    color_dict::Dict{String, Symbol} = Dict(
        "Debug Level" => :cyan,
        "Debug" => :cyan,
        "Info" => :cyan,
        "Warn" => :yellow,
        "Error" => :red,
        "Fatal Error" => :red,
    ),
    background_reverse_dict::Dict{String, Bool} = Dict(
        "Debug Level" => false,
        "Debug" => false,
        "Info" => false,
        "Warn" => false,
        "Error" => false,
        "Fatal Error" => true,
    ),
)
    if !append_log
        remove_log_file_path_on_logger_creation(log_file_path)
    end

    # Console logger only min_level_console and up
    format_logger_console = FormatLogger() do io, args
        level_to_print = choose_level_to_print(args.level, level_dict)
        open_bracket, close_bracket = get_tag_brackets(args.level, brackets_dict)
        space_before_msg = treat_empty_tag(level_to_print, close_bracket)
        io = choose_terminal_io(args.level) # needed to use Polyglot in MD Studio. It takes stderr as error and stdout as non error log
        print(io, open_bracket)
        print_colored(io, level_to_print, args.level, color_dict, background_reverse_dict)
        println(io, close_bracket, space_before_msg, args.message)
    end
    console_logger = MinLevelLogger(format_logger_console, min_level_console)

    # File logger logs min_level_file and up
    format_logger_file = FormatLogger(log_file_path; append = true) do io, args
        level_to_print = choose_level_to_print(args.level, level_dict)
        open_bracket, close_bracket = get_tag_brackets(args.level, brackets_dict)
        space_before_msg = treat_empty_tag(level_to_print, close_bracket)
        println(
            io,
            now(),
            " ",
            open_bracket,
            level_to_print,
            close_bracket,
            space_before_msg,
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
    str::String,
    level::Logging.LogLevel,
    color_dict::Dict{String, Symbol},
    reverse_dict::Dict{String, Bool},
)
    level_str = get_level_string(level)

    color = color_dict[level_str]
    reverse = reverse_dict[level_str]

    print_colored(io, str; color = color, reverse = reverse)
    return nothing
end

function print_colored(io::IO, str::String; color::Symbol = :normal, reverse::Bool = false)
    if color == :normal && reverse == false
        print(io, str) # MD Studio doesn't support colors and even printstyled with color = :normal and reverse = false doesn't work
    else
        printstyled(io, str; color = color, reverse = reverse)
    end
    return nothing
end
