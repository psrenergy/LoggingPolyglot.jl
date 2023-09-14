# LoggingPolyglot.jl

[build-img]: https://github.com/psrenergy/LoggingPolyglot.jl/workflows/CI/badge.svg?branch=master
[build-url]: https://github.com/psrenergy/LoggingPolyglot.jl/actions?query=workflow%3ACI

[codecov-img]: https://codecov.io/gh/psrenergy/LoggingPolyglot.jl/coverage.svg?branch=master
[codecov-url]: https://codecov.io/gh/psrenergy/LoggingPolyglot.jl?branch=master

# StateSpaceModels.jl

| **Build Status** | **Coverage** |
|:-----------------:|:-----------------:|
| [![Build Status][build-img]][build-url] | [![Codecov branch][codecov-img]][codecov-url] |

A minimal and opinionated way to deal with compositional loggers built with LoggingExtras.jl. 

The package also helps users to deal with logs in multiple languages.

## Basic usage

LoggingPolyglot will log messages to different locations.

```julia
import LoggingPolyglot

log_file = "my_application.log"
polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_file)

# Only goes to file
LoggingPolyglot.debug("debug message")

# Goes to file and console
LoggingPolyglot.info("info message")
LoggingPolyglot.warn("warn message")
LoggingPolyglot.non_fatal_error("error message")

# Goes to console and file and then runs exit(1) if the session is not iterative.
LoggingPolyglot.fatal_error("Application cannot continue")
```

## Log in differnt languages

LoggingPolyglot stores some constants that help users deal with logs in different languages.

```julia
log_path = "langs.log"
langs_dict = Dict(
    1 => Dict(
        "en" => "Hello!",
        "pt" => "Olá!",
    ),
    2 => Dict(
        "en" => "The file @@@ does not exist.",
        "pt" => "O arquivo @@@ não existe.",
    )
)
LoggingPolyglot.set_dict(langs_dict)
LoggingPolyglot.set_language("pt")
polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
# It will log the portuguese version "Olá!"
LoggingPolyglot.info(1)
# It will display the message "O arquivo file.txt não existe"
LoggingPolyglot.info(2, "file.txt")
```

One suggestion to store the codes ans messages for multiple languages is to store it on a TOML file. The function `LoggingPolyglot.set_dict` accepts the TOML path as input. 

Dictionary TOML:
```toml
[1]
"en" = "Hello!"
"pt" = "Olá!"

[2]
"en" = "The file @@@ does not exist."
"pt" = "O arquivo @@@ não existe."
```

Set dictionary from TOML:
```julia
log_path = "langs.log"
toml_dict_path = "example.toml"
LoggingPolyglot.set_dict(toml_dict_path)
LoggingPolyglot.set_language("pt")
polyglot_logger = LoggingPolyglot.create_polyglot_logger(log_path)
# It will log the portuguese version "Olá!"
LoggingPolyglot.info(1)
# It will display the message "O arquivo file.txt não existe"
LoggingPolyglot.info(2, "file.txt")
```

## Create logger

The arguments that can be passed using `LoggingPolyglot.create_polyglot_logger`:
* `log_file_path`: Log file path. This input must be passed
* `min_level_console`: Minimum level shown in console. Default: Logging.Info
* `min_level_file`: Minimum level shown in file. Default: Logging.Debug
* `append_log`: Boolean input to append logs in existing log file (if true) or overwrite/create log file (if false). Default is false
* `brackets_dict`: select the brackets for each LogLevel. As default,
```julia
brackets_dict = Dict(
    "Debug Level" => ["[", "]"],
    "Debug" => ["[", "]"],
    "Info" => ["[", "]"],
    "Warn" => ["[", "]"],
    "Error" => ["[", "]"],
    "Fatal Error" => ["[", "]"],
)
```
* `level_dict`: defined in order to change the tags. As default, 
```julia
level_dict = Dict(
    "Debug Level" => "Debug Level",
    "Debug" => "Debug",
    "Info" => "Info",
    "Warn" => "Warn",
    "Error" => "Error",
    "Fatal Error" => "Fatal Error"
)
```
* `color_dict`: one can customize the tag colors displayed in terminal using this dictionary. As default,
```julia
color_dict = Dict(
    "Debug Level" => :cyan,
    "Debug" => :cyan,
    "Info" => :cyan,
    "Warn" => :yellow,
    "Error" => :red,
    "Fatal Error" => :red
)
```
* `background_reverse_dict`: used to customize the background of a tag in terminal. As default, 
```julia
background_reverse_dict = Dict(
    "Debug Level" => false,
    "Debug" => false,
    "Info" => false,
    "Warn" => false,
    "Error" => false,
    "Fatal Error" => true
)
```

The next example shows how to print the tags in lowercase letters, with julia default string colors and background.
```julia
level_dict = Dict(
    "Debug Level" => "debug level",
    "Debug" => "debug",
    "Info" => "info",
    "Warn" => "warn",
    "Error" => "error",
    "Fatal Error" => "fatal error"
)
color_dict = Dict(
    "Debug Level" => :normal,
    "Debug" => :normal,
    "Info" => :normal,
    "Warn" => :normal,
    "Error" => :normal,
    "Fatal Error" => :normal
)
background_reverse_dict = Dict(
    "Debug Level" => false,
    "Debug" => false,
    "Info" => false,
    "Warn" => false,
    "Error" => false,
    "Fatal Error" => false
)

log_file = "my_application.log"
LoggingPolyglot.create_polyglot_logger(log_file; level_dict, color_dict, background_reverse_dict)
```

The next example shows how to remove the `info` tag
```julia
log_file = "my_application.log"
brackets_dict = Dict(
    "Debug Level" => ["[", "]"],
    "Debug" => ["[", "]"],
    "Info" => ["", ""],
    "Warn" => ["[", "]"],
    "Error" => ["[", "]"],
    "Fatal Error" => ["[", "]"],
)
level_dict = Dict(
    "Debug Level" => "Debug Level",
    "Debug" => "Debug",
    "Info" => "",
    "Warn" => "Warn",
    "Error" => "Error",
    "Fatal Error" => "Fatal Error",
)
LoggingPolyglot.create_polyglot_logger(log_file; brackets_dict, level_dict)
LoggingPolyglot.info("info msg")
LoggingPolyglot.warn("warn msg")
LoggingPolyglot.remove_log_file_path_on_logger_creation(log_file)
```
