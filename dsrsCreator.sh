#!/bin/bash
# Use this script to setup multiple DS 7.x.x servers in replication and initialize
#
# Created on 08/Dec/2021
# Author = G.Nikolaidis
# Version 1.00
#
# Before execuete the script make sure you have installed Java version 11 or later
# the unzip and netstat utility
# include the DS-7.x.x.zip in the same directory where you execute the script
# chmod 755 the script to make it executable and execute it as root or sudo
# execute with command line argument the number of DS to deploy: ./replDS 3


clear
noOfServers=$1



# Settings
# !!! important !!!
# you MUST change the below settings to meet your installation requirments!
#
#Destination path will be in the format /opt/ds7xRepl0, /opt/ds7xRepl1, /opt/ds7xRepl2, /opt/ds7xRepl3, /opt/ds7xReplx ...
destPath=~/ds720RepTest

#DS version, if the verison is between 7.0.x and 7.1.x enter 1 else for ds version 7.2.x and on enter 2
dsVersion=2


#Stand alone servers 1) for stand alone servers DS RS, 2) for DS/RS servers
standAlone=2

#hostname will be in format rep0.example.com, rep1.example.com, rep2.example.com, repx.example.com
hostName=rep
domain=.example.com

#serverId will be in the format MASTER0, MASTER1, MASTER2, MASTERx
serverId=MASTER


#installationProfile=ds-evaluation
generateUsers=10000

#change the name of the zip file to install
#password to be used: Password1
installationZipFile=DS-7.2.0.zip
installationPassword=Password1

#Default protocol ports to be used
#on each additional server the port will be +1 ie. server0 ldapPort:1389, server1 ldapPort:1390, server2 ldapPort:1391 etc
#ldaps port server0 ldapsPort:1686, server1 ldapsPort:1687 etc
ldapPort=1389
ldapsPort=1636
httpsPort=8443
replPort=8989
adminPort=4444


dsEval="--profile ds-evaluation --set ds-evaluation/generatedUsers:$generateUsers "
dsAmCtsAmReap="--profile am-cts --set am-cts/amCtsAdminPassword:5up35tr0ng "
dsAmCtsSes="--profile am-cts --set am-cts/amCtsAdminPassword:5up35tr0ng --set am-cts/tokenExpirationPolicy:am-sessions-only "
dsAmCtsDs="--profile am-cts --set am-cts/amCtsAdminPassword:5up35tr0ng --set am-cts/tokenExpirationPolicy:ds "
dsAmConfig="--profile am-config --set am-config/amConfigAdminPassword:5up35tr0ng "
dsAmIdentities="--profile am-identity-store --set am-identity-store/amIdentityStoreAdminPassword:5up35tr0ng "

#Default installation profile
installationProfile=$dsEval

# Path of the first installed server
#
setupPath=${destPath}0/opendj
binPath=$setupPath/bin/




tput civis

# Functions
#
progressBar()
{
sleepTime=$1
while ps |grep $! &>/dev/null; do
        printf '▇'
        #printf '\u2589'
        sleep ${sleepTime}
done
printf "\n"
}



unzipMessage()
{
if [ $? -eq 0 ];then
        printf "extraction successful..Done\n"
else
        printf "something went wrong while extracting the file!\n"
        printf "check your file might be corrupted, re download it.\n"
        printf "Installation failed!"
        tput cnorm
	exit -1
fi
}


setupMessage()
{
if [ $? -eq 0 ];then
        printf "setup DS successful..Done\n"
else
        printf "something went wrong while setup!\n"
        printf "Installation failed!"
        tput cnorm
	exit -1
fi
}


initialiseRepMessage()
{
if [ $? -eq 0 ];then
        printf "initialise replication successful..Done\n"
else
        printf "something went wrong while initialise replication!\n"
        printf "Installation failed!"
        tput cnorm
	exit -1
fi
printf "\n"
}

selectProfile()
{
profile=$1
case "$1" in
1) installationProfile=$dsEval
   ;;
2) installationProfile=$dsAmCtsAmReap
   ;;
3) installationProfile=$dsAmCtsSes
   ;;
