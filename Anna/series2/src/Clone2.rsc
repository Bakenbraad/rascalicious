module Clone2
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import IO;
import List;
import String;

public loc projectLoc = |project://smallsql0.21_src|;
//public loc projectLoc = |project://test_project|;

public set[Declaration] allMethods(){
	list[Statement] methods = [];
	set[Declaration] decls 		= createAstsFromEclipseProject(projectLoc, true);
	return visit(decls){
		case \method(x, _, y, z, q) 		=> \method(x, "methodName", y, z, q)
		case \parameter(x, _, z) 			=> \parameter(x, "paramName", z)
		case \vararg(x, _) 					=> \vararg(x, "varArgName") 
		case \annotationTypeMember(x, _)	=> \annotationTypeMember(x, "annonName")
		case \annotationTypeMember(x, _, y) => \annotationTypeMember(x, "annonName", y)
		case \typeParameter(_, x) 			=> \typeParameter("typeParaName", x)
		case \constructor(_, x, y, z) 		=> \constructor("constructorName", x, y, z)
		case \interface(_, x, y, z) 		=> \interface("interfaceName", x, y, z)
		case \class(_, x, y, z) 			=> \class("className", x, y, z)
		case \enumConstant(_, y) 			=> \enumConstant("enumName", y) 
		case \enumConstant(_, y, z) 		=> \enumConstant("enumName", y, z)
		case \methodCall(x, _, z) 			=> \methodCall(x, "methodCall", z)
		case \methodCall(x, y, _, z) 		=> \methodCall(x, y, "methodCall", z) 
		case \simpleName(_) 				=> \simpleName("simpleName")
		case \number(_) 					=> \number("1992")
		case \variable(x,y) 				=> \variable("variableName",y) 
		case \variable(x,y,z)				=> \variable("variableName",y,z) 
		
					
	}
}

public list[Statement] allMethodsEdit(){
	list[Statement] methods = [];
	set[Declaration] decls 		= allMethods();
	visit(decls){
		case m: \method(_,_,_,_, Statement s):
			{
				methods 	+= s;
				//parameters 	+= <size(l),s.src>;
			}
		case c: \constructor(_,_,_, Statement s):
			{
				methods 	+= s;
				//parameters 	+= <size(l),s.src>;
			}
	}
	return methods; 
}

