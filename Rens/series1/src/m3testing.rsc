module m3testing
import List;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;

// The model created from the eclipse project.
public M3 myModel = createM3FromEclipseProject(|project://test_project|);

// Counts the methods in the model (Functions inside of a class)
public int methodCount () {
	helloWorldMethods = [ e | e <- myModel.containment[|java+class:///test_project/Cars|], e.scheme == "java+method"];
	return size(helloWorldMethods);
}

// Counts the amount of fields/methods in a given class (cl).
int numberOfMethods(loc cl, M3 model) = size([ m | m <- model.containment[cl], isMethod(m)]);
int numberOfFields(loc cl, M3 model) = size([ m | m <- model.containment[cl], isField(m)]);

// Gives a map of all classes with their amount of methods.
public map[loc class, int methodCount] numberOfMethodsPerClass() {
	return (cl:numberOfMethods(cl, myModel) | <cl,_> <- myModel.containment, isClass(cl));
}

// Gives a map of all classes with their amount of fields (properties)
public map[loc class, int fieldCount] numberOfFieldsPerClass() {
	return (cl:numberOfFields(cl, myModel) | <cl,_> <- myModel.containment, isClass(cl));
}

// Counts all methods combined for all of the classes.
public int methodCount () {
	helloWorldMethods = [ e | e <- myModel.containment[|java+class:///test_project/Cars|], e.scheme == "java+method"];
	return size(helloWorldMethods);
}

public map[loc class, real fieldCount] classToMethodRatio() {
	// Retrieve the lists from the functions.
	fieldlist = numberOfFieldsPerClass();
	methodlist = numberOfMethodsPerClass();
	
	// Calculate the ratio for each class.
	return (cl : (fieldlist[cl] * 1.0) / (methodlist[cl] * 1.0) | cl <- classes(myModel));
}

