# Plans for SML
 Although, the Sml is functioning and useful, there are some features planed for Sml that will make it much more powerful and still easier to use. I'm very excited about these future plans and hope to implement them as soon as I can. Here are a few examples:
 
 * Populate Templates with data.
 * Structured Attribute Shorthand.
 * More Shorthand.
 
 ## Populate Templates with data
 ```Scss
 // Warning: Details on this are still not decided!
 
    $BtnNames:"INFO" "TESTS" "IDEAS" "HOME";
 
 @MyNavbarButtons{ text:$BtnNames;
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
 The objective here would be that an template generate a button for each element in the```$BtnNames``` array. Likewise, if the template is structured, having element B nested in A, and A is passed an array of two items to populate it and B is passed an array of 1 item, something like the following structure would be generated in the final document:
 ```Scss
 div{ text:"A1";
     div{ text:"B"}
}
 div{ text:"A2";
     div{ text:"B"}
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
