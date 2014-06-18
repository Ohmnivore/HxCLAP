Haxe port of CLAP, a C++ command line argument parser:
[CLAP website](http://www.cs.bgu.ac.il/~cgproj/CLAP/)

# Work in progress

My goal with this port is to create a cross-platform solution that isn't exclusively destined for console programs. For example, it must be able to parse from an input string, not just from Sys.args(). I plan to use it for a HaxeFlixel game where I will implement a shell interface.

### TODO:
* Finish porting sub-classes of CmdArgTypedList
* Document everything with comments
* Event system for feedback/messages instead of "trace"
* Correct feedback formatting
* Write tests