4) installationProfile=$dsAmCtsDs
   ;;
5) installationProfile=$dsAmConfig
   ;;
6) installationProfile=$dsAmIdentities
   ;;
*)
   ;;
esac
}

selectVersion()
{
dsVersion=$1
case "$1" in
1) installationProfile=$dsEval
   ;;
2) installationProfile=$dsAmCtsAmReap
   ;;
*)
   ;;
esac
}

# Start
#

#Check the number or replication servers to be installed
#Max number is set to 8 (this number can be changed)
#
if [[ $noOfServers -lt 2 ]]
then
	printf "The number of servers joining replication must be more that 1!\nPlease execute the script with command line argument like ./repDS 3\nwhere 3 is the number of DS to deploy, min=2 max=8.\n"
	tput cnorm
	exit -1
fi
if [[ $noOfServers -gt 8 ]]
then
	printf "The number of installing servers will be very high and resources will be not enough!\n"
	tput cnorm
	exit -1
fi


printf "      Topology Creator\n"
printf "*****************************\n"
printf "\n"

printf "Please select DS family:\n"
printf "*****************************\n"
printf "1. DS 5.x - DS 6.x\n"
printf "2. DS 7.0.x - DS 7.1.x\n"
printf "3. DS 7.2.x - DS 7.3x and up\n"
printf "Enter your choise: "
read dsFamily
printf "\n"
while [[ "$dsFamily" != "1" && "$dsFamily" != "2" && "$dsFamily" != "3" ]]
do
	clear
  printf "Please select DS version:\n"
  printf "*****************************\n"
  printf "1. DS 5.x - DS 6.x\n"
  printf "2. DS 7.0.x - DS 7.1.x\n"
  printf "3. DS 7.2.x - DS 7.3x and up\n"
  printf "Enter your choise: "
  read dsFamily
done

clear

case "$dsFamily" in
1) printf "Please select DS version:\n"
   printf "*************************\n"
   printf "1. DS 5.0.0\n"
   printf "2. DS 5.5.0\n"
   printf "3. DS 5.5.1\n"
   printf "4. DS 5.5.2\n"
   printf "5. DS 5.5.3\n"
   printf "6. DS 6.0.0\n"
   printf "7. DS 6.5.0\n"
   printf "8. DS 6.5.1\n"
   printf "9. DS 6.5.2\n"
   printf "10. DS 6.5.3\n"
   printf "11. DS 6.5.4\n"
   printf "12. DS 6.5.5\n"
   printf "13. DS 6.5.6\n"
   printf "Enter your choise: "
   read dsVersion
   printf "\n"
   while [[ "$dsVersion" != "1" && "$dsVersion" != "2" && "dsVersion" != "3" && "$dsVersion" != "4" && "dsVersion" != "5" && "$dsVersion" != "6" && "dsVersion" != "7" && "$dsVersion" != "8" && "dsVersion" != "9" && "dsVersion" != "10" && "$dsVersion" != "11" && "dsVersion" != "12" && "$dsVersion" != "13" ]]
   do
      clear
      printf "Please select DS version:\n"
      printf "*************************\n"
      printf "1. DS 5.0.0\n"
      printf "2. DS 5.5.0\n"
      printf "3. DS 5.5.1\n"
      printf "4. DS 5.5.2\n"
      printf "5. DS 5.5.3\n"
      printf "6. DS 6.0.0\n"
      printf "7. DS 6.5.0\n"
      printf "8. DS 6.5.1\n"
      printf "9. DS 6.5.2\n"
      printf "10. DS 6.5.3\n"
      printf "11. DS 6.5.4\n"
      printf "12. DS 6.5.5\n"
      printf "13. DS 6.5.6\n"
      printf "Enter your choise: "
      read dsVersion
   done
   ;;
