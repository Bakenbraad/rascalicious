module CyclomaticComplexity

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import IO;
import List;
import String;
import VolumeMetric;
import demo::common::Crawl;

public loc projectloc = |project://test_project|;
public M3 myModel = createM3FromEclipseProject(projectloc);
public set[Declaration] decls = createAstsFromEclipseProject(projectloc, true);
public map[str,int] totalFileLines = countLines(carProject);
public int totalPureLines = totalFileLines["lines"] - (totalFileLines["comments"] + totalFileLines["emptylines"]);

// Gets all methods as statements from the project.
public list[Statement] allMethods(){
	results = [];
	visit(decls){
		case m: \method(_,_,_,_, Statement s):
			results += s;
		case c: \constructor(_,_,_, Statement s):
			results += s;
	}
	return results; 
}

public void calcUnitSize() {
	allStatements = allMethods();
	
	for (statement <- allStatements){
		methodLines = countLines(statement.src);
		pureLines = methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]);
		println("<pureLines> in method at: <statement.src>");
	}

}

// Generate the CC for each of the methods and return a map of all methods (units) and their CC
public rel[str, loc] getCCforMethods() {

	allStatements = allMethods();
	int cc = 0;
	rel[str, loc] results = {};
	
	for (statement <- allStatements){
		cc = calcCC(statement);
		if(cc <= 10) {
			results += <"l", statement.src>;
		} else if (cc <= 20) {
			results += <"m", statement.src>;
		} else if (cc <= 50) {
			results += <"h", statement.src>;
		} else {
			results += <"vh", statement.src>;
		}
	}	
	
	return results;	
}

public map[str, int] getCCcategorizedRisk(){

	methodCCRel = getCCforMethods();
	map[str,int] results = ();
	
	results["vh"] 	= 0;
	results["h"]	= 0;
	results["m"]	= 0;
	results["l"]	= 0;
	
	for (r <- methodCCRel["l"]) {
		methodLines = countLines(r);		
		results["l"] += methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]);
	}
	for (r <- methodCCRel["m"]) {
		methodLines = countLines(r);
		results["m"] += methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]);
	}
	for (r <- methodCCRel["h"]) {
		methodLines = countLines(r);
		results["h"] += methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]);
	}
	for (r <- methodCCRel["vh"]) {
		methodLines = countLines(r);
		results["vh"] += lines["lines"] - (methodLines["comments"] + methodLines["emptylines"]);
	}
	
	return results;
}

public str calcRelativeRisk() {

	ccRelativeRisk = getCCcategorizedRisk();	
	
	// Calculate the percentages of the total code per category.
	real moderatePerc = (toReal(ccRelativeRisk["m"]) / (toReal(totalPureLines))) * 100.0;
	real highPerc = (toReal(ccRelativeRisk["h"]) / (toReal(totalPureLines))) * 100.0;
	real veryPerc = (toReal(ccRelativeRisk["vh"]) / (toReal(totalPureLines))) * 100.0;
	
	// Decide what rank the code has according to the paper.
	if (moderatePerc <= 25 && highPerc == 0 && veryPerc == 0) {
		return "++";
	}
	else if(moderatePerc<=30 && highPerc <= 5 && veryPerc == 0){
		return "+";
	}
	else if(moderatePerc <= 40 && highPerc <= 10 && veryPerc == 0){
		return "o";
	}
	else if(moderatePerc<=50 && highPerc <= 15 && veryPerc <= 5){
		return "-";
	}
	else return "--";
	
	
	
}

// Calculates the accumulated CC for a statement (method).
// Source: https://stackoverflow.com/questions/40064886/obtaining-cyclomatic-complexity
public int calcCC(Statement impl) {

	// Start at CC 1.
    int result = 1;
    
    visit (impl) {
        case \if(_,_) : result += 1;
        case \if(_,_,_) : result += 1;
        case \case(_) : result += 1;
        case \do(_,_) : result += 1;
        case \while(_,_) : result += 1;
        case \for(_,_,_) : result += 1;
        case \for(_,_,_,_) : result += 1;
        case foreach(_,_,_) : result += 1;
        case \catch(_,_): result += 1;
        case \conditional(_,_,_): result += 1;
        case infix(_,"&&",_) : result += 1;
        case infix(_,"||",_) : result += 1;
    }
    return result;
}

// Gives a list of all methods in a model. 
public list[loc] getAllMethods() {
	return dup([mt | <mt,_> <- myModel.containment, isMethod(mt)]);
}



