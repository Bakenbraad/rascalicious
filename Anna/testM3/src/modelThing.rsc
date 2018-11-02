module modelThing
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;
import List;


public M3 model1 = createM3FromEclipseProject(|project://test_project|);
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

