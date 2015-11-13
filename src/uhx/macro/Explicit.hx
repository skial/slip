package uhx.macro;

import haxe.ds.IntMap;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
import haxe.macro.Compiler;

using haxe.macro.TypeTools;
using haxe.macro.TypedExprTools;
using haxe.macro.MacroStringTools;

/**
 * ...
 * @author Skial Bainn
 */
class Explicit {

	public static function setup() {
		Context.onGenerate( start );
	}
	
	public static var types:Array<Type> = [];
	
	public static function start(types:Array<Type>) {
		Explicit.types = types;
		
		var args = Sys.args();
		var entryName = args[args.indexOf( '-main' ) + 1];
		var entryType:ClassType = null;
		var entryMethod:ClassField = null;
		
		for (type in types) {
			switch (type) {
				case TInst(_.get() => cls, params) if (cls.pack.toDotPath( cls.name ) == entryName):
					entryType = cls;
					entryMethod = cls.statics.get().filter( function(f) return f.name == 'main' )[0];
					
				case _:
					
			}
			
		}
		
		if (entryMethod != null) {
			process( entryMethod.expr() );
			
		}
		
	}
	
	public static inline function notNull(v):Bool {
		return v != null;
	}
	
	public static function process(expr:TypedExpr) {
		var errors:Array<Error> = [];
		
		if (expr != null) switch(expr.expr) {
			case TBinop(OpAssign, { expr:TLocal(register(_) => object), pos:_ }, { expr:ctor, pos:_ } ):
				if (!strictUnify( object.t, ctor )) errors.push( NULL( object.name, object.t, object.t) );
				
			case TVar(register(_) => object, value):
				if (!strictUnify( object.t, value.expr )) errors.push( NULL(object.name, object.t, value.t) );
				
			case TCall( { expr:TField(module, FStatic(_.get() => c, _.get() => { name:n, type:TFun(fargs, _) } )), pos:_ }, args):
				var argErrors:Array<Error> = [];
				for (i in 0...fargs.length) {
					if (!strictUnify( fargs[i].t, args[i].expr )) {
						expr = args[i];
						argErrors.push( ARG_NULL( n, fargs[i].name, fargs[i].t ) );
						break;
						
					}
					
				}
				report( argErrors, expr );
				
			case TFunction(method):
				var argErrors:Array<Error> = [];
				for (arg in method.args) {
					register( arg.v );
					if (!strictUnify( arg.v.t, TConst(arg.value) )) argErrors.push( NULL( arg.v.name, arg.v.t, arg.v.t ) );
					
				}
				report( argErrors, expr );
				process( method.expr );
				
			case _:
				//trace( expr );
				expr.iter( process );
				
		}
		
		report( errors, expr );
	}
	
	public static function strictUnify(t1:Type, t2:TypedExprDef):Bool {
		var nullAllowed = switch(t1) {
			case TType(_.get() => def, params):
				def.name == 'Null';
				
			case _:
				false;
				
		}
		
		var isNull = switch (t2) {
			case TConst(TNull):
				true;
				
			case _: 
				false;
				
		}
		
		return (nullAllowed && isNull) || (!nullAllowed && !isNull) || (nullAllowed && !isNull);
	}
	
	public static function typedNull(type:Type):Bool {
		// Watch the world burn!
		return type.toString().indexOf( 'Null<' ) != -1;
	}
	
	public static var registry:IntMap<TVar> = new IntMap();
	
	public static function register(tvar:TVar):TVar {
		if (!registry.exists( tvar.id )) {
			registry.set( tvar.id, tvar );
			
		}
		
		return tvar;
	}
	
	public static function report(errors:Array<Error>, expr:TypedExpr) {
		for (error in errors) switch (error) {
			case NULL(n, t1, t2):
				Context.error( '$n shouldn\'t be null. Change its type from ${t1.toString()} to Null<${t2.toString()}> or initialize it.', expr.pos );
				
			case ARG_NULL(m, a, t):
				Context.error( 'For function $m, value for argument $a should be of type ${t.toString()}.', expr.pos );
				
			case _:
				
		}
		
	}
	
}

enum Error {
	NULL(name:String, type1:Type, type2:Type);
	ARG_NULL(method:String, arg:String, type1:Type);
}