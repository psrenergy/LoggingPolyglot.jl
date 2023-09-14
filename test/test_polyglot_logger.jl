module TestPolyglot

using Test
import LoggingPolyglot

function test_create_and_close_polyglot_logger()
    log_path = "test_log.log"
    polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
    @test isfile(log_path)
    LoggingPolyglot.close_polyglot_logger(polyglot_logger)
    rm(log_path)
    return nothing
end

function test_create_two_polyglot_loggers_in_different_files()
    log_path1 = "test_log1.log"
    log_path2 = "test_log2.log"
    polyglot_logger1 = LoggingPolyglot.create_polyglot_logger(log_path1)
    polyglot_logger2 = LoggingPolyglot.create_polyglot_logger(log_path2)
    @test isfile(log_path1)
    @test isfile(log_path2)
    LoggingPolyglot.close_polyglot_logger(polyglot_logger1)
    LoggingPolyglot.close_polyglot_logger(polyglot_logger2)
    rm(log_path1)
    rm(log_path2)
    return nothing
end

function test_create_two_polyglot_loggers_in_the_same_file()
    log_path = "test_log.log"
    polyglot_logger1 = LoggingPolyglot.create_polyglot_logger(log_path)
    @test isfile(log_path)
    polyglot_logger2 = LoggingPolyglot.create_polyglot_logger(log_path)
    @test isfile(log_path)
    LoggingPolyglot.close_polyglot_logger(polyglot_logger1)
    LoggingPolyglot.close_polyglot_logger(polyglot_logger2)
    rm(log_path)
    return nothing
end

function test_append_log_in_the_same_file()
    log_path = "test_log.log"

    polyglot_logger1 = LoggingPolyglot.create_polyglot_logger(log_path)
    LoggingPolyglot.info("old log")
    LoggingPolyglot.close_polyglot_logger(polyglot_logger1)

    polyglot_logger2 = LoggingPolyglot.create_polyglot_logger(log_path; append_log = true)
    LoggingPolyglot.info("new log")
    LoggingPolyglot.close_polyglot_logger(polyglot_logger2)

    logs_on_file = readlines(log_path)
    @test occursin("old log", logs_on_file[1])
    @test occursin("new log", logs_on_file[2])

    rm(log_path)
    return nothing
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

TestPolyglot.runtests()

end # module
