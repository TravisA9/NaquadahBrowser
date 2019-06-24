.round-button{
    display:inline-block; margin:7; radius:12; color: 0.6 0.6 0.6
    hover{color: 0.8 0.8 0.8; }
    circle{ radius:12;}
}

div{ height:39; color:0.6 0.6 0.6; padding:2;
    circle{ class:round-button; circle{ image:"Back.png"} }
    circle{ class:round-button; circle{ image:"Forward.png"} }
    circle{ class:round-button; circle{ image:"Start.png"} }
    circle{ class:round-button; float:right; circle{ image:"Download.png"} }
    circle{ class:round-button; circle{ image:"Back.png"} }

    div{ marked:true; display:inline-block; height:22;
        padding:3 4 3 3; margin:4 4 4 4; color:0.9 0.9 0.9;
    border{ radius:15 15 3 3; width:thin; style:solid;color:0.3 0.3 0.3;}
        div{ margin:3 3 3 3; display:inline-block;
            width:15; height:15; image:"Search.png"; color:lightgreen;
        }
        div{display:inline; text:"file:///src/SamplePages/test.sml";
            font{ color:black; size:15; align:left; lineHeight:1.4; family:sans;}
        }
    }
}
