Haxe port of CLAP, a C++ command line argument parser:
[CLAP website](http://www.cs.bgu.ac.il/~cgproj/CLAP/)

`haxelib install HxCLAP`

My goal with this port is to create a cross-platform solution that isn't exclusively destined for console programs. For example, it must be able to parse from an input string, not just from Sys.args(). I plan to use it for a HaxeFlixel game where I will implement a shell interface.

For usage, the best thing would be to check out the docs at the CLAP website, the API is very similar. However, note that this version got rid of delimiters, instead a space character is used as a delimiter. For example: test -s arg1 arg2 arg3 arg4 would be appropriately parsed by a CmdLine object using a CmdArgStrList.

### Quick examples:
    var test_bool:CmdArgBool = new CmdArgBool(
			"b",
			"bool",
			"Simple boolean flag",
			(E_CmdArgSyntax.isOPT) //Flag is set to optional
			);
    
    var test_string_list:CmdTargStrList = new CmdTargStrList(
			"copies",
			"filename",
			"tests CmdTargStrList class",
			(E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
			1,
			100
			);
    var testCmd:CmdLine = new CmdLine("Test", [test_bool, test_string_list]);
    testCmd.parse(["filename1", "filename2", "filename3", "-b"]);
    trace(test_bool.value); //traces true
    trace(test_string_list2.list); //traces ["filename1", "filename2", "filename3"]

These examples are quite basic, HxCLAP can power an application that requires much more advanced parsing.
Check out src/Main.hx for examples.

### Examples of possible parsed inputs (pure gibberish btw):
* rm readme license test.c -d
* ping localhost -n 1000
* mult -n 3.93 3.56
* mail message.md message2.md message3.md message4.md -destination ohmnivore@canada.ca
* cp file1 file2 file3 -d file_1 file_2 file_3 -k -j 4
* heck, you get the idea

### TODO:
* Document CmdArg subclasses
* Write tests that verify if invalid switch arguments are handled correctly (pretty sure they are, just doing it for the record)
