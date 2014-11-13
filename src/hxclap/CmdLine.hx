package hxclap;

import hxclap.CmdElem;
import hxclap.CmdArg.E_CmdArgSyntax;

import hxclap.CmdArg.CmdArgBool;
import hxclap.CmdArg.CmdArgInt;
import hxclap.CmdArg.CmdArgFloat;
import hxclap.CmdArg.CmdArgStr;
import hxclap.CmdArg.CmdArgChar;

import hxclap.CmdArg.CmdArgIntList;
import hxclap.CmdArg.CmdArgFloatList;
import hxclap.CmdArg.CmdArgStrList;
import hxclap.CmdArg.CmdArgCharList;

import hxclap.CmdTarget.CmdTargStrList;
import hxclap.CmdTarget.CmdTargStr;

/**
 * ...
 * @author Ohmnivore
 */

 /**
 * The core
 */
class CmdLine
{
	private var _cmdList:Array<CmdElem>;
	private var _targList:Array<CmdTarget>;
	private var _progName:String;
	private var _maxLength:Int;
	
	//Callbacks
	/**
	 * Called when the parser can't find the specified flag
	 */
	public var switchNotFound:String->Void;
	/**
	 * Called when a required flag wasn't passed to the parser
	 */
	public var missingRequiredSwitch:CmdElem->Void;
	
	/**
	 * Called when a flag's argument couldn't be parsed
	 */
	public var argNotFound:CmdElem->Void;
	/**
	 * Called when a flag doesn't receive its required argument
	 */
	public var missingRequiredArg:CmdElem->Void;
	
	/**
	 * @param ProgName	The program's name - typically the application's name
	 * @param cmds		Flags available for this application
	 */
	public function new(progName:String, cmds:Array<CmdElem>) 
	{
		_progName = progName;
		_maxLength = 0;
		_cmdList = [];
		_targList = [];
		
		setUpDefaultCallbacks();
		
		for (cmd in cmds)
		{
			_cmdList.push(cmd);
			_maxLength = Std.int(Math.max(_maxLength, cmd.valueName.length));
			
			if (!cmd.isArg)
			{
				_targList.push(cast cmd);
			}
		}
	}
	
	/**
	 * Traces this function's usage using default trace()
	 */
	public function defaultTraceUsage():Void
	{
		var u:UsageInfo = usage();
		
		trace("Usage: " + u.name);
		
		for (cmd in u.args)
		{
			if (cmd.type < 6)
			{
				_traceSimple(cmd);
			}
			else
			{
				_traceList(cmd);
			}
		}
	}
	
	private function _traceSimple(cmd:ArgInfo):Void
	{
		var longName:String = cmd.longName;
		var shortName:String = cmd.shortName;
		var description:String = cmd.description;
		var expects:String = cmd.expects;
		
		if (cmd.isOPT)
		{
			longName = '[$longName]';
		}
		if (cmd.isVALOPT)
		{
			expects = '[$expects]';
		}
		
		if (cmd.type == ArgType.TARG_STRING)
			trace('$longName -> $description -> expects: $expects');
		else
			trace('-$longName (-$shortName) -> $description -> expects: $expects');
	}
	
	private function _traceList(cmd:ArgInfo):Void
	{
		var longName:String = cmd.longName;
		var shortName:String = cmd.shortName;
		var description:String = cmd.description;
		var expects:String = cmd.expects;
		
		if (cmd.isOPT)
		{
			longName = '[$longName]';
		}
		if (cmd.isVALOPT)
		{
			expects = '[$expects]';
		}
		
		if (cmd.type == ArgType.TARG_LIST_STRING)
			trace('$longName -> $description -> expects: $expects');
		else
			trace('-$longName (-$shortName) -> $description -> expects: $expects');
	}
	
	private function setUpDefaultCallbacks():Void
	{
		switchNotFound = HandleSwitchNotFound;
		missingRequiredSwitch = HandleMissingSwitch;
		
		argNotFound = HandleArgNotFound;
		missingRequiredArg = HandleMissingArg;
	}
	
	public function HandleSwitchNotFound(Switch:String):Void
	{
		trace("Warning: argument '" + Switch + "' looks strange, ignoring");
	}
	
	public function HandleMissingSwitch(Cmd:CmdElem):Void
	{
		if (Cmd.isArg)
			trace("Error: the switch -" + Cmd.keyword + " must be supplied");
		else
			trace("Error: the target " + Cmd.keyword + " must be supplied");
	}
	