2) printf "Please select DS version:\n"
   printf "*************************\n"
   printf "1. DS 7.0.0\n"
   printf "2. DS 7.0.1\n"
   printf "3. DS 7.0.2\n"
   printf "4. DS 7.1.0\n"
   printf "5. DS 7.1.1\n"
   printf "6. DS 7.1.2\n"
   printf "7. DS 7.1.3\n"
   printf "8. DS 7.1.4\n"
   printf "9. DS 7.1.5\n"
   printf "10. DS 7.1.6\n"
   printf "Enter your choise: "
   read dsVersion
   printf "\n"
   while [[ "$dsVersion" != "1" && "$dsVersion" != "2" && "dsVersion" != "3" && "$dsVersion" != "4" && "dsVersion" != "5" && "$dsVersion" != "6" && "dsVersion" != "7" && "$dsVersion" != "8" && "dsVersion" != "9" && "dsVersion" != "10" ]]
   do
     clear
     printf "Please select DS version:\n"
     printf "************************\n"
     printf "1. DS 7.0.0\n"
     printf "2. DS 7.0.1\n"
     printf "3. DS 7.0.2\n"
     printf "4. DS 7.1.0\n"
     printf "5. DS 7.1.1\n"
     printf "6. DS 7.1.2\n"
     printf "7. DS 7.1.3\n"
     printf "8. DS 7.1.4\n"
     printf "9. DS 7.1.5\n"
     printf "10. DS 7.1.6\n"
     printf "Enter your choise: "
     read dsVersion
  done
   ;;
*)
   ;;
esac







printf "\n"



#selectVersion $dsVersion
#printf "Selection is:$dsVersion"
clear

printf "Select type of Servers:\n"
printf "***********************\n"
printf "1. Stand Alone DS RS\n"
printf "2. Non Stand Alone DS/RS\n"
printf "Enter your choise: "
read standAlone
printf "\n"
while [[ "$standAlone" != "1" && "$standAlone" != "2" ]]
do
	clear
  printf "Select type of Servers:\n"
  printf "***********************\n"
  printf "1. Stand Alone DS RS\n"
  printf "2. Non Stand Alone DS/RS\n"
  printf "Enter your choise: "
  read standAlone
done

clear

if [[ $standAlone -eq 1 ]]; then

  printf "Select number of Servers:\n"
  printf "*************************\n"
  printf "Number of stand alone DS:"
  read dsNumber
  while [[ $dsNumber -lt 0 || $dsNumber -gt 8 ]]
  do
    clear
    printf "Number of stand alone DS:"
    read dsNumber
  done


  printf "Number of stand alone RS:"
  read rsNumber
  while [[ $rsNumber -lt 0 || $rsNumber -gt 8 ]]
  do
    clear
    printf "Number of stand alone RS:"
    read rsNumber
  done
fi

clear

printf "Please select profile\n"
printf "***********************************************************\n"
printf "1. Evaluation\n"
printf "2. AM CTS (AM reaper manages all token expiration)\n"
printf "3. AM CTS (AM reaper manages only SESSION token expiration)\n"
printf "4. AM CTS (DS manages all token expiration)\n"
printf "5. AM Configuration\n"
printf "6. AM identities\n"
printf "7. IDM Repository\n"
printf "Enter your choise: "
read dsProfile
printf "\n"
while [[ "$dsProfile" != "1" && "$dsProfile" != "2" && "$dsProfile" != "3" && "$dsProfile" != "3" && "$dsProfile" != "4" && "$dsProfile" != "5" && "$dsProfile" != "6" && "$dsProfile" != "7" ]]
do
	clear
	printf "Please select profile\n"
	printf "***********************************************************\n"
	printf "1. Evaluation\n"
	printf "2. AM CTS (AM reaper manages all token expiration)\n"
	printf "3. AM CTS (AM reaper manages only SESSION token expiration)\n"
	printf "4. AM CTS (DS manages all token expiration)\n"
	printf "5. AM Configuration\n"
	printf "6. AM identities\n"
  printf "7. IDM Repository\n"
	printf "Enter your choise: "
        read dsProfile
done

selectProfile $dsProfile

# check for Java environment
#
printf "Checking for Java environment..\n"
#printf "Java version: "; java -version 2>&1 |grep "version" | awk '{print $3}'
javaVer=`java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1`

