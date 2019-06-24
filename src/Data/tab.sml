
div{ display:inline-block; height:21; padding:3;
        width:100; color:0.6 0.6 0.6; margin:0 1 0 0;
        border{ radius:7 0 0 3; width:0 2 0 0; style:solid; color:0.2 0.6 0.99;}
 	    click:"println(\"You clicked me!\")";

        circle{ display:inline-block; margin:2; radius:8; color:pink;
            image:"Atlantis.png";
        }
        div{ display:inline-block; text:"Tab!";
            font{ color:black; size:15; align:left; lineHeight:1.4; family:sans;}}
        circle{ display:inline-block; position:absolute; right:0;
            top:5; radius:5; image:"close.png";
        }
}