	public function HandleArgNotFound(Cmd:CmdElem):Void
	{
		if (Cmd.isArg)
			trace("Error: switch -" + Cmd.keyword + " must take an argument");
		else
			trace("Error: target " + Cmd.keyword + " must take an argument");
	}
	
	public function HandleMissingArg(Cmd:CmdElem):Void
	{
		if (Cmd.isArg)
			trace("Error: the switch -" + Cmd.keyword + " must take a value");
		else
			trace("Error: the target " + Cmd.keyword + " must take a value");
	}
	
	/**
	 * Returns this program's arguments and name in a UsageInfo object.
	 * Iterate of that object's args array to retrieve useful info
	 */
	public function usage():UsageInfo
	{
		var u:UsageInfo = new UsageInfo(_progName);
		
		for (cmd in _cmdList)
		{
			if (!cmd.isHidden() && !cmd.isArg)
			{
				u.args.push(new ArgInfo(cmd));
			}
		}
		
		for (cmd in _cmdList)
		{
			if (!cmd.isHidden() && cmd.isArg)
			{
				u.args.push(new ArgInfo(cmd));
			}
		}
		
		return u;
	}
	
	/**
	 * This is probably the most essential function.
	 * @param argc		Amount of arguments you wish to pass to the parser
	 * @param argv		List of arguments to parse, ex: ["-test-arg", "1", "-B"]
	 */
	public function parse(argv:Array<String>):Void
	{
		var argc:Int = argv.length;
		var cmd:CmdElem;
		
		var i:Int = 0;
		for (t in _targList)
		{
			if (Std.is(t, CmdTargStrList))
			{
				var tl:CmdTargStrList = cast t;
				
				while(true)
				{
					var arg:String = argv[0];
					
					if (arg.charAt(0) == "-")
					{
						if (!tl.isValOpt() && tl.list.length == 0)
						{
							if (argNotFound != null)
							{
								argNotFound(tl);
							}
						}
						
						break;
					}
					else
					{
						tl.setFound();
						tl.list.push(arg);
						tl.setValFound();
						
						argv.shift();
					}
				}
				
				tl.validate();
			}
			else
			{
				var val:String = argv[i];
				
				if (val.charAt(0) == "-")
				{
					if (t.isValOpt())
						continue;
					else
					{
						if (argNotFound != null)
						{
							argNotFound(t);
						}
					}
				}
				
				t.setFound();
				if (!t.getValue(i, argc, argv))
				{
					if (argNotFound != null && !t.isValOpt())
					{
						argNotFound(t);
					}
				}
				else
				{
					t.setValFound();
				}
				argv.shift();
			}
		}
		
		i = 0;
		while (i < argv.length)
		{
			var arg:String = argv[i];
			var found:Bool = false;
			
			var i2:Int = 0;
			while ((i2 < _cmdList.length) && !found)
			{
				cmd = _cmdList[i2];
				
				var cmdWord:String = "";
				var cmdChar:String = "";
				
				cmdWord = "-" + cmd.keyword;
				cmdChar = "-" + cmd.optChar;
				
				if ((arg == cmdWord) || (arg == cmdChar))
				{
					cmd.setFound();
					
					if (!cmd.getValue(i, argc, argv))
					{
						if (argNotFound != null && !cmd.isValOpt())
						{
							argNotFound(cmd);
						}
					}
					else
					{
						cmd.setValFound();
						
						if (!Std.is(cmd, CmdArgBool))
							i++;
					}
					
					found = true;
				}
				
				i2++;
			}
			
			if (!found)
			{
				if (switchNotFound != null)
				{
					switchNotFound(arg);
				}
			}
			
			i++;
		}
		
		for (cmd2 in _cmdList)
		{
			if (!cmd2.isOpt()) // i.e required
			{
				if (!cmd2.isFound())
				{
					if (missingRequiredSwitch != null)
					{
						missingRequiredSwitch(cmd2);
					}
				}
			}
			
			if (cmd2.isFound() && !cmd2.isValOpt()) // i.e need value
			{
				if (!cmd2.isValFound())
				{
					if (missingRequiredArg != null)
					{
						missingRequiredArg(cmd2);
					}
				}
			}
		}
	}
}

class UsageInfo
{
	/**
	 * Program's name as passed when the CmdLine object was constructed
	 */
	public var name:String;
	/**
	 * List of all CmdArgs added to the CmdLine object that don't have the HIDDEN flag set to true
	 */
	public var args:Array<ArgInfo>;
	
	public function new(Name:String)
	{
		name = Name;
		args = [];
	}
}

class ArgInfo
{
	/**
	 * ex: test-arg
	 */
	public var longName:String;
	/**
	 * ex: t
	 */
	public var shortName:String;
	
	public var description:String;
	/**
	 * Describes what sort of argument is expected for this switch
	 */
	public var expects:String;
	/**
	 * Minimum amount of arguments to be passed for this switch.
	 * Only applies to list command arguments.
	 */
	public var min:Int = 0;
	/**
	 * Maximum amount of arguments to be passed for this switch.
	 * Only applies to list command arguments.
	 */
	public var max:Int = 100;
	/**
	 * The type of this argument, as defined in ArgType
	 */
	public var type:Int;
	
	/**
	 * Whether this argument is optional
	 */
	public var isOPT:Bool = false;
	/**
	 * Wether this argument is required
	 */
	public var isREQ:Bool = false;
	/**
	 * Wether an argument for this switch is optional
	 */
	public var isVALOPT:Bool = false;
	/**
	 * Wether an argument is required for this switch
	 */
	public var isVALREQ:Bool = false;
	
	public function new(Arg:CmdElem)
	{
		longName = Arg.keyword;
		shortName = Arg.optChar;
		description = Arg.description;
		expects = Arg.valueName;
		
		if ((Arg.syntaxFlags & E_CmdArgSyntax.isOPT) > 0)
		{
			isOPT = true;
		}
		if ((Arg.syntaxFlags & E_CmdArgSyntax.isREQ) > 0)
		{
			isREQ = true;
		}
		if ((Arg.syntaxFlags & E_CmdArgSyntax.isVALOPT) > 0)
		{
			isVALOPT = true;
		}
		if ((Arg.syntaxFlags & E_CmdArgSyntax.isVALREQ) > 0)
		{
			isVALREQ = true;
		}
		
		//Simple
		if (Std.is(Arg, CmdArgBool))
		{
			type = ArgType.ARG_BOOL;
		}
		if (Std.is(Arg, CmdArgInt))
		{
			type = ArgType.ARG_INT;
		}
		if (Std.is(Arg, CmdArgFloat))
		{
			type = ArgType.ARG_FLOAT;
		}
		if (Std.is(Arg, CmdArgStr))
		{
			type = ArgType.ARG_STRING;
		}
		if (Std.is(Arg, CmdArgChar))
		{
			type = ArgType.ARG_CHAR;
		}
		
		//Lists
		if (Std.is(Arg, CmdArgIntList))
		{
			type = ArgType.ARG_LIST_INT;
			initList(Arg);
		}
		if (Std.is(Arg, CmdArgFloatList))
		{
			type = ArgType.ARG_LIST_FLOAT;
			initList(Arg);
		}
		if (Std.is(Arg, CmdArgStrList))
		{
			type = ArgType.ARG_LIST_STRING;
			initList(Arg);
		}
		if (Std.is(Arg, CmdArgCharList))
		{
			type = ArgType.ARG_LIST_CHAR;
			initList(Arg);
		}
		
		//Other
		if (Std.is(Arg, CmdTargStr))
		{
			type = ArgType.TARG_STRING;
		}
		if (Std.is(Arg, CmdTargStrList))
		{
			type = ArgType.TARG_LIST_STRING;
			initList(Arg);
		}
	}
	
	private function initList(Arg:CmdElem):Void
	{
		min = Reflect.field(Arg, "_min");
		max = Reflect.field(Arg, "_max");
	}
}

class ArgType
{
	public static inline var ARG_BOOL:Int = 0;
	public static inline var ARG_INT:Int = 1;
	public static inline var ARG_FLOAT:Int = 2;
	public static inline var ARG_STRING:Int = 3;
	public static inline var ARG_CHAR:Int = 4;
	public static inline var TARG_STRING:Int = 5;
	
	public static inline var ARG_LIST_INT:Int = 6;
	public static inline var ARG_LIST_FLOAT:Int = 7;
	public static inline var ARG_LIST_STRING:Int = 8;
	public static inline var ARG_LIST_CHAR:Int = 9;
	
	public static inline var TARG_LIST_STRING:Int = 10;
}