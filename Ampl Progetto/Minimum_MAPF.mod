### SET ###
set NODI;
set ARCHI within NODI cross NODI;
set ARCHI_BIDIREZIONALI = ARCHI union setof{(i,j) in ARCHI} (j,i);

### PARAMETRI ###
param Agenti >0, integer;
param Origine{1..Agenti} symbolic in NODI;
param Destinazione{1..Agenti} symbolic in NODI;
param Limite_Percorso >0, integer;


### VARIABILI ###
# risulta 1 se l'arco viene utilizzato da un agente ad un istante temporale nel suo percorso minimo 
var ArcoUtilizzato{1..Agenti, 1..Limite_Percorso, ARCHI_BIDIREZIONALI} binary; 


### VINCOLI ###
# all'istante temporale t=1 ogni agente parte dal suo nodo di partenza
subject to nodo_Partenza{a in 1..Agenti}: 
	sum{(i,j) in ARCHI_BIDIREZIONALI: i = Origine[a]} ArcoUtilizzato[a,1, i, j] = 1;

# quando in un istante temporale t, n agenti entrano in un nodo, allora all'istante t+1 n agenti usciranno da quel nodo
subject to vincolo_Flusso{a in 1..Agenti, t in 1..Limite_Percorso, k in NODI:(t!=1 || k!=Origine[a]) && (t==1 || k!=Destinazione[a]) && t!=Limite_Percorso}: 
	sum{(i, k) in ARCHI_BIDIREZIONALI} ArcoUtilizzato[a,t,i,k] = sum{(k, j) in ARCHI_BIDIREZIONALI} ArcoUtilizzato[a,t+1, k, j];
	
	
# più agenti non possono utilizzare lo stesso arco allo stesso tempo
subject to overlap_Agenti{(k,t) in NODI cross (1..Limite_Percorso)}: 
	sum{a in 1..Agenti} sum{(i,k) in ARCHI_BIDIREZIONALI} ArcoUtilizzato[a,t,i,k] <= 1;


# se un agente utilizza un arco (i,j) nell'istante t, un altro agente non potrà usare l'arco(j,i) al medesimo istante
subject to collisioni_Agenti{a in 1..Agenti, t in 1..Limite_Percorso, (i,j) in ARCHI_BIDIREZIONALI}:
	ArcoUtilizzato[a, t, i, j] + sum{a2 in 1..Agenti: a2!=a} ArcoUtilizzato[a2, t, j, i] <= 1;


### OBIETTIVO ###
# minimizzare la somma dei cammini minimi di tutti gli agenti
minimize costoTot_Percorso: sum{a in 1..Agenti} sum{t in 1..Limite_Percorso} sum {(i,j) in ARCHI_BIDIREZIONALI} ArcoUtilizzato[a,t,i,j];