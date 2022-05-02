function toggleMe(a){
        
    var e=document.getElementById(a);
            
        if(!e)return true;
        
        if(e.style.display=="block"){
            e.style.display="none"
        } else {
            e.style.display="block"
            
        }   
        
        return true;
}

function tFlag(a){

    var e=document.getElementById(a);
    
    if(!e)return true;
  
    if (a != 'closeall') {
        if((e.style.backgroundColor=="white") || (e.style.backgroundColor=="")) {
            e.style.backgroundColor="lightgreen";
        } else {
            e.style.backgroundColor="white";
        }
    }
   
    if (a == 'closeall') {
        var t=document.getElementsByTagName('a');
        var r=0;
        for (var vtag in t) {
           
             var regex =/(col|data)/;
               
             if (!t[vtag].id) {
             continue ;
             }

             if (t[vtag].id.match(regex)) {

                 t[vtag].style.backgroundColor='white';
             }
        }
    }

    var t=document.getElementById('klapptabelle');
   
    if(!t) return true;
    
    var r=0;
    while (row=t.rows[r++]) {
        
        var c=0;
        while (cell=row.cells[c++]) {

            var cc=0;
            var flag=true;

            while (vclass=cell.classList[cc++]) {

                var cl=document.getElementById(vclass);
   
                if (!cl) {
                 continue ;
                }

                if ((cl.style.backgroundColor != 'lightgreen')) {
                    flag=false;
                }
            }

            if (a != 'closeall') {
                if (flag) {
                    t.rows[r-1].cells[0].style.display='table-cell';
                    t.rows[r-1].cells[1].style.display='table-cell';
                    t.rows[r-1].cells[2].style.display='table-cell';
                    t.rows[r-1].cells[c-1].style.display='table-cell';
                }
                else {
                    t.rows[r-1].cells[c-1].style.display='none';
                }
            }
            else {
                    t.rows[r-1].cells[c-1].style.display='none';
            }

         var k=1;
        }
    }
    return true;
}
