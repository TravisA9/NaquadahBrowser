.Thumbnail{ margin:100 10 100 10; align:center;
    div{ align:center; margin:10; width:200; height:200; color:#1b4f72; display:inline-block;
        border{ radius:3 5 5 3; width:thin; style:solid; color:white;}
        img{ width:200; height:150; color:lightgreen;}
        div{ padding:5;
            font{ color:black; size:16; align:center; weight:bold; family:arial;}}
        hover{ color:0.8 0.8 0.8; }
    }
}



body{ color:#F9F9FA; align:center;
    title:"New Tab";
    // Search bar.
div{ align:center;
    // Search Bar
    div{ align:center; width:450; display:inline-block; padding:50;
        padding:10; margin:4 50 4 50; color:0.9 0.9 0.9;
        border{ radius:20; width:thin; style:solid; color:0.3 0.3 0.3;}
        img{ margin:3 3 3 3; display:inline-block;
            width:15; height:15; image:"Search.png";
        }
        div{ display:inline;  align:center;
            text:"What are you searching for today?";
            font{ color:grey; size:15; align:center; family:sans;}
        }
    }


// Thumbnails
div{  class:Thumbnail;

    div{ color:#e74c3c; img{ image:"seat.png";}
        div{ text:"Place Your Ad Here"; }
    }
    div{ color: #9b59b6 ; img{ image:"beanflower.png";}
        div{ text:"Have Your Own Sml Website"; }
    }
    div{ color:#3498db; img{ image:"water.png";}
        div{ text:"Show Up Where Everyone Will See"; }
    }
    div{ color:#1abc9c; img{ image:"Mountains.png";}
        div{ text:"This is the title!"; }
    }
    div{ color:#f4d03f; img{ image:"bannana.png";}
        div{ text:"This is the title!"; }
    }
    div{ color:#e67e22; img{ image:"fruit.png";}
        div{ text:"This is the title!"; }
    }

}

}
// footer
div{ color:#f9e79f; height:50; padding:10; position:fixed;
    bottom:0; left:0;
    div{ text:"This is the title!"; }
}



p{ position:fixed; color:0.0 0.0 0.0; opacity:0.8;
bottom:60; right:10; height:50; width:150; margin:3;
border{ radius:7; width:thin; style:solid; color:black}
text:"This element has a \"FIXED\" position.";
font{ color:black; size:18; align:center; lineHeight:1.4; family:Georgia }
}

}
