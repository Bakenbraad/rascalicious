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
import Node;

alias subTreeMap = map[str, list[loc]];

//public loc projectLoc = |project://smallsql0.21_src|;
public loc projectLoc = |project://test_project|;

//http://leodemoura.github.io/files/ICSM98.pdf
public int massThreshold = 7;


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

public loc getNodeLoc(node n) {

	switch (n) {
		case Declaration d:
			return d.src;
		case Expression e:
			return e.src;
		case Statement s:
			return s.src;
	}
	return projectLoc;
}



public tuple[list[str], list[loc]] getCloneClasses(subTreeMap st) {
	for (clone <- st) {
		//if (size(st[clone]) > 1) {			
			return <[clone], st[clone]>;
		//}
	}
	return <[], []>;
}



public str cleanMetaData(node n) {

	str nodeKey = "";
	
	visit(n) {
		case Declaration d:{
			dnew = d;
			dnew.src = |unknown:///|;
			dnew.typ = class(|unknown:///|,[]);
			dnew.decl = |unknown:///|;
			nodeKey += toString(dnew);
			println("");
			println(dnew);
		}
		case Expression e:{
			enew = e;
			enew.src = |unknown:///|;
			enew.typ = class(|unknown:///|,[]);
			nodeKey += toString(enew);
			println("");
			println(enew);
		}
		case Statement s:{
			snew = s;
			snew.src = |unknown:///|;
			nodeKey += toString(snew);
			println("");
			println(snew);
		}
	}
	return nodeKey;

}

public map[str, list[loc]] addSubTreeToRes(node n, map[str, list[loc]] results) {

	nodeLoc = getNodeLoc(n);
	cleanNode = cleanMetaData(n);
	if (nodeLoc != |unknown:///|) {
		if(cleanNode in results) {
			results[cleanNode] += nodeLoc;
		} else {
			results[cleanNode] = [nodeLoc];
		}
	}	
	return results;
}

public tuple[list[str], list[loc]] getSingleNode() {
	renamedASTs = getRenamedFileASTs(projectLoc);
	subTreeMap results = ();
	sq = false;
	for (fileAST <- renamedASTs) {
	
		visit(fileAST) {
			case node n:{
				loc l = projectLoc;
				if (calcNodeMass(n) >= 10) {
					results = addSubTreeToRes(n, results);
				}	
			}		
		}
	}
	aSingleClone = getCloneClasses(results);
	
	return aSingleClone;
}
public tuple[list[str], list[loc]] getASingleClone() {
	
	renamedASTs = getRenamedFileASTs(projectLoc);
	
	subTreeMap results = ();
	
	for (fileAST <- renamedASTs) {
		visit(fileAST) {
			case node n: {
				if (calcNodeMass(n) == 10) {
					l = projectLoc;
					println(n);
					switch (n) {
						case Declaration d:
							l = d.src;
						case Expression e:
							l = e.src;
						case Statement s:
							l = s.src;
					}
					if(n in results) {
						results[n] += l;
					} else {
						results[n] = [l];
					}
				}	
			}		
		}
	}
	
	aSingleClone = getCloneClasses(results);
	
	return aSingleClone;
}

//TODO: generate all clone pairs and classes and output them in a textual way.

// To avoid comparison of small trees and reduce the search space monumentally calculate a mass.
// The mass is the amount of subnodes of a node.
public int calcNodeMass(node n) {

	int mass = 0;
	
	visit (n) {
		case node sn:
			mass += 1;
	}
	return mass;
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
		case \characterLiteral(_)			=> \characterLiteral("s")
		case \booleanLiteral(_)				=> \booleanLiteral(true)
		case \number(_) 					=> \number("0")
		case \variable(x,y) 				=> \variable("variableName",y) 
		case \variable(x,y,z)				=> \variable("variableName",y,z) 	
		case Type _ 						=> Type::\void()
		case Modifier _ 					=> lang::java::jdt::m3::AST::\public()
	}
}