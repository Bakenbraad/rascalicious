package test_project;


public class Cars2 {
	public String a = "test \\ test";
    public String brand = null;
    public String model = null;
    public String color = null;
    

   
    public Cars2() {
    	HelloWorld h = new HelloWorld();
    	h.count("thest");
    }
    
    public void main() {
        int a = 11;
        int b = 6;
        int c = 4;


     }

    public Cars2(String theBrand, String theModel, String theColor) {
        this.brand = theBrand;
        this.model = theModel;
        this.color = theColor;
    }
    
    public class HelloWorld {
    	
    	public String s = "Test";
    	/*testing comments*/
    	public void count(String arg) {
        	int counter = 0;
        	int size = arg.length();
        	
        	for(int i = 0; i < size; i++)
        	{
        		counter ++;
        	}
        	
        	// TEST MOOI
        	/* blabla
        	  blabla
        	 */
        	
        	System.out.println(counter);
        }  
        
    	/*
    	 lala
    	 lala
    	 lala
    	 lala
    	 lala
    	 */
    	public int minFunction(int n1, int n2) {
    	   int min;/*huhu
    	   if (n1 > n2)
    	      min = n2;
    	   else
    	     */ min = n1;
    	
    	   return min; 
    	}
    }
	    /*
		 lala
		 lala
		 lala
		 lala
		 lala
		 */

}