module MetricsForUnits

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Math;
import IO;
import List;
import String;
import FileReader;

// Gets all methods as statements from the project.
public tuple[list[tuple[int,loc]],list[Statement]] allMethods(loc projectloc){
	list[Statement] methods = [];
	list[tuple[int,loc]] parameters 	= [];
	set[Declaration] decls 		= createAstsFromEclipseProject(projectloc, true);
	visit(decls){
		case m: \method(_,_,list[Declaration] l,_, Statement s):
			{
				methods 	+= s;
				parameters 	+= <size(l),s.src>;
			}
		case c: \constructor(_,list[Declaration] l,_, Statement s):
			{
				methods 	+= s;
				parameters 	+= <size(l),s.src>;
			}
	}
	return <parameters,methods>; 
}


public int allUnitLines(loc projectloc){
	allStatements = allMethods(projectloc);
	int allPureLines = 0;
	
	for (statement <- allStatements[1]){
		methodLines = countLines(statement.src);
		pureLines = methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]+methodLines["brackets"]);
		allPureLines += pureLines;
	}
	return allPureLines;
	
}

// calculates the lines of pure code per unit(method)
public list[tuple[int,loc]] calcUnitSize(loc projectloc){
	allStatements = allMethods(projectloc);
	list[tuple[int,loc]] unitSize = [];
	for (statement <- allStatements[1]){
		methodLines = countLines(statement.src);
		pureLines = methodLines["lines"] - (methodLines["comments"] + methodLines["emptylines"]+ methodLines["brackets"]);
		sizeLoc = <pureLines,statement.src>;
		unitSize += sizeLoc;
	}
	return unitSize;
}

public rel[str, loc, int] calculateRisk(int n, rel[str, loc, int] strLoc,loc stateLoc,list[int] values,bool linesOfCode){
	int unitLines = 0;
	if ( linesOfCode){
		unitLines = n;
	} else{
		unitAllLines = countLines(stateLoc);
		unitLines = unitAllLines["lines"] - (unitAllLines["comments"] + unitAllLines["emptylines"]+ unitAllLines["brackets"]);
	}
	if(n <= values[0]) {
		strLoc += <"l", stateLoc,unitLines>;
	} else if (n <= values[1]) {
		strLoc += <"m", stateLoc,unitLines>;
	} else if (n <= values[2]) {
		strLoc += <"h", stateLoc,unitLines>;
	} else {
		strLoc += <"vh", stateLoc,unitLines>;
	}
	return strLoc;
}

public rel[str,loc,int] riskPerUnitSize(loc projectloc){
	unitSize = calcUnitSize(projectloc);
	rel[str,loc,int] results = {};
	list[int] values = [15,30,60];
	for (units <- unitSize){
		linesUnit 	= units[0];
		locationUnit= units[1]; 
		results = calculateRisk(linesUnit,results,locationUnit,values,true);
	}
	return results;
}

public rel[str,loc,int] riskPerUnitParameters(loc projectloc){
	allStatements 	= allMethods(projectloc);
	int parameters 	= 0;
	rel[str,loc,int] results = {};
	list[int] values = [3,5,7];
	for (statement <- allStatements[0]){
		parameters = statement[0];
		loc stateLoc = statement[1];
		results = calculateRisk(parameters,results,stateLoc,values,false);
	}
	return results;
}

// Generate the CC for each of the methods and return a map of all methods (units) and their CC
public rel[str, loc, int] riskPerUnitCC(loc projectloc) {

	allStatements = allMethods(projectloc);
	int cc = 0;
	rel[str,loc,int] results = {};
	list[int] values = [10,20,50];
	
	for (statement <- allStatements[1]){
		cc = calcCC(statement);
		loc stateLoc = statement.src;
		results = calculateRisk(cc,results,stateLoc,values,false);
	}	
	
	return results;	
}

public map[str, int] getCategorizedRisk(rel[str, loc, int] riskRelation){

	map[str,int] results = ();
	str riskCategory ="";
	
	results["vh"] 	= 0;
	results["h"]	= 0;
	results["m"]	= 0;
	results["l"]	= 0;
	
	for (r <- riskRelation){
		riskCategory = r[0];
		methodLines = r[2];
		results[riskCategory] += methodLines;
		
	}
	
	return results;
}


public str calcRelativeRisk(map[str, int] riskMap, int totalPureLines) {	
	
	// Calculate the percentages of the total code per category.
	real moderatePerc 	= (toReal(riskMap["m"]) / (toReal(totalPureLines))) * 100.0;
	real highPerc 		= (toReal(riskMap["h"]) / (toReal(totalPureLines))) * 100.0;
	real veryPerc 		= (toReal(riskMap["vh"]) / (toReal(totalPureLines))) * 100.0;
	
	//println("<veryPerc>,<highPerc>,<moderatePerc>");
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


public map[int,str] unitRank(loc projectloc) {
	int totalPureLines = allUnitLines(projectloc);
	map[int,str] results = ();
	results[0] 	= calcRelativeRisk(getCategorizedRisk(riskPerUnitCC(projectloc)), totalPureLines);
	results[1]	= calcRelativeRisk(getCategorizedRisk(riskPerUnitSize(projectloc)), totalPureLines);
	results[2]	= calcRelativeRisk(getCategorizedRisk(riskPerUnitParameters(projectloc)), totalPureLines);
	
	return results;
	
}
