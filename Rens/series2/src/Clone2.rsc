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

alias subTreeMap 	= map[node, list[loc]];
alias cloneClass 	= tuple[node, list[loc]];
alias filePair 		= tuple[loc, loc];

//public loc projectLoc = |project://smallsql0.21_src|;
public loc projectLoc = |project://test_project|;

//http://leodemoura.github.io/files/ICSM98.pdf
public int massThreshold = 10;


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

public list[cloneClass] getCloneClasses(subTreeMap st, bool filtered) {

	cloneClasses = [];
	
	for (clone <- st) {
		if (filtered) {
			cloneClasses += <clone, dup(st[clone])>;
		} else if (size(st[clone]) > 1 ) {			
			cloneClasses += <clone, st[clone]>;
		}
		
	}
	return cloneClasses;
}

public subTreeMap addSubTreeToRes(node n, subTreeMap results) {

	nodeLoc = getNodeLoc(n);
	cleanNode = unsetRec(n);
	if (nodeLoc != |unknown:///|) {
		if(cleanNode in results) {
			results[cleanNode] += nodeLoc;
		} else {
			results[cleanNode] = [nodeLoc];
		}
	}	
	return results;
}

public list[cloneClass] findCloneClasses() {

	renamedASTs = getRenamedFileASTs(projectLoc);
	subTreeMap results = ();

	for (fileAST <- renamedASTs) {
	
		visit(fileAST) {
			case node n:{
				loc l = projectLoc;
				if (calcNodeMass(n) >= massThreshold) {
					results = addSubTreeToRes(n, results);
				}	
			}		
		}
	}
	
	filteredResults = filterSubClones(getCloneClasses(results, false));
	filteredCloneClasses = getCloneClasses(filteredResults, true);
	
	println(size(filteredCloneClasses));
	return filteredCloneClasses;
}

public subTreeMap filterSubClones(list[cloneClass] cloneClasses) {

	cloneClassesPerFilePair = createCloneClassesPerFilePair(cloneClasses);
	subTreeMap filteredNodes = ();
	
	for (fp <- cloneClassesPerFilePair) {
		allCloneClassesInFilePair = cloneClassesPerFilePair[fp];
		for (cC <- allCloneClassesInFilePair) {
			if (!isSubLocOfAny(cC, allCloneClassesInFilePair)) {
				locs = cC[1];
				if (cC[0] in filteredNodes) {
					filteredNodes[(cC[0])] += locs[0];
				} else {
					filteredNodes[(cC[0])] = [locs[0]];
				}
				filteredNodes[cC[0]] += locs[1];
			}
		}
	}
	
	return filteredNodes;
}

public bool isSubLocOfAny(cloneClass cC, list[cloneClass] allCloneClassesInFilePair) {
	
	cClocs = cC[1];
	cCOneLoc = cClocs[0];
	cCTwoLoc = cClocs[1];
	
	for (superCC <- allCloneClassesInFilePair) {
		if (cC != superCC) {
			
			superCCLocs = superCC[1];
			superCCOneLoc = superCCLocs[0];
			superCCTwoLoc = superCCLocs[1];
			
			if (isSubLocOf(cCOneLoc, superCCOneLoc) && isSubLocOf(cCTwoLoc, superCCTwoLoc)) {
				return true;
			}
		}
	}
	return false;
}

public bool isSubLocOf(loc l, loc superloc) {
	if (l.offset >= superloc.offset && l.offset + l.length <= superloc.offset + superloc.length) {
		return true;
	}
	return false;
}

public map[filePair, list[cloneClass]] createCloneClassesPerFilePair(list[cloneClass] cloneClasses) {
	
	map[filePair, list[cloneClass]] cloneClassPerFile = ();
	for (cC <- cloneClasses) {
		cloneLocs = cC[1];
		locCombinations = getLocCombinations(cloneLocs);
		cloneClassPerFile = insertCloneClassPerFile(locCombinations, cC, cloneClassPerFile);		
	}
	return cloneClassPerFile;
}

public map[filePair, list[cloneClass]] insertCloneClassPerFile(lrel[loc,loc] locCombinations, cloneClass cC, map[filePair, list[cloneClass]] cloneClassPerFile) {

	for (lc <- locCombinations) {
	
		loc1 = toLocation(lc[0].uri);
		loc2 = toLocation(lc[1].uri);
		
		if (<loc1, loc2> in cloneClassPerFile) {
			cloneClassPerFile[<loc1, loc2>] += <cC[0], [lc[0],lc[1]]>;
		} else if (<loc2, loc1> in cloneClassPerFile) {
			cloneClassPerFile[<loc2, loc1>] += <cC[0], [lc[1],lc[0]]>;
		} else {
			cloneClassPerFile[<loc1, loc2>] = [<cC[0], [lc[0],lc[1]]>];
		}
	}
	return cloneClassPerFile;
}

public list[tuple[loc, loc]] getLocCombinations(list[loc] locs) {
	
	res = [];
	
	locSize = size(locs);
	n = 1;
	
	if (locSize >= 2) {
		for (l <- locs) {
			for (i <- [n..locSize]) {
				res += <l, locs[i]>;
			}
			n += 1;
		}
	}
	return res;
}

//TODO: filter subpairs of clones.

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
