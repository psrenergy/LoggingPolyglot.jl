module TestLogs

using Test
import LoggingPolyglot

function test_direct_log_debug()
    log_debug_path = "debug.log"
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_debug_path)
    LoggingPolyglot.debug("test message")
    debug_on_file = readlines(log_debug_path)
    @test occursin("Debug", debug_on_file[1])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_debug_path; force = true)
    return nothing
end

function test_direct_log_info()
    log_info_path = "info.log"
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_info_path)
    LoggingPolyglot.info("test message")
    info_on_file = readlines(log_info_path)
    @test occursin("Info", info_on_file[1])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_info_path; force = true)
    return nothing
end

function test_direct_log_warn()
    log_warn_path = "warn.log"
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_warn_path)
    LoggingPolyglot.warn("test message")
    warn_on_file = readlines(log_warn_path)
    @test occursin("Warn", warn_on_file[1])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_warn_path; force = true)
    return nothing
end

function test_direct_log_error()
    log_error_path = "error.log"
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_error_path)
    LoggingPolyglot.non_fatal_error("test message")
    error_on_file = readlines(log_error_path)
    @test occursin("Error", error_on_file[1])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_error_path; force = true)
    return nothing
end

function test_different_logs_same_file()
    log_path = "test.log"
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    LoggingPolyglot.info("test message")
    LoggingPolyglot.warn("test message")
    logs_on_file = readlines(log_path)
    @test occursin("Info", logs_on_file[1])
    @test occursin("Warn", logs_on_file[2])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path; force = true)
    return nothing
end

function test_log_from_langs_dict()
    log_path = "langs.log"
    langs_dict = Dict(
        1 => Dict(
            "en" => "hi!",
            "pt" => "oi!",
        ),
        2 => Dict(
            "en" => "bye!",
            "pt" => "tchau!",
        ),
    )
    LoggingPolyglot.set_dict(langs_dict)
    LoggingPolyglot.set_language("pt")
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    LoggingPolyglot.info(1)
    logs_on_file = readlines(log_path)
    @test occursin("oi", logs_on_file[1])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path; force = true)
    return nothing
end

function test_log_from_langs_dict_inexistent_code()
    log_path = "langs.log"
    langs_dict = Dict(
        1 => Dict(
            "en" => "hi!",
            "pt" => "oi!",
        ),
        2 => Dict(
            "en" => "bye!",
            "pt" => "tchau!",
        ),
    )
    LoggingPolyglot.set_dict(langs_dict)
    LoggingPolyglot.set_language("pt")
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    @test_throws ErrorException LoggingPolyglot.info(3)
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path; force = true)
    return nothing
end

function test_log_from_langs_dict_debug_levels()
    log_path = "langs_debug_levels1.log"
    langs_dict = Dict(
        1 => Dict(
            "en" => "hi!",
            "pt" => "oi!",
        ),
        2 => Dict(
            "en" => "bye!",
            "pt" => "tchau!",
        ),
    )
    LoggingPolyglot.set_dict(langs_dict)
    LoggingPolyglot.set_language("pt")
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    LoggingPolyglot.debug(1; level = -1)
    logs_on_file = readlines(log_path)
    @test length(logs_on_file) == 1
    @test occursin("oi!", logs_on_file[1])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path; force = true)
    return nothing
end

function test_log_from_langs_dict_with_interpolation()
    log_path = "langs.log"
    langs_dict = Dict(
        1 => Dict(
            "en" => "Iteration @@@:",
            "pt" => "Iteração @@@:",
        ),
        2 => Dict(
            "en" => "The thermal plant @@@ of code @@@ has the an invalid capacity.",
            "pt" => "A usina térmica @@@ de código @@@ tem a capacidade inválida.",
        ),
    )
    LoggingPolyglot.set_dict(langs_dict)
    LoggingPolyglot.set_language("pt")
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    LoggingPolyglot.info(1, "10")
    LoggingPolyglot.info(2, "UTE1", "2")
    logs_on_file = readlines(log_path)
    @test occursin("Iteração 10", logs_on_file[1])
    @test occursin("UTE1", logs_on_file[2])
    @test occursin("2", logs_on_file[2])
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path; force = true)
    return nothing
end

function test_log_from_langs_dict_with_invalid_interpolation()
    log_path = "langs.log"
    langs_dict = Dict(
        1 => Dict(
            "en" => "Iteration @@@:",
            "pt" => "Iteração @@@:",
        ),
        2 => Dict(
            "en" => "The thermal plant @@@ of code @@@ has the an invalid capacity.",
            "pt" => "A usina térmica @@@ de código @@@ tem a capacidade inválida.",
        ),
    )
    LoggingPolyglot.set_dict(langs_dict)
    LoggingPolyglot.set_language("pt")
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    @test_throws ErrorException LoggingPolyglot.info(1, "10", "oi", "tchau")
    @test_throws ErrorException LoggingPolyglot.info(2, "UTE1")
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path; force = true)
    return nothing
end

function test_empty_brackets()
    brackets = Dict(
        "Debug Level" => ["[", "]"],
        "Debug" => ["[", "]"],
        "Info" => [],
        "Warn" => ["[", "]"],
        "Error" => ["[", "]"],
        "Fatal Error" => ["[", "]"],
    )
    level = Dict(
        "Debug Level" => "debug",
        "Debug" => "debug",
        "Info" => "",
        "Warn" => "warn",
        "Error" => "error",
        "Fatal Error" => "fatal",
    )

    logger_path = "brackets.log"
    logger = LoggingPolyglot.create_polyglot_logger(
        logger_path;
        brackets_dict = brackets,
        level_dict = level,
    )

    LoggingPolyglot.info("empty brackets for info")
    LoggingPolyglot.warn("brackets for warn")
    LoggingPolyglot.close_polyglot_logger(logger)
    rm(logger_path; force = true)
end

function runtests()
    for name in names(@__MODULE__; all = true)
        if startswith("$name", "test_")
            @testset "$(name)" begin
                getfield(@__MODULE__, name)()
            end
        end
    end
end

TestLogs.runtests()

end # module
