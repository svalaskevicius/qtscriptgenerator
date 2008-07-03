Runs QtScript code from the command line.

USAGE
-----
qsexec
    Runs QtScript in interactive mode, i.e. presents a prompt and executes
    commands as given.
qsexec FILE [ARGS ...]
    Runs the script in FILE with the given command line arguments
    (see SCRIPT EXTENSIONS below).
qsexec -f FILE1 [FILE2 ...]
    Runs all the scripts FILE1 FILE2 ... consecutively sharing the same engine.

SCRIPT EXTENSIONS
-----------------
The qsexec tool adds some useful functionality to the global object:

- qs.system.os
  A string that specifies the operating system the script is run on
  (e.g. "linux", "windows", "mac").
- qs.script.args
  Array containing the strings given as [args ...] on the command line
  (single file mode only).
- qs.script.absoluteFilePath
  File system path (including the file name) of the script that is processed
  at the moment as a string.
- qs.script.absolutePath
  File system path (excluding the file name) of the script that is processed
  at the moment as a string.
- qs.script.importExtension(name)
  Lets the script resolve and load the script extension with the given name.
- qs.script.include(fileName)
  Dynamically loads and executes the script in the given file (relative to the
  currently processed file or absolute). Multiple includes of the same file
  result in only one execution of the file (only the first include triggers
  the execution).

NOTE
----
The qsexec tool doesn't import any script extensions (like qt.core) itself.
A script that needs a script extension has to load it via 
qs.script.importExtension("myextension");
