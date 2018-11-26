module main

import VolumeMetric;
import MetricsForUnits;
import CodeDuplication;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;

//public loc projectLoc = |project://test_project|;
public loc projectLoc = |project://smallsql0.21_src|;
//public loc projectLoc = |project://hsqldb-2.3.1|;

public tuple[map[str, int], int,str] volumeResults 	= showLines(projectLoc);
public map[int,str]	unitRankingResults 				= unitRank(projectLoc);
public tuple[int,str,real] codeDuplicationResults	= showCodeDuplication(projectLoc, volumeResults[0]);

public void main(){
	
	println("Printing results\n\nVolume metric:");
	println("Lines in total: <volumeResults[0]["lines"]>\nLines of pure code: <volumeResults[1]>\nLines of comments: <volumeResults[0]["comments"]>\nEmpty Lines: <volumeResults[0]["emptylines"]>\nBrackets: <volumeResults[0]["brackets"]>");
	println("Rank: <volumeResults[2]>\n");
	
	println("Code duplication:");
	println("Duplicated lines in project: <codeDuplicationResults[0]>\nPercentage of total: <codeDuplicationResults[2]>");
	println("Rank: <codeDuplicationResults[1]>\n");

	println("Complexity Rank: <unitRankingResults[0]>");
	println("Unit Size Rank: <unitRankingResults[1]>");
	println("Unit Interfacing Rank: <unitRankingResults[2]>");
	table();
}

//TODO: Do we add duplication to any of the analysability/changeability/testability metrics.
public void table(){
	map[str,int] intRanking = ();
		
	intRanking["volume"] = strToInt(volumeResults[2]);
	intRanking["cc"] = strToInt(unitRankingResults[0]);
	intRanking["unitsize"] = strToInt(unitRankingResults[1]);
	intRanking["duplication"] = strToInt(codeDuplicationResults[1]);
	analysability = intToStr((intRanking["volume"]+intRanking["unitsize"]+intRanking["duplication"])/3);
	changeability = intToStr((intRanking["cc"]+intRanking["duplication"])/2);
	testability = intToStr((intRanking["cc"]+intRanking["unitsize"])/2);
	println("analysability: <analysability>, changeability: <changeability>, testability: <testability>");
}

public int strToInt(str ranking){
	int intRanking = 0;
	if(ranking == "--"){
		intRanking	= 1;
	}
	else if(ranking == "-"){
		intRanking	= 2;
	}
	else if(ranking == "o"){
		intRanking	= 3;
	}
	else if(ranking == "+"){
		intRanking	= 4;
	}
	else{
		intRanking	= 5;
	}
	return intRanking;
}

public str intToStr(int ranking){
	str strRanking = "";
	if(ranking == 1){
		strRanking	= "--";
	}
	else if(ranking == 2){
		strRanking	= "-";
	}
	else if(ranking == 3){
		strRanking	= "o";
	}
	else if(ranking == 4){
		strRanking	= "+";
	}
	else{
		strRanking	= "++";
	}
	return strRanking;
}