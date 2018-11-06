module modelThing
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;
import String;
import demo::common::Crawl;


public loc carProjectLocation = |project://test_project|;
public M3 model1 = createM3FromEclipseProject(carProjectLocation);
public set[loc] methods1 = methods(model1);

// number of methrods(functions) in a class
public int numberOfMethods(loc cl, M3 model) = size([ m | m <- model.containment[cl], isMethod(m)]);

// number of methrods(functions) per class
public map[loc class, int methodCount] numberOfMethodsPerClass() {
	return (cl:numberOfMethods(cl, model1) | <cl,_> <- model1.containment, isClass(cl));
}

// number of fields (properties) in a class
public int numberOfFields(loc cl, M3 model) = size([ m | m <- model.containment[cl], isField(m)]);

// number of fields (properties) per class
public map[loc class, int fieldCount] numberOfFieldsPerClass(){
	return (cl:numberOfFields(cl, model1) | <cl,_> <- model1.containment, isClass(cl));
}

// ratio per class
public map[loc class, real fieldCount] ratio(){
	fieldsPC = numberOfFieldsPerClass();
	methodsPC = numberOfMethodsPerClass();
    return (cl : (fieldsPC[cl] * 1.0) / (methodsPC[cl] * 1.0) | cl <- classes(model1));
}

public str methodSrc = readFile(|java+method:///test_project/Cars/HelloWorld/count(java.lang.String)|);

public void methodSrc1(str methodfromFile){
	println(meth);
}

public str wordsInMethod(str methodfromFile){
	int words = (0 | it + 1 | /\W+/ := methodSrc);
	str mess = "The number of words is <words>";
	return(mess);
}

// list with all the java files in the carProjectLocation
// public list[loc] carProject() {
//	return crawl(carProjectLocation, ".java");
//}

// cars.java location
public loc carProject = |project://test_project//src//test_project/Cars.java|;

// function that prints the lines of codes in the cars.java file
public void showLines(){
	map[str,int] projectVolumeValues = countLines(carProject);
	int codeLines = projectVolumeValues["lines"]-(projectVolumeValues["comments"] + projectVolumeValues["emptylines"]);
	println("Lines in Cars.java: <projectVolumeValues["lines"]>\nLines of pure code: <codeLines>\nLines of comments: <projectVolumeValues["comments"]>\nEmpty Lines: <projectVolumeValues["emptylines"]>");
}

public map[str,int] countLines(loc carProjectLoc) {

	map[str,int] results = ();
	
	results["lines"] 		= 0;
	results["comments"]		= 0;
	results["emptylines"]	= 0;
	int linesOfCom 			= 0;			
	
		for (line <- readFileLines(carProjectLoc)) {
		
			results["lines"] += 1;
			
			// checks for one line comments
			if(startsWith(line,"//") || contains(line,"//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))){
				results["comments"] += 1;
			}
			// checks for comments of more than one line
			else if (startsWith(trim(line),"/*") || linesOfCom>0){
				linesOfCom += 1;
				if (endsWith(trim(line),"*/")){
					results["comments"] += linesOfCom;
					linesOfCom = 0;
				}
			}
			// checks for empty lines
			else if(trim(line) == ""){
				results["emptylines"]+=1;
			}
		 }
	return results;
}
