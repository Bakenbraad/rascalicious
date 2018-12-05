module Clone2
import lang::java::m3::Core;
import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import IO;
import List;
import String;
import demo::common::Crawl;


public loc projectLoc = |project://smallsql0.21_src|;
//public loc projectLoc = |project://test_project|;


// Get all java files from a project location.
public list[loc] findJavaFiles(loc l) {
	return crawl(l, ".java");
}

public list[Declaration] getRenamedFileASTs(loc projectLoc) {
	
	allProjectFiles = findJavaFiles(projectLoc);
	list[Declaration] fileASTs = [];
	
	for (file <- allProjectFiles) {
		AST			= renameDecls(file);
		fileASTs 	+= AST;
	}
	return fileASTs;
}

public Declaration main() {
	renamedAST = getRenamedFileASTs(projectLoc);
	return renamedAST[2];
}

public Declaration renameDecls(loc fileLoc){

	Declaration decl = createAstFromFile(fileLoc, true);
	
	return visit(decl){
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
		case \stringLiteral(_)				=> \stringLiteral("string")
		case \characterLiteral(_)			=> \stringLiteral("s")
		case \booleanLiteral(_)				=> \stringLiteral(true)
		case \number(_) 					=> \number("0")
		case \variable(x,y) 				=> \variable("variableName",y) 
		case \variable(x,y,z)				=> \variable("variableName",y,z) 	
		case Type _ 						=> Type::\void()
		case Modifier _ 					=> lang::java::jdt::m3::AST::\public()
	}
}
