package;

/**
 * ...
 * @author Skial Bainn
 */
class Main {
	
	static function main() {
		var a:String = '';
		var b:String = '';
		var c:Null<Main> = null;
		c = new Main();
		var d:Null<String> = null;
		d = '';
		trace( a, b );
		foo( a, b, 0, null );
		//foo('', '', '', 0 );
	}
	
	public function new() {
		
	}
	
	public static function foo(a:String, b:String, c:Int, d:Null<Int>) {
		
	}
	
}