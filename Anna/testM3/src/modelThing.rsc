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
set[Declaration] decls = createAstsFromEclipseProject(carProjectLocation, true);
public M3 model1 = createM3FromEclipseProject(carProjectLocation);
public set[loc] methods1 = methods(model1);

int calcCC(Statement impl) {
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

// number of methods(functions) in a class
public int numberOfMethods(loc cl, M3 model) = size([ m | m <- model.containment[cl], isMethod(m)]);

// number of methods(functions) per class
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
	str rank = "";
	int codeLines = projectVolumeValues["lines"]-(projectVolumeValues["comments"] + projectVolumeValues["emptylines"]);
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
	println("Lines in Cars.java: <projectVolumeValues["lines"]>\nLines of pure code: <codeLines>\nLines of comments: <projectVolumeValues["comments"]>\nEmpty Lines: <projectVolumeValues["emptylines"]>");
	println("\nRank: <rank>");
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
			if(startsWith(trim(line),"//") || contains(line,"//") || (startsWith(trim(line),"/*") && endsWith(trim(line),"*/"))){
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

/* public set[list[str]] allSixLines(loc carProjectLoc){
	list[str] sixLines = [];
	int i 		= 0;
	// int curLine = 1;
	bool firstTime = true;
	blocks		= {};
	for (line <- readFileLines(carProjectLoc)) {
		// curLine +=1;
		if(i<6){
			if(trim(line)!=""){
				sixLines += line;
				i+=1;
			}
		}
		else{
			if (firstTime){
				blocks += sixLines;
				firstTime = false;
			}
			else{
				sixLines = drop(1, sixLines);
				sixLines += line;
				blocks += sixLines;
			}
			
		}
	}
	return blocks;
}

public void showSix(){
	// int dup	= 0;
	int a = 0;
	blocks1 = allSixLines(carProject);
	// for(i<- blocks1){
		// for (j <- [size(blocks1)..i]){
			// if(blocks1[i]==blocks1[j]){ 
				//dup +=1;
			//}
		// }
		dups = [ y | y <-blocks1, size(blocks1[y])>1];
		a += 1;
		println("<dups>\n\n");
	//}
	// println("<dup>");
}*/