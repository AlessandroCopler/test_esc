#!/bin/bash
#CONFIGURAZIONE 2 : controllo del commit, cerco la/le parole chiavi per avviare i moduli corretti 

#-q : per controllare lo stato dopo
#-i : non controlla se minusco o maiuscola
# manca il controllo che ha sbagliato il commit non farà nessuna di queste voci 

#vettore dei possibili moduli   
moduli=(nova swift horizon)

#vettore degli URL dei vari progetti da eseguire 
link=( http://localhost:8081/job/NovaConf2/build?token=nova http://localhost:8081/job/SwiftConf2/build?token=swift http://localhost:8081/job/HorizonConf2/build?token=horizone )

#inizializzazione indice per le scansioni
i=0

#inizializzazione del vettore che contiene i moduli trovati
temp=( null null null )

VBoxManage unregistervm horizon-clone --delete
VBoxManage unregistervm nova-clone --delete
VBoxManage unregistervm swift-clone --delete
sudo rm -rf ~/VirtualBox\ VMs/horizon-clone
sudo rm -rf ~/VirtualBox\ VMs/nova-clone
sudo rm -rf ~/VirtualBox\ VMs/swift-clone
vagrant snapshot delete snap1
vagrant up manager
name_vm=$(VBoxManage list runningvms | cut -d '"' -f2)
vagrant snapshot take snap1
vagrant ssh manager <<END
ls -a
sudo shutdown -h now
END
sleep 120
#VBoxManage controlvm $name_vm acpipowerbutton

# continua fino a quando $i e uguale a 2
while [ $i -le 2 ]; do 
	#cerca nel commit la corrispondenza con il modulo in posizione i
	git log -1 | tail -1 | grep -q -i "${moduli[i]}"
	#verifica dello stato attuale: se trova la corrispondenza del modulo entra nel if altrimenti va al modulo successivo
	if [ $? -eq 0 ] 
	then 
		#salvo i moduli che ha trovato per poi eseguirli solo alla fine 
		temp[i]=${moduli[i]}
		i=$((i+1))
	else 
		i=$((i+1))

	fi
done
i=0

#flag che permette di capire se e stato trovato almeno un modulo 
flag=0

#avvio i test specifici
#continua fino a quando trova uno null,temp è stato inizializzato cn tutti null
while [ $i -le 2 ]; do
	if [ ${temp[i]} != null ]
	then
		name_clone="${temp[i]}-clone"
		flag=1
		VBoxManage clonevm $name_vm --snapshot snap1 --mode machineandchildren --name $name_clone --register		
		echo "avvia test: ${temp[i]}"
		sleep 120
		curl -L ${link[i]}
		i=$((i+1))
	else
		i=$((i+1))
	fi
done

i=0

#controllo che abbia torvato almeno un modulo altrimenti significa che deve avviarli tutti
if [ $flag -eq 0 ]
then
	#avvio tutti i test
	while [ $i -le 2 ]
	do
		name_clone="${moduli[i]}-clone"
		VBoxManage clonevm $name_vm --snapshot snap1 --mode machineandchildren --name $name_clone --register
		echo "avvia test: ${moduli[i]}"
		sleep 120
		curl -L ${link[i]}
		i=$((i+1))
	done
fi
exit 0
