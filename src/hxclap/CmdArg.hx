package hxclap;

/**
 * ...
 * @author Ohmnivore
 */

class E_CmdArgStatus
{
	public static inline var isBAD:Int       = 0x00;  // bad status
	public static inline var isFOUND:Int     = 0x01;  // argument was found in the command line
	public static inline var isVALFOUND:Int  = 0x02;  // the value of the argument was found in the command line
	public static inline var isPARSEOK:Int   = 0x04;   // argument was found and its value is ok
}

class E_CmdArgSyntax
{
	public static inline var isOPT:Int       = 0x01;  // argument is optional
	public static inline var isREQ:Int       = 0x02;  // argument is required
	public static inline var isVALOPT:Int    = 0x04;  // argument value is optional
	public static inline var isVALREQ:Int    = 0x08;  // argument value is required
	public static inline var isHIDDEN:Int    = 0x10;  // argument is not to be printed in usage    
}

//Definition of class CmdArg
class CmdArg
{
	public var _optChar:String;
	public var _keyword:String;
	public var _valueName:String;
	public var _description:String;
	public var _syntaxFlags:Int;
	public var _status:Int;
	
	private function setValueName(S:String):Void
	{
		_valueName = S;
	}
	
	private function setDescription(S:String):Void
	{
		_description = S;
	}
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ)) 
	{
		_optChar = optChar;
		_keyword = keyword;
		_valueName = valueName;
		_description = description;
		_syntaxFlags = syntaxFlags;
		_status = E_CmdArgStatus.isBAD;
		
		validate_flags();
	}
	
	// selectors
	public function getOptChar():String
	{
		return _optChar;
	}
	
	public function getKeyword():String
	{
		return _keyword;
	}
	
	public function getValueName():String
	{
		return _valueName;
	}
	
	public function getDescription():String
	{
		return _description;
	}
	
	public function getSyntaxFlags():Int
	{
		return _syntaxFlags;
	}
	
	public function isHidden():Bool
	{
		//return (_syntaxFlags & E_CmdArgSyntax.isHIDDEN);
		if (_syntaxFlags & E_CmdArgSyntax.isHIDDEN > 0)
			return true;
		
		return false;
	}
	
	public function isOpt():Bool
	{
		//return (_syntaxFlags & E_CmdArgSyntax.isOPT);
		if (_syntaxFlags & E_CmdArgSyntax.isOPT > 0)
			return true;
		
		return false;
	}
	
	public function isValOpt():Bool
	{
		//return (_syntaxFlags & E_CmdArgSyntax.isVALOPT);
		if (_syntaxFlags & E_CmdArgSyntax.isVALOPT > 0)
			return true;
		
		return false;
	}
	
	public function isBad():Bool
	{
		//return _status;
		if (_status > 0)
			return true;
		
		return false;
	}
	
	public function setFound():Void
	{
		_status |= E_CmdArgStatus.isFOUND;
		//trace((_syntaxFlags & E_CmdArgStatus.isFOUND), E_CmdArgStatus.isFOUND, ((0x00 | 0x02) & 0x02));
	}
	
	public function isFound():Bool
	{
		//return (_status & E_CmdArgStatus.isFOUND);
		//trace((_syntaxFlags & E_CmdArgStatus.isFOUND));
		if (_status & E_CmdArgStatus.isFOUND > 0)
			return true;
		
		return false;
	}
	
	public function setValFound():Void
	{
		_status |= E_CmdArgStatus.isVALFOUND;
	}
	
	public function isValFound():Bool
	{
		//return (_status & E_CmdArgStatus.isVALFOUND);
		if ((_status & E_CmdArgStatus.isVALFOUND) > 0)
			return true;
		
		return false;
	}
	
	public function setParseOK():Void
	{
		_status |= E_CmdArgStatus.isPARSEOK;
	}
	
	public function isParseOK():Bool
	{
		//return (_status & E_CmdArgStatus.isPARSEOK);
		if (_status & E_CmdArgStatus.isPARSEOK > 0)
			return true;
		
		return false;
	}
	
	// methods
	public function isNull():Bool
	{
		return !isParseOK();
	}
	
	public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		return true;
	}
	
	public function validate_flags():Bool
	{
		if ((_syntaxFlags & E_CmdArgSyntax.isOPT > 0) && (_syntaxFlags & E_CmdArgSyntax.isREQ > 0))
		{
			trace("Warning: keyword " + getKeyword() + " can't be optional AND required\n");
			trace(" changing the syntax of " + getKeyword() + " to be required.\n");
			
			_syntaxFlags &= ~E_CmdArgSyntax.isOPT;
			return false;
		}
		
		if ((_syntaxFlags & E_CmdArgSyntax.isVALOPT > 0) && (_syntaxFlags & E_CmdArgSyntax.isVALREQ > 0))
		{
		   trace("Warning: value for keyword " + getKeyword() + " can't be optional AND required\n");
		   trace("changing the syntax for the value of " + getKeyword() + " to be required.\n");
		   
			_syntaxFlags &= ~E_CmdArgSyntax.isVALREQ;
			return false;
		}
		
		return true;
	}
}

//Definition of class CmdArgInt
class CmdArgInt extends CmdArg
{
	public var _v:Float;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:Int = 0)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		_v = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		var ptr:String;
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			try
			{
				_v = Std.parseInt(arg);
			}
			
			catch (e:Dynamic)
			{
				trace(" invalid integer value \\" + arg + "\\");
				return false;
			}
			
			setParseOK();
			return true;
		}
		
		else
		{
			return false;
		}
	}
	//operator int();
	//friend ostream& operator<<(ostream&, const CmdArgInt&);
}

