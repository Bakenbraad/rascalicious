module MetricsForUnits

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

public M3 myModel 		= createM3FromEclipseProject(projectloc);
public set[Declaration] decls 		= createAstsFromEclipseProject(projectloc, true);
// public map[str,int] totalFileLines 	= countLines(carProject);


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

public int allUnitLines(){
	allStatements = allMethods();
	int allPureLines = 0;
	
	for (statement <- allStatements){
		methodLines = countLines(statement.src);
		pureLines = methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]+methodLines["brackets"]);
		allPureLines += pureLines;
	}
	return allPureLines;
	
}

public int totalPureLines = allUnitLines();

// calculates the lines of pure code per unit(method)
public list[tuple[int,loc]] calcUnitSize(){
	allStatements = allMethods();
	list[tuple[int,loc]] unitSize = [];
	for (statement <- allStatements){
		methodLines = countLines(statement.src);
		pureLines = methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]+ methodLines["brackets"]);
		sizeLoc = <pureLines,statement.src>;
		unitSize += sizeLoc;
	}
	return unitSize;
}

public rel[str, loc] calculateRisk(int n, rel[str,loc] strLoc,loc stateLoc,list[int] values){
	if(n <= 10) {
		strLoc += <"l", stateLoc>;
	} else if (n <= 20) {
		strLoc += <"m", stateLoc>;
	} else if (n <= 50) {
		strLoc += <"h", stateLoc>;
	} else {
		strLoc += <"vh", stateLoc>;
	}
	return strLoc;
}

public rel[str,loc] riskPerUnitSize(){
	unitSize = calcUnitSize();
	rel[str, loc] results = {};
	list[int] values = [15,30,60];
	for (units <- unitSize){
		linesUnit 	= units[0];
		locationUnit= units[1]; 
		results = calculateRisk(linesUnit,results,locationUnit,values);
	}
	return results;
}


// Generate the CC for each of the methods and return a map of all methods (units) and their CC
public rel[str, loc] riskPerUnitCC() {

	allStatements = allMethods();
	int cc = 0;
	rel[str, loc] results = {};
	list[int] values = [10,20,50];
	
	for (statement <- allStatements){
		cc = calcCC(statement);
		loc stateLoc = statement.src;
		results = calculateRisk(cc,results,stateLoc,values);
	}	
	
	return results;	
}

public map[str, int] getCategorizedRisk(rel[str, loc] riskRelation){

	map[str,int] results = ();
	str riskCategory ="";
	
	results["vh"] 	= 0;
	results["h"]	= 0;
	results["m"]	= 0;
	results["l"]	= 0;
	
	for (r <- riskRelation){
		riskCategory = r[0];
		methodLines = countLines(r[1]);
		results[riskCategory] += (methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]));
		
	}
	
	return results;
}


public str calcRelativeRisk(map[str, int] riskMap) {
	
	
	// Calculate the percentages of the total code per category.
	real moderatePerc 	= (toReal(riskMap["m"]) / (toReal(totalPureLines))) * 100.0;
	real highPerc 		= (toReal(riskMap["h"]) / (toReal(totalPureLines))) * 100.0;
	real veryPerc 		= (toReal(riskMap["vh"]) / (toReal(totalPureLines))) * 100.0;
	
	println("<veryPerc>,<highPerc>,<moderatePerc>");
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

public void printUnitResults(){
	println("Complexity Rank: <calcRelativeRisk(getCategorizedRisk(riskPerUnitCC()))>");
	println("Unit Size Rank: <calcRelativeRisk(getCategorizedRisk(riskPerUnitSize()))>");
}