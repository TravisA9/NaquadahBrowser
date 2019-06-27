# Plans for SML
 Although, the Sml is functioning and useful, there are some features planed for Sml that will make it much more powerful and still easier to use. I'm very excited about these future plans and hope to implement them as soon as I can. Here are a few examples:
 
 * Populate Templates with data.
 * Structured Attribute Shorthand.
 * More Shorthand.
 
 ## Populate Templates with data
 ```Scss
 // Warning: Details on this are still not decided!
 @MyNavbarButtons{ 
    Instances:["INFO" "TESTS" "IDEAS" "HOME"];
    padding:10; display:inline-block; margin:2; height:20;
    font{ color:steelblue; size:15; align:center; lineHeight:1.4; family:Georgia; vertical-align:middle;}
    hover{ color:0.99 0.5 0.5};
    Click{ "DoSomething()" };
    border{ radius:3; color:steelblue; style:solid; width:medium;}
 }
 
 div{
    @MyNavbarButtons
 }
 
 ```
 
  ## Structured Attribute Shorthand
 ```Scss
 // From this:
 border{ radius:15 15 3 3; width:thin; style:solid; color:#F9F9FA;}
 
 // To this:
 border: 15 15 3 3 thin solid #F9F9FA;
 ```
 
  ## More Shorthand
 ```Scss
  // From this:
 border{ color:#F9F9FA;}
 
 // To this:
 border-color:#F9F9FA;
 ```
 
  ## More Stuff
 ```Scss
 
 ```
