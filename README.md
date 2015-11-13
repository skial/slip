# !slip

Currently a exploration in making Haxe a little stricter. It's just an idea.

## Setup

Add `--macro uhx.macro.Explicit.setup()` to your `.hxml` file.

## _Current_ Purpose

Currently, all `!slip` does is check for null assignments on non nulled
types. What does that mean?

```Haxe
package ;

class Main {
	
	public static function main() {
		var s:String = null;	//	Error: s shouldn't be null. Change its type from String to Null<String> or initialize it.
		foo( null, 1 );			//	Error: For function foo, value for argument a should be of type String.
	}
	
	public static function foo(a:String, b:Int) {
		
	}
	
}
```