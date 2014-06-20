Haxe port of CLAP, a C++ command line argument parser:
[CLAP website](http://www.cs.bgu.ac.il/~cgproj/CLAP/)

My goal with this port is to create a cross-platform solution that isn't exclusively destined for console programs. For example, it must be able to parse from an input string, not just from Sys.args(). I plan to use it for a HaxeFlixel game where I will implement a shell interface.

For usage, the best thing would be to check out the docs at the CLAP website, the API is exactly the same.

### Quick example:
    var test_bool:CmdArgBool = new CmdArgBool(
			"b",
			"bool",
			"Simple boolean flag",
			(E_CmdArgSyntax.isOPT) //Flag is set to optional
			);
    var testCmd:CmdLine = new CmdLine("Test", [test_bool]);
    testCmd.parse(1, ["-b"]);
    trace(test_bool._v); //traces true

This example was really basic, HxCLAP can power an application that requires much more advanced parsing.
Check out src/Main.hx for examples.

### TODO:
* Document CmdArg subclasses
* Write tests that verify if invalid switch arguments are handled correctly (pretty sure they are, just doing it for the record)
