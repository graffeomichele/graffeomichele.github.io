newPackage("DoubleNestedHilbertScheme",
           Version => "beta",
	   Date => "2023",
           Authors => {
	               {Name => "Michele Graffeo", Email => "michele.graffeo@polimi.it", HomePage => "http://https://graffeomichele.github.io//"}
    	              },
	   Headline => "Double nested Hilbert schemes of points on smooth curves"
	  )


--M={{0,1,3,6,6,6},{0,1,3,6,7,8},{0,1,3,6},{0,1,3,6},{0,1,3},{0,1,2},{2}};
--N={{0,1,3,6,6,6},{0,1,3,6,7,8},{0,1,3,6},{0,1,3,6},{0,1,3},{0,1,4},{2}};
--O={{2},{0,0,3},{0,0,0},{0,0,3},{0,0,0,5},{0,0,0,0}};
--P={{2},{0,0,3},{0,0,0},{0,0,0},{0,0,0,5},{0,0,0,0}};
--P={{0,0,0,1,1,1},{0,0,0,1,2},{0,0,1,2},{0,1,2},{1,2},{1}};



--L={{1,2},{0,1}};

--N={{2},{1,2,3},{1,2,3}};

export{
"socle",
"subsocle",
"computeDimension",
"inizia",
"mossa",
"integrateDiagram",
"isInHilbertScheme",
"genealogy",
"isLeaf",
"netRPP",
"isRPP"
}

------ COMPUTE SOCLES------

socle = d-> (
s :={((#d-1,#d#(#d-1)-1),d#(#d-1)#(#d#(#d-1)-1))};
for i from 1 to #d-1 do (
if #d#(#d-1-i)>#d#(#d-i) then s = {((#d-1-i,#d#(#d-1-i)-1),d#(#d-1-i)#(#d#(#d-1-i)-1))}|s;
);
clearOutput;
return s;
)



------ COMPUTE SUBSOCLES------

subsocle= d->(
s:={};
l:=socle(d);
if #l > 1 then(
for i from 0 to #l-2 do
(
s=append(s, ((l#(i)#0#0,l#(i+1)#0#1),d#(l#(i)#0#0)#(l#(i+1)#0#1)  ) ) ;
)
);
clearOutput;
return s;
)


------ COMPUTE DIMENSION -------

computeDimension = d->(
dimension :=0;
for l in socle(d) do dimension=dimension+l#1;
for l in subsocle(d) do dimension=dimension-l#1;
clearOutput;
return dimension ;
)



------INITIALIZE ALGORITHM------


inizia = d-> (
start :={};
start=for i from 1 to #d-1 list for a in d#i list 0;
start = {join({computeDimension (d)},for i from 0 to #(d#0)-2 list 0)}| start;
clearOutput;
return start;
)

-------- MOVE -----------


mossa = d->( 
spostati :={};
for i from 0 to #d-1 do( 

for j from 0 to #(d#i)-1 do (if d#i#j !=0 then(

if #(d#i)>j+1 then (
A:=for k from 0 to i-1 list d#k;
v:= join( for h from 0 to j-1 list d#i#h,{d#i#j-1},{d#i#(j+1)+1}, for h from j+2 to #(d#i)-1 list d#i#h);
B:=for k from i+1 to #d-1 list d#k;
C:=join(A,{v},B);
spostati = append (spostati,C);
);

if i<#d-1 then(
if #(d#(i+1))>j then(
E:=for k from 0 to i-1 list d#k;
u:= join( for h from 0 to j-1 list d#(i)#h,{d#(i)#j-1}, for h from j+1 to #(d#(i))-1 list d#(i)#h);
w:= join( for h from 0 to j-1 list d#(i+1)#h,{d#(i+1)#j+1}, for h from j+1 to #(d#(i+1))-1 list d#(i+1)#h);
F:=for k from i+2 to #d-1 list d#k;
D:=join(E,{u,w},F);
spostati = append (spostati,D);
);
);
)));
clearOutput;
return spostati;
)

------- INTEGRATE DIAGRAM ------

integrateDiagram =d->(
convertito:={};
a:={d#0#0};
for j from 1 to #(d#0)-1 do(
a=join(a,{d#0#j+a#(j-1)});
);
convertito ={a};
for i from 1 to #d-1 do(
b:={d#i#0+convertito#(i-1)#0};
for j from 1 to #(d#i)-1 do(
b=append(b,d#i#j+b#(j-1)+convertito#(i-1)#j-convertito#(i-1)#(j-1));
);
convertito= convertito|{b};
);
clearOutput;
return convertito;
)

------ netRPP ------

netRPP =d->(
 a:="";
b:=for c in d#0 list length toString c;
for i from 1 to #d-1 do (
for j from 0 to #(d#i)-1 do (
if length toString d#i#j> b#j then b=join(for l from 0 to j-1 list b#l,{length toString d#i#j},for l from j+1 to #b-1 list b#l);
);
);
for c in b do( 
u:="+"|concatenate(for i from 1 to c list "-");
a= concatenate(a,u) ) ;
a=a|"+\n";
for i from 0 to #d-1 do(
for j from 0 to  #(d#i)-1 do a= a|"|"|toString d#i#j|concatenate(for i from 1 to b#j - length toString d#i#j list " ");
a=a|"|\n";
for k from 0 to #(d#i)-1 do( 
u:="+"|concatenate(for i from 1 to b#k list "-");
a= concatenate(a,u) ) ;
a=a|"+\n";
);
return a;

)


------- isInHilbertScheme ----------

isInHilbertScheme = (a,b)->(
if isRPP a and isRPP b then(
ver:=true;
if (( for c in a list #c)==(for c in b list #c))  then(
for i from 0 to #a-1 do(
for j from 0 to #(a#i)-1 do(
if a#i#j-b#i#j<0 then ver =false;
)
) 
) else ver =false;
return ver;)
else(
print  "ERROR: it is not a RPP";
return null;
);
)


---------- isLeaf --------

isLeaf =(d,b)->(
if socle integrateDiagram d==socle b then (
F:= mossa d;
a:= for f in F list isInHilbertScheme (integrateDiagram f,b);
c:= for f in F list false;
if a==c then return true else return false;
)
else return false;
)


------ GENEALOGY --------

genealogy = d->(
if isRPP d then(
graph:={};
irrcomp:={};
Q:={inizia d};
while #Q>0 do(
D:= first Q;
Q=delete(D,Q);
F:=mossa D;
for f in F do(
if isInHilbertScheme(integrateDiagram f,d)==true then(
graph =graph | {(D,f)};
Q=Q | {f};
);
);
if isLeaf(D,d)==true then irrcomp=irrcomp | {D};
);
return (graph,irrcomp);
)
else(
print  "ERROR: it is not a RPP";
return (null, null);
);
)


-------- isRPP -------

isRPP = d->(

itis:=true;
if  (class d) =!=List  then itis =false else if ((unique for a in d list (class a))=!={List} ) then itis =false;
for i from 1 to #d-1 do(
if  d#i#0<d#(i-1)#0  then itis =false;
);
for i from 1 to #d#0-1 do(
if  d#0#i<d#0#(i-1)  then itis =false;
);
for i from 1 to #d-1 do(
for j from 1 to #(d#i)-1 do(
if  (d#i#j< d#(i-1)#j or d#i#j< d#i#(j-1))  then itis=false ;
)
);
return itis;
)

