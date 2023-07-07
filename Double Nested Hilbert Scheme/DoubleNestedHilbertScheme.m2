newPackage("DoubleNestedHilbertScheme",
           Version => "beta",
	   Date => "2023",
           Authors => {
	               {Name => "Michele Graffeo", Email => "michele.graffeo@polimi.it", HomePage => "http://https://graffeomichele.github.io//"}
    	              },
	   Headline => "Double nested Hilbert schemes of points on smooth curves"
	  )


--M={{2},{1,2,3},{0,1,3},{0,1,3},{0,1,3,5},{0,1,3,6},{0,1,3,6,7,8},{0,1,3,6,6,6}};
--O={{2},{0,0,3},{0,0,0},{0,0,3},{0,0,0,5},{0,0,0,0}};
--P={{2},{0,0,3},{0,0,0},{0,0,0},{0,0,0,5},{0,0,0,0}};
--P={{1},{1,2},{0,1,2},{0,0,1,2},{0,0,0,1,2},{0,0,0,1,1,1}};

8 components


--L={{1,2},{0,1}};

--N={{2},{1,2,3},{1,2,3}};

export{
"socle",
"subsocle",
"computeDimension",
"inizia",
"mossa",
"integrateDiagram",
"finished",
"rawList",
"isInHilbertScheme",
"genealogy"
}

------ COMPUTE SOCLES------

socle = d-> (
s :={((0,#d#0-1),d#0#(#d#0-1))};
for i from 1 to #d-1 do (
if #d#i>#d#(i-1) then s = append(s,((i,#d#i-1),d#i#(#d#i-1)));
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
s=append(s, ((l#(i+1)#0#0,l#i#0#1),d#(l#(i+1)#0#0)#(l#i#0#1)  ) ) ;
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
start=for i from 0 to #d-2 list for a in d#i list 0;
start = append (start, join({computeDimension (d)},for i from 0 to #(d#(#d-1))-2 list 0));
clearOutput;
return start;
)

-------- MOVE -----------


mossa = d->( 
spostati :={};
for l from 0 to #d-1 do( 

i:=#d-1-l;
for j from 0 to #(d#i)-1 do (if d#i#j !=0 then(

if #(d#i)>j+1 then (
A:=for k from 0 to i-1 list d#k;
v:= join( for h from 0 to j-1 list d#i#h,{d#i#j-1},{d#i#(j+1)+1}, for h from j+2 to #(d#i)-1 list d#i#h);
B:=for k from i+1 to #d-1 list d#k;
C:=join(A,{v},B);
spostati = append (spostati,C);
);

if #(d#(i-1))>j and i>0 then(
E:=for k from 0 to i-2 list d#k;
u:= join( for h from 0 to j-1 list d#(i-1)#h,{d#(i-1)#j+1}, for h from j+1 to #(d#(i-1))-1 list d#(i-1)#h);
w:= join( for h from 0 to j-1 list d#(i)#h,{d#(i)#j-1}, for h from j+1 to #(d#(i))-1 list d#(i)#h);
F:=for k from i+1 to #d-1 list d#k;
D:=join(E,{u,w},F);
spostati = append (spostati,D);
);
)));
clearOutput;
return spostati;
)

------- INTEGRATE DIAGRAM ------

integrateDiagram =d->(
convertito:={};
a:={d#(#d-1)#0};
for j from 1 to #(d#(#d-1))-1 do(
a=join(a,{d#(#d-1)#j+a#(j-1)});
);
convertito ={a};
for k from 1 to #d-1 do(
i:= #d-1-k;
b:={d#i#0+convertito#0#0};
for j from 1 to #(d#i)-1 do(
b=append(b,d#i#j+b#(j-1)+convertito#0#j-convertito#0#(j-1));
);
convertito= {b}|convertito;
);
clearOutput;
return convertito;
)


------ FINISHED ---------

finished = d->(
l:= for t in socle d list t#0;
print l;
a:=0;
for i from 0 to #d-1 do(
for j from 0 to #d#i-1 do(
if position(l,b->b==(i,j))===null then a=a+d#i#j;
)
);
if a == 0 then (clearOutput;  return true;) else (clearOutput; return false;) ;
)

------ rawList ---------

rawList = d->(
L:=d;
D:={};
for a in L do D= join(D , mossa a);
L=unique join(L,D);
if L== unique d then (clearOutput; return unique L;) else (clearOutput; return unique rawList(L););
)

------- isInHilbertScheme ----------

isInHilbertScheme = (a,b)->(
ver:=true;
if (( for c in a list #c)==(for c in b list #c))  then(
for i from 0 to #a-1 do(
for j from 0 to #(a#i)-1 do(
if a#i#j-b#i#j<0 then ver =false;
)
) 
) else ver =false;
return ver;
)


---------- isLeaf --------

isLeaf =(d,b)->(
if socle integrateDiagram d==socle b then (
F:= mossa d;
a:= for f in F list isInHilbertScheme (integrateDiagram f,b);
c:= for f in F list false;
if a==c then return true else return false;
--return true;
)
else return false;
)


------ GENEALOGY --------

genealogy = d->(
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