//Definition of class CmdArgFloat
class CmdArgFloat extends CmdArg
{
	public var _v:Float;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:Float = 0)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		_v = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		var ptr:String;
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			try
			{
				_v = Std.parseFloat(arg);
			}
			
			catch (e:Dynamic)
			{
				trace(" invalid integer value \\" + arg + "\\");
				return false;
			}
			
			setParseOK();
			return true;
		}
		
		else
		{
			return false;
		}
	}
	//operator float();
    //friend ostream& operator<<(ostream&, const CmdArgFloat&);
}

//Definition of class CmdArgBool
class CmdArgBool extends CmdArg
{
	public var _v:Bool;
	
	public function new(optChar:String, keyword:String, description:String, syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ))
	{
		super(optChar, keyword, "", description, syntaxFlags);
		
		_v = false;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		_v = true;
		setParseOK();
		return true;
	}
	//operator bool();
	//friend ostream& operator<<(ostream&, const CmdArgBool&);
}

//Definition of class CmdArgStr
class CmdArgStr extends CmdArg
{
	public var _v:String;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:String)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		_v = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			if (arg.charAt(0) == "-") return false;
			_v = arg;
			setParseOK();
			return true;
		}
		
		else
			return false;
	}
	//operator char*();
	//friend ostream& operator<<(ostream&, const CmdArgStr&);
}

//Definition of class CmdArgChar
class CmdArgChar extends CmdArg
{
	public var _v:String;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), def:String)
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		_v = def;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var arg:String = argv[i];
			
			if (arg.length > 1)
			{
				trace("value \\" + arg + "\\ is too long. ignoring\n");
				return false;
			}
			
			_v = arg.charAt(0);
			setParseOK();
			return true;
		}
		
		else
			return false;
	}
	//operator char();
	//friend ostream& operator<<(ostream&, const CmdArgChar&);
}

//Definition of CmdArgTypeList
class CmdArgTypeList<T> extends CmdArg
{
	public var _list:Array<T>;
	public var _index:Int;
	public var _delimiters:String;
	public var _max:Int;
	public var _min:Int;
	
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ),
		minSize:Int = 1,
		maxSize:Int = 100,
		delim:String = ",-~/.")
	{
		super(optChar, keyword, valueName, description, syntaxFlags);
		
		_delimiters = delim;
		_min = minSize;
		_max = maxSize;
		_list = [];
		
		var buf:String = "";
		buf = getValueName();
		if (buf.length == 0)
			buf += " ";
		//[TODO]Not sure about this one...
		buf += _delimiters.charAt(0) + "..." + _delimiters.charAt(0) + getValueName();
		setValueName(buf);
		
		buf = "";
		//[TODO]This is probably wrong
		buf += '$description ($_min $_max)';
		setDescription(buf);
		
		var i:Int = 0;
		while (i < delim.length)
		{
			if (delim.charAt(i) == ' ')
			{
				//[TODO]Gotta throw an exception
				trace("ERROR: space can't be a delimiter");
			}
			
			i++;
		}
	}
	
	public function getDelimiters():String
	{
		return _delimiters;
	}
	
	public function getMaxSize():Int
	{
		return _max;
	}
	
	public function getMinSize():Int
	{
		return _min;
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		return true;
	}
	
	//[TODO]Not too sure about the iterator
	public function getItem(Index:Int):T
	{
		Index = Index % _list.length;
		while (_index != Index)
		{
			if (_index < Index)
			{
				_index++;
			}
			else
			{
				_index++;
			}
		}
		
		return _list[_index];
	}
	
	public function reset():Void
	{
		_index = 0;
	}
	
	public function size():Int
	{
		return _list.length;
	}
	
	public function insert(Item:T):Void
	{
		if (_list.length < _max)
		{
			_list.push(Item);
		}
	}
	
	public function validate():Bool
	{
		if (_list.length < _min)
		{
			//[TODO]Throw an exception
			trace("Too few arguments to the switch -" + getKeyword() + "\n");
			return false;
		}
		
		if (_list.length > _max)
		{
			//[TODO]Throw an exception
			trace("Too many arguments to the switch -" + getKeyword() + "\n");
			return false;
		}
		
		reset();
		setParseOK();
		return true;
	}
	
	//friend ostream& operator<< <>(ostream&, const CmdArgTypeList<T>&);
	//ostream& print_me(ostream&) const;
}

//Definition of class CmdArgIntList
class CmdArgIntList extends CmdArgTypeList<Int>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				var value:Dynamic = Std.parseInt(v);
				
				if (value != null)
				{
					insert(value);
				}
				else
				{
					trace("invalid integer value \\" + v + "\\\n");
					return false;
				}
			}
			
			return validate();
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgFloatList
class CmdArgFloatList extends CmdArgTypeList<Float>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				var value:Dynamic = Std.parseFloat(v);
				
				if (value != null)
				{
					insert(value);
				}
				else
				{
					trace("invalid float value \\" + v + "\\\n");
					return false;
				}
			}
			
			return validate();
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgStrList
class CmdArgStrList extends CmdArgTypeList<String>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				insert(v);
			}
			
			return validate();
		}
		
		else
			return false;
	}
}

//Definition of class CmdArgCharList
class CmdArgCharList extends CmdArgTypeList<String>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(i:Int, argc:Int, argv:Array<String>):Bool
	{
		i++;
		
		if (i < argc)
		{
			var tokens:String = argv[i];
			
			var tokens_arr:Array<String> = tokens.split(_delimiters.charAt(0));
			
			for (v in tokens_arr)
			{
				v = StringTools.trim(v);
				
				if (v.length == 1)
				{
					insert(v);
				}
				else
				{
					trace("invalid char value \"" + v + "\"\n");
				}
			}
			
			return validate();
		}
		
		else
			return false;
	}
}