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

public loc projectLoc = |project://test_project|;
//public loc projectLoc = |project://smallsql0.21_src|;
//public loc projectLoc = |project://hsqldb-2.3.1|;

public void main(){
	println("Printing results\n\nVolume metric:");
	<totalLines, codeLines> = showLines(projectLoc);	
	
	println("\nCode duplication:");
	int duplicatedLines = getProjectCodeDuplication(projectLoc,1);
	println("Duplication percentage: <((duplicatedLines * 1.0 ) / ((codeLines + totalLines["brackets"]) * 1.0)) * 100>% or <duplicatedLines> out of <codeLines> lines");
	
	printUnitResults(projectLoc);
}
