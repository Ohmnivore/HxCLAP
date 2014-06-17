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
		
	}
	
	private function setDescription(S:String):Void
	{
		
	}
	
	public function new(Char1:String, Char2:String, Char3:String, Char4:String, Int1:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ)) 
	{
		
	}
	
	// selectors
	public function getOptChar():String
	{
		return "";
	}
	
	public function getKeyword():String
	{
		return "";
	}
	
	public function getValueName():String
	{
		return "";
	}
	
	public function getDescription():String
	{
		return "";
	}
	
	public function getSyntaxFlags():Int
	{
		return 0;
	}
	
	public function isHidden():Bool
	{
		return true;
	}
	
	public function isOpt():Bool
	{
		return true;
	}
	
	public function isValOpt():Bool
	{
		return true;
	}
	
	public function isBad():Bool
	{
		return true;
	}
	
	public function setFound():Void
	{
		
	}
	
	public function isFound():Bool
	{
		return true;
	}
	
	public function setValFound():Void
	{
		
	}
	
	public function isValFound():Bool
	{
		return true;
	}
	
	public function setParseOK():Void
	{
		
	}
	
	public function isParseOK():Bool
	{
		return true;
	}
	
	// methods
	public function isNull():Bool
	{
		return true;
	}
	
	public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
	
	public function validate_flags():Bool
	{
		return true;
	}
}

//Definition of class CmdArgInt
class CmdArgInt extends CmdArg
{
	public var _v:Float;
	
	public function new(Char1:String, Char2:String, Char3:String, Char4:String,
		Int1:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), Int2:Int = 0)
	{
		super(Char1, Char2, Char3, Char4, Int1);
	}
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
	//operator int();
	//friend ostream& operator<<(ostream&, const CmdArgInt&);
}

//Definition of class CmdArgFloat
class CmdArgFloat extends CmdArg
{
	public var _v:Float;
	
	public function new(Char1:String, Char2:String, Char3:String, Char4:String,
		Int1:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), Double1:Float = 0)
	{
		super(Char1, Char2, Char3, Char4, Int1);
	}
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
	//operator float();
    //friend ostream& operator<<(ostream&, const CmdArgFloat&);
}

//Definition of class CmdArgBool
class CmdArgBool extends CmdArg
{
	public var _v:Bool;
	
	public function new(Char1:String, Char2:String, Char3:String, Int1:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ))
	{
		super(Char1, Char2, Char3, Char3, Int1);
	}
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
	//operator bool();
	//friend ostream& operator<<(ostream&, const CmdArgBool&);
}

//Definition of class CmdArgStr
class CmdArgStr extends CmdArg
{
	public var _v:String;
	
	public function new(Char1:String, Char2:String, Char3:String, Char4:String, Int1:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ))
	{
		super(Char1, Char2, Char3, Char4, Int1);
	}
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
	//operator char*();
	//friend ostream& operator<<(ostream&, const CmdArgStr&);
}

//Definition of class CmdArgChar
class CmdArgChar extends CmdArg
{
	public var _v:String;
	
	public function new(Char1:String, Char2:String, Char3:String, Char4:String,
		Int1:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), Char5:String = "\\0")
	{
		super(Char1, Char2, Char3, Char4, Int1);
	}
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
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
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
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
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
}

//Definition of class CmdArgIntList
class CmdArgFloatList extends CmdArgTypeList<Float>
{
	public function new(optChar:String, keyword:String, valueName:String, description:String,
		syntaxFlags:Int = (E_CmdArgSyntax.isREQ | E_CmdArgSyntax.isVALREQ), minSize:Int = 1,
		maxSize:Int = 100, delim:String = ",~/")
	{
		super(optChar, keyword, valueName, description, syntaxFlags, minSize, maxSize, delim);
	}
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
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
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
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
	
	override public function getValue(Int1:Int, Int2:Int, Char1:Array<String>):Bool
	{
		return true;
	}
}