module main

import VolumeMetric;
import MetricsForUnits;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;

//public loc carProject = |project://test_project//src//test_project/Cars.java|;
// public loc testProjectLocation = |project://smallsql0.21_src|;

public void main(){
	println("Printing results\n\nVolume metric:");
	showLines();
	printUnitResults();
	
}

public void showLines(){
	map[str,int] projectVolumeValues = countProjectLines(findJavaFiles());
	str rank = "";
	int codeLines = projectVolumeValues["lines"]-(projectVolumeValues["comments"] + projectVolumeValues["emptylines"]+projectVolumeValues["brackets"]);
	if(codeLines<=66000){
		rank = "++";
	}
	else if(codeLines<=246000){
		rank = "+";
	}
	else if(codeLines<=665000){
		rank = "o";
	}
	else if(codeLines<=1310000){
		rank = "-";
	}
	else rank = "--";
	println("Lines in total: <projectVolumeValues["lines"]>\nLines of pure code: <codeLines>\nLines of comments: <projectVolumeValues["comments"]>\nEmpty Lines: <projectVolumeValues["emptylines"]>\nBrackets: <projectVolumeValues["brackets"]>");
	println("Rank: <rank>");
}

public list[loc] findJavaFiles() {
	return crawl(projectloc, ".java");
}