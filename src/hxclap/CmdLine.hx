package hxclap;

/**
 * ...
 * @author Ohmnivore
 */
class CmdLine
{
	public var _cmdList:Array<CmdArg>;
	public var _progName:String;
	public var _maxLength:Int;
	
	public function new(progName:String, cmds:Array<CmdArg>) 
	{
		_progName = progName;
		_maxLength = 0;
		_cmdList = [];
		
		for (cmd in cmds)
		{
			_cmdList.push(cmd);
			_maxLength = Std.int(Math.max(_maxLength, cmd._valueName.length));
		}
	}
	
	public function usage():Void
	{
		trace("\n" + "Usage : " + _progName);
		
		for (cmd in _cmdList)
		{
			if (!cmd.isHidden())
			{
				var to_trace:String = " ";
				if (cmd.isOpt())
				{
					to_trace += "[";
				}
				to_trace += "-" + cmd.getKeyword();
				if (cmd.isValOpt())
				{
					to_trace += " " + cmd.getValueName();
				}
				if (cmd.isOpt())
				{
					to_trace += "]";
				}
				trace(to_trace);
			}
		}
		
		trace("\nWhere:\n");
		
		for (cmd2 in _cmdList)
		{
			if (!cmd2.isHidden())
			{
				if (!cmd2.isValOpt())
				{
					trace(cmd2.getValueName());
				}
				else
				{
					trace(cmd2.getKeyword());
				}
				
				trace(cmd2.getDescription());
			}
		}
		
		trace("\n");
	}
	
	public function parse(argc:Int, argv:Array<String>):Void
	{
		var cmd:CmdArg;
		
		var i:Int = 0;
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
				
				cmdWord = "-" + cmd.getKeyword();
				cmdChar = "-" + cmd.getOptChar();
				
				if ((arg == cmdWord) || (arg == cmdChar))
				{
					cmd.setFound();
					
					if (!cmd.getValue(i, argc, argv))
					{
						trace("Error: switch -" + cmd.getKeyword() + " must take an argument" + "\n");
						usage();
					}
					else
					{
						cmd.setValFound();
					}
					
					found = true;
				}
				
				i2++;
			}
			
			if (!found)
			{
				trace("Warning: argument \\" + arg + "\\ looks strange, ignoring.\n");
			}
			
			i++;
		}
		
		for (cmd2 in _cmdList)
		{
			if (!cmd2.isOpt()) // i.e required
			{
				if (!cmd2.isFound())
				{
					trace("Error: the switch -" + cmd2.getKeyword() + " must be supplied\n");
					usage();
				}
			}
			
			if (cmd2.isFound() && !cmd2.isValOpt()) // i.e need value
			{
				if (!cmd2.isValFound())
				{
					trace("Error: the switch -" + cmd2.getKeyword() + " must take a value\n");
					usage();
				}
			}
		}
	}
}