if [[ $javaVer -lt 11 ]];then
        printf "You need to install Java version 11\n"
        printf "Execute sudo yum install java-11-openjdk\n"
        printf "Installation failed!\n"
        tput cnorm
	exit -1
else
        jdkVersion=`java -version 2>&1 |grep "version" | awk '{print $3}'`
        printf "compatible Java version $jdkVersion..Done\n"
fi




# Check if netstat is installed and then check all the ports to avoid conflicts..
#
#netstat -V &>/dev/null
which lsof

if [ $? -eq 0 ];then
        printf "lsof utility found..Done\n"
else
        printf "lsof utility not found, please use sudo yum/apt/brew install lsof\n"
        printf "installation aborted!\n"
        tput cnorm
	exit -1
fi


#lsof -nP -itcp -stcp:listen |grep "TCP *" |awk {'print $9'}|cut -c3-
#lsof -nP -itcp:5000 -stcp:listen|grep "TCP" |awk {'print $9'}|cut -c3-|head -1

checkPorts()
{
 portCheck=$1
 noOfDS=$2
 for (( i=0; i<$noOfDS; i++ ))
 do
   result=`lsof -nP -itcp:$portCheck -stcp:listen|grep "TCP" |awk {'print $9'}|cut -c3-|head -1`
   if [ "$result" == "$portCheck" ];then
     printf "Port $portCheck exists and there will be conflict!\n"
     printf "installation aborted!\n"
     tput cnorm
		 exit -1
   else
     printf "Checking port: $portCheck ..Done\n"
  fi
	((portCheck++))
 done
}

#checkPorts()
#{
# portCheck=$1
# noOfDS=$2
# for (( i=0; i<$noOfDS; i++ ))
# do
#	result=`netstat -tulpn |grep -w $portCheck| awk {'print $4'} |cut -c4-`
#        result=`netstat -tulpn |grep -o -m 1 $portCheck`
#        if [ "$result" == "$portCheck" ];then
#                printf "Port $portCheck exists and there will be conflict!\n"
#                printf "installation aborted!\n"
#                tput cnorm
#		exit -1
#        else
#                printf "Checking port: $portCheck ..Done\n"
#        fi
#	((portCheck++))
# done
#}

for j in $ldapPort $ldapsPort $httpsPort $replPort $adminPort
do
	printf "Checking protocol port: $j\n"
	checkPorts $j $noOfServers
done





#Check for existing directories
#Create new directories if there are none existing
#
for (( k=0; k<$noOfServers; k++ ))
do
        if [ -d $destPath${k} ];then
                echo; printf "Directory already exists, please delete or rename it\n"
                printf "Installation abort!\n"
                tput cnorm
                exit -1
        else
                printf "Creating directory $destPath${k}...\n"
                mkdir $destPath${k}
                if [ $? -eq 0 ];then
                        printf "Created successful..Done\n"
                else
                        printf "Can not create directory $destPath${k} check the directory permissions!\n"
                        printf "Installation failed!\n"
                        tput cnorm
                        exit -1
                fi
        fi
done



# Check if unzip utility exists
#
echo
printf "Checking for unzip utility...\n"
#unzipVer=`unzip -v 2>&1`
which unzip
if [ $? -eq 0 ];then
        printf "uzip util..Done\n"
else
        printf "Unzip utility is not installed, you need to install it\n"
        printf "Execute sudo yum install unzip\n"
        printf "Installation failed!\n"
        tput cnorm
	exit -1
fi



# Check if DS-7.x.x.zip file exist on the directory
#
printf "Checking for zip file..\n"
if [ -f "$installationZipFile" ];then
        printf "found,$installationZipFile..ok\n"
else
        printf "Can't find $installationZipFile file, please make sure to include\n"
        printf "the file on the same directory where you execute the script\n"
        printf "Installation failed!\n"
        tput cnorm
	exit -1
fi



# Unzip files to directories
#
printf "Unzipping files to directories...\n"
for (( dir=0; dir<$noOfServers; dir++ ))
do
        unzip $installationZipFile -d $destPath${dir} 2>&1 >/dev/null &
        progressBar 0
        unzipMessage
done




# Create deployment key
#
printf "creating DEPLOYMENT_KEY...please wait it might take some time..\n"
export installationPassword
if [ $dsVersion -eq 1 ];then
	$binPath./dskeymgr create-deployment-key --deploymentKeyPassword $installationPassword > $setupPath/DEPLOYMENT_KEY
else
	$binPath./dskeymgr create-deployment-id --deploymentIdPassword $installationPassword > $setupPath/DEPLOYMENT_KEY
fi

if [ $? -eq 0 ];then
        printf "creation successful..Done\n"
else
        printf "something went wrong creating the DEPLOYMENT_KEY!\n"
        printf "Installation failed!\n"
        tput cnorm
	exit -1
fi
deploymentKey=$(cat $setupPath/DEPLOYMENT_KEY |awk '{ print $1 }')
export deploymentKey
printf "DEPLOYMENT_KEY: $deploymentKey\n"




# Insert hostNames into /etc/hosts file
#
cp /etc/hosts /etc/hosts.backup
if [ $? -eq 0 ];then
        printf "backup /etc/hosts hosts.backup..Done\n"
else
        printf "backup /etc/hosts file hosts.backup..failed!\n"
        printf "must run as root\n"
        printf "installation..failed!\n"
        tput cnorm
	exit -1
fi

for (( name=0; name<$noOfServers; name++ ))
do
cat /etc/hosts |grep "$hostName${name}$domain"
if [ $? -eq 0 ];then
        printf "hostNames already exist on /etc/hosts..Done\n"
else
        sed -i "/127.0.0.1/ s/$/ $hostName${name}$domain/" /etc/hosts
fi

done
printf "insert hostNames into /etc/hosts..Done\n"





installationText()
{
# Create INSTALLATION text
#printf "Installation instructions..\n\n\n$setupCommand\n\n\n$setupCommand2\n\n\n$initReplication\n\n\nDEPLOYMENT_KEY:$deploymentKey\nPassword: $installationPassword\n" > $setupPath/INSTALLATION
#
#ldap ldaps admin replication replication port
ldd=$1
ldss=$2
admm=$3
repp=$4
repbb=$4

printf "Installation instructions..\n\n\n" > $setupPath/INSTALLATION

for (( b=0; b<$noOfServers; b++ ))
do
        bootStrapSrv="$bootStrapSrv--bootstrapReplicationServer $hostName${b}$domain:$repbb\n"
        ((repbb++))
done

if [ $dsVersion -eq 1 ];then
	for (( i=0; i<$noOfServers; i++ ))
	do
		setupCommand="$destPath${i}/opendj/./setup \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentKeyPassword $installationPassword \ \n--deploymentKey $deploymentKey \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--hostName $hostName${i}$domain \ \n--serverId $serverId${i} \ \n--replicationPort $repp \ \n$bootStrapSrv${installationProfile}  \ \n--acceptLicense"

		printf "$setupCommand\n\n\n" >> $setupPath/INSTALLATION
		((ldd++))
		((admm++))
		((ldss++))
		((repp++))
	done
else
	for (( i=0; i<$noOfServers; i++ ))
        do
                setupCommand="$destPath${i}/opendj/./setup \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentIdPassword $installationPassword \ \n--deploymentId $deploymentKey \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--hostName $hostName${i}$domain \ \n--serverId $serverId${i} \ \n--replicationPort $repp \ \n$bootStrapSrv${installationProfile} \ \n--acceptLicense"

                printf "$setupCommand\n\n\n" >> $setupPath/INSTALLATION
                ((ldd++))
                ((admm++))
                ((ldss++))
                ((repp++))
        done
fi

s=0
initReplication="$binPath./dsrepl initialize \\n--baseDN dc=example,dc=com \\n--toAllServers \\n--hostname $hostName${s}$domain \\n--port $adminPort \\n--bindDN "uid=admin" \\n--bindPassword $installationPassword \\n--trustStorePath $setupPath/config/keystore \\n--trustStorePasswordFile $setupPath/config/keystore.pin \\n--no-prompt"
printf "$initReplication\n\n\nDEPLOYMENT_KEY:$deploymentKey\nPassword: $installationPassword\n" >> $setupPath/INSTALLATION
}

#Call installation instruction function
installationText $ldapPort $ldapsPort $adminPort $replPort



executeInstallation()
{
# Execute DS setup
#
#ldap ldaps admin replication replication port
ld=$1
lds=$2
adm=$3
rep=$4
repb=$4

printf "executing DS ./setup command...\n"

for (( b=0; b<$noOfServers; b++ ))
do
        bootStrapServers=$bootStrapServers" "--bootstrapReplicationServer" "$hostName${b}$domain:$repb
        ((repb++))
done





if [ $dsVersion -eq 1 ];then

	for (( i=0; i<$noOfServers; i++ ))
	do
		$destPath${i}/opendj/./setup --ldapPort $ld --adminConnectorPort $adm --rootUserDN "uid=admin" --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --deploymentKeyPassword $installationPassword --deploymentKey $deploymentKey --enableStartTLS --ldapsPort $lds --hostName $hostName${i}$domain --serverId $serverId${i} --replicationPort $rep $bootStrapServers ${installationProfile} --acceptLicense 2>&1 >/dev/null &

		((ld++))
		((adm++))
		((lds++))
		((rep++))

		progressBar 2
		setupMessage

	done
else
	for (( i=0; i<$noOfServers; i++ ))
        do
                $destPath${i}/opendj/./setup --ldapPort $ld --adminConnectorPort $adm --rootUserDN "uid=admin" --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --deploymentIdPassword $installationPassword --deploymentId $deploymentKey --enableStartTLS --ldapsPort $lds --hostName $hostName${i}$domain --serverId $serverId${i} --replicationPort $rep $bootStrapServers ${installationProfile} --acceptLicense 2>&1 >/dev/null &

                ((ld++))
                ((adm++))
                ((lds++))
                ((rep++))

                progressBar 2
                setupMessage

        done
fi
}

#Call installation command
#
executeInstallation $ldapPort $ldapsPort $adminPort $replPort




# starting DS servers
#
printf "Starting DS server$startServer\n"
for (( startServer=0; startServer<$noOfServers; startServer++ ))
do
	$destPath${startServer}/opendj/bin/./start-ds
	printf "Server$startServer started..Done\n\n\n"
done




# Initialise replication
#
s=0
printf "starting replication initialisation please wait..\n"
sleep 10
$binPath./dsrepl initialize --baseDN dc=example,dc=com --toAllServers --hostname $hostName${s}$domain --port $adminPort --bindDN "uid=admin" --bindPassword $installationPassword --trustStorePath $setupPath/config/keystore --trustStorePasswordFile $setupPath/config/keystore.pin --no-prompt
printf "Replication initialisation started..\n\n"

#Execute status command
#
sleep 20
$binPath./dsrepl status --showGroups --showReplicas --hostname $hostName${s}$domain --port $adminPort --bindDN "uid=monitor" --bindPassword $installationPassword --trustStorePath $setupPath/config/keystore --trustStorePassword:file $setupPath/config/keystore.pin --no-prompt

#Create start stop command for all servers
#
printf "\n\nCreating srvDS.sh command to start and stop all your servers,\n"
printf "Command created on the default path, execute ./srvDS.sh stop or ./srvDS start\n\n"

numSrv=$noOfServers
printf "#!/bin/bash\n\nSrv=$numSrv\n\ndPath=$destPath\n" > $setupPath/srvDS.sh

command='p=$1\nif [ "$p" = "start" ];then\n\tfor (( j=0; j<$Srv; j++ ))\n\tdo\n\t\t$dPath${j}/opendj/bin/./start-ds\n\tdone\nelse\n\tfor (( j=0; j<$Srv; j++ ))\n\tdo\n\t\t$dPath${j}/opendj/bin/./stop-ds\n\tdone\nfi\n'

printf "$command" >> $setupPath/srvDS.sh
chmod 755 $setupPath/srvDS.sh





printf "installation successful..Done\n"
printf "Sagionara...\n"
tput cnorm

#END
