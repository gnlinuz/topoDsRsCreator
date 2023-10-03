#!/bin/bash
# This is a usiversal setup script for DS versios 5x 6X 7x
#
# Created on 01/Oct/2023
# Author = G.Nikolaidis
# Version 1.00
#
# Before execuete the script make sure you have installed Java version 11 or later
# the unzip and lsof utility
# include the DS.zip in the same directory where you execute the script
# chmod 755 the script to make it executable and execute it as root or sudo


clear

# **************************** SETTINGS ****************************************
# !!! important !!!
# you MUST change the below settings to meet your installation requirments!
#
#Destination path will be in the format /opt/ds7xRepl0, /opt/ds7xRepl1, /opt/ds7xRepl2, /opt/ds7xRepl3, /opt/ds7xReplx ...
destPath=~/dsrsTopo

#hostname will be in format ds0.example.com, ds1.example.com, ds2.example.com, dsx.example.com
hostName=ds
domain=.example.com

#serverId will be in the format MASTER0, MASTER1, MASTER2, MASTERx
serverId=MASTER

#password to be used for uid=admin for uid=Monitor cn=Directory Manager
installationPassword=DrowssaP

#installationProfile=ds-evaluation
generateUsers=10000

#change the name of the zip file to install

installationZipFile=DS-7.2.0.zip


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
idmRepo="--profile idm-repo --set idm-repo/domain:forgerock.com "

#Default installation profile
installationProfile=$dsEval

# Path of the first installed server
#
setupPath=${destPath}0/opendj
binPath=$setupPath/bin/

tput civis







# ************************** FUNCTIONS *****************************************
# ******************************************************************************
# ******************************************************************************
# ******************************************************************************
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


sselectedFamilyVersion()
{
  family=$1
  version=$2
  if [[ $family -eq 1 ]]; then
    case "$version" in
      1) selectedVersion=DS-5.0.0.zip
         ;;
      2) selectedVersion=DS-5.5.0.zip
         ;;
      3) selectedVersion=DS-5.5.1.zip
         ;;
      4) selectedVersion=DS-5.5.2.zip
         ;;
      5) selectedVersion=DS-5.5.3.zip
         ;;
      6) selectedVersion=DS-6.0.0.zip
         ;;
      7) selectedVersion=DS-6.5.0.zip
         ;;
      8) selectedVersion=DS-6.5.1.zip
         ;;
      9) selectedVersion=DS-6.5.2.zip
         ;;
      10) selectedVersion=DS-6.5.3.zip
         ;;
      11) selectedVersion=DS-6.5.4.zip
         ;;
      12) selectedVersion=DS-6.5.5.zip
         ;;
      13) selectedVersion=DS-6.5.6.zip
         ;;
      *)
    esac
 fi

 if [[ $family -eq 2 ]]; then
   case "$version" in
     1) selectedVersion=DS-7.0.0.zip
        ;;
     2) selectedVersion=DS-7.0.1.zip
        ;;
     3) selectedVersion=DS-7.0.2.zip
        ;;
     4) selectedVersion=DS-7.1.0.zip
        ;;
     5) selectedVersion=DS-7.1.1.zip
        ;;
     6) selectedVersion=DS-7.1.2.zip
        ;;
     7) selectedVersion=DS-7.1.3.zip
        ;;
     8) selectedVersion=DS-7.1.4.zip
        ;;
     9) selectedVersion=DS-7.1.5.zip
        ;;
     10) selectedVersion=DS-7.1.6.zip
        ;;
     *)
   esac
 fi

 if [[ $family -eq 3 ]]; then
   case "$version" in
     1) selectedVersion=DS-7.2.0.zip
        ;;
     2) selectedVersion=DS-7.2.1.zip
        ;;
     3) selectedVersion=DS-7.2.2.zip
        ;;
     4) selectedVersion=DS-7.2.3.zip
        ;;
     5) selectedVersion=DS-7.3.0.zip
        ;;
     6) selectedVersion=DS-7.3.1.zip
        ;;
     7) selectedVersion=DS-7.3.2.zip
        ;;
     8) selectedVersion=DS-7.3.3.zip
        ;;
     *)
   esac
 fi
}


selectProfile()
{
  profile=$1
  case "$profile" in
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
  7) installationProfile=$idmRepo
     ;;
  *)
     ;;
  esac
}


checkPorts()
{
 portCheck=$1
 noOfDS=$2
 for (( i = 0; i < $noOfDS; i++ ))
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


checkJava()
{
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
}


checkLsof()
{
  printf "Checking for lsof utility...\n"
  which lsof
  if [ $? -eq 0 ];then
          printf "lsof utility found..Done\n"
  else
          printf "lsof utility not found, please use sudo yum/apt/brew install lsof\n"
          printf "installation aborted!\n"
          tput cnorm
  	exit -1
  fi
}


checkDirectories()
{
  noServers=$1
  dPath=$2
  for (( k=0; k<$noServers; k++ ))
  do
          if [ -d $ddPath${k} ];then
                  echo; printf "Directory already exists $dPath${k}, please delete or rename it\n"
                  printf "Installation abort!\n"
                  tput cnorm
                  exit -1
          else
                  printf "Creating directory $dPath${k}...\n"
                  mkdir $dPath${k}
                  if [ $? -eq 0 ];then
                          printf "Created successful..Done\n"
                  else
                          printf "Can not create directory $dPath${k} check the directory permissions!\n"
                          printf "Installation failed!\n"
                          tput cnorm
                          exit -1
                  fi
          fi
  done
}


checkUnzip()
{
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
}


checkFileZip()
{
  zipFile=$1
  printf "Checking for zip file..\n"
  if [ -f "$zipFile" ];then
          printf "found,$zipFile..ok\n"
  else
          printf "Can't find $zipFile file, please make sure to include\n"
          printf "the file on the same directory where you execute the script\n"
          printf "Installation failed!\n"
          tput cnorm
  	exit -1
  fi
}


printMsg()
{
  commandOutput=$1
  if [ $commandOutput -eq 0 ];then
          printf "creation successful..Done\n"
  else
          printf "something went wrong creating the DEPLOYMENT_KEY!\n"
          printf "Installation failed!\n"
          tput cnorm
  	exit -1
  fi
}


insertHostNames()
{
  noServers=$1
  hName=$2
  domainName=$3
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

  for (( name=0; name<$noServers; name++ ))
  do
  cat /etc/hosts |grep "$hName${name}$domainName"
  if [ $? -eq 0 ];then
          printf "hostNames already exist on /etc/hosts..Done\n"
  else
          sed -i "/127.0.0.1/ s/$/ $hName${name}$domainName/" /etc/hosts
  fi

  done
  printf "insert hostNames into /etc/hosts..Done\n"
}


# Execute setup for ds version 7x
#
execute7xSetup()
{
  ld=$1
  lds=$2
  adm=$3
  rep=$4
  repb=$4
  noServers=$5
  hName=$6
  Domain=$7
  dePath=$8
  setupPass=$9
  Key=$10
  srvId=$11
  setupProfile=$12
  dFamily=$13

  printf "executing DS ./setup command...\n"

  for (( b=0; b<$noServers; b++ ))
  do
          bootStrapServers=$bootStrapServers" "--bootstrapReplicationServer" "$hName${b}$Domain:$repb
          ((repb++))
  done

  if [ $dFamily -eq 2 ];then

  	for (( i=0; i<$noServers; i++ ))
  	do
  		$dePath${i}/opendj/./setup --ldapPort $ld --adminConnectorPort $adm --rootUserDN "uid=admin" --rootUserPassword $setupPass --monitorUserPassword $setupPass --deploymentKeyPassword $setupPass --deploymentKey $Key --enableStartTLS --ldapsPort $lds --hostName $hName${i}$Domain --serverId $srvId${i} --replicationPort $rep $bootStrapServers ${setupProfile} --acceptLicense 2>&1 >/dev/null &

  		((ld++))
  		((adm++))
  		((lds++))
  		((rep++))

  		progressBar 2
  		setupMessage

  	done
  fi

  if [ $dFamily -eq 3 ];then
  	for (( i=0; i<$noServers; i++ ))
      do
        $dePath${i}/opendj/./setup --ldapPort $ld --adminConnectorPort $adm --rootUserDN "uid=admin" --rootUserPassword $setupPass --monitorUserPassword $setupPass --deploymentIdPassword $setupPass --deploymentId $Key --enableStartTLS --ldapsPort $lds --hostName $hName${i}$Domain --serverId $srvId${i} --replicationPort $rep $bootStrapServers ${setupProfile} --acceptLicense 2>&1 >/dev/null &

        ((ld++))
        ((adm++))
        ((lds++))
        ((rep++))

        progressBar 2
        setupMessage
      done
  fi
}



exportKey()
{
  sPath=$1
  deploymentKey=$(cat $sPath/DEPLOYMENT_KEY |awk '{ print $1 }')
  export deploymentKey
  printf "DEPLOYMENT_KEY/ID: $deploymentKey\n"
}













# ************************** MAIN **********************************************
# ******************************************************************************
# ******************************************************************************
# ******************************************************************************

printf "      Topology Creator\n"
printf "*****************************\n"
printf "\n"

printf "  Please select DS family\n"
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
  printf "  Please select DS family\n"
  printf "*****************************\n"
  printf "1. DS 5.x - DS 6.x\n"
  printf "2. DS 7.0.x - DS 7.1.x\n"
  printf "3. DS 7.2.x - DS 7.3x and up\n"
  printf "Enter your choise: "
  read dsFamily
done

clear

case "$dsFamily" in
1) printf "Please select DS version\n"
   printf "************************\n"
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
   while [[ $dsVersion -lt 1 && $dsVersion -gt 13 ]]
   do
      clear
      printf "Please select DS version\n"
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
2) printf "Please select DS version\n"
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
   printf "\n"
   while [[ $dsVersion -lt 1 && $dsVersion -gt 10 ]]
   do
     clear
     printf "Please select DS version\n"
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
3) printf "Please select DS version\n"
   printf "************************\n"
   printf "1. DS 7.2.0\n"
   printf "2. DS 7.2.1\n"
   printf "3. DS 7.2.2\n"
   printf "4. DS 7.2.3\n"
   printf "5. DS 7.3.0\n"
   printf "6. DS 7.3.1\n"
   printf "7. DS 7.3.2\n"
   printf "8. DS 7.3.3\n"
   printf "Enter your choise: "
   read dsVersion
   printf "\n"
   while [[ $dsVersion -lt 1 && $dsVersion -gt 8 ]]
   do
      clear
      printf "Please select DS version\n"
      printf "************************\n"
      printf "1. DS 7.2.0\n"
      printf "2. DS 7.2.1\n"
      printf "3. DS 7.2.2\n"
      printf "4. DS 7.2.3\n"
      printf "5. DS 7.3.0\n"
      printf "6. DS 7.3.1\n"
      printf "7. DS 7.3.2\n"
      printf "8. DS 7.3.3\n"
      read dsVersion
  done
      ;;
*)
   ;;
esac


printf "\n"
clear

printf "    Select type of Servers\n"
printf "********************************\n"
printf "1. Stand Alone DS RS servers\n"
printf "2. Non Stand Alone DS RS servers\n"
printf "Enter your choise: "
read standAlone
printf "\n"
while [[ "$standAlone" != "1" && "$standAlone" != "2" ]]
do
	clear
  printf "    Select type of Servers\n"
  printf "*********************************\n"
  printf "1. Stand Alone DS RS servers\n"
  printf "2. Non Stand Alone DS RS servers\n"
  printf "Enter your choise: "
  read standAlone
done

clear

if [[ $standAlone -eq 1 ]]; then

  printf " Select number of Servers\n"
  printf "*****************************\n"
  printf "Number of stand alone DS: "
  read dsNumber
  while [[ $dsNumber -lt 0 || $dsNumber -gt 8 ]]
  do
    clear
    printf "Number of stand alone DS: "
    read dsNumber
  done


  printf "Number of stand alone RS: "
  read rsNumber
  while [[ $rsNumber -lt 0 || $rsNumber -gt 8 ]]
  do
    clear
    printf "Number of stand alone RS: "
    read rsNumber
  done
fi

clear

if [[ $dsFamily -eq 1 && $dsVersion -gt 6 ]] || [[ $dsFamily -gt 1 ]]; then

  printf "                 Please select profile\n"
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
  while [[ $dsProfile -lt 1 && $dsProfile -gt 7 ]]
  do
	   clear
     printf "                 Please select profile\n"
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
fi


if [[ $standAlone -eq 2 ]]; then

  printf "Select number of servers (1 - 8)\n"
  printf "No: "
  read noOfServers
  while [[ $noOfServers -lt 1 && $noOfServers -gt 8 ]]
  do
    printf "Select number of servers (1 - 8)\n"
    printf "No: "
    read noOfServers
  done
  clear
fi


# Call function to check the product ds Family and Version
#
sselectedFamilyVersion $dsFamily $dsVersion

# Call function to select profile
#
selectProfile $dsProfile

printf "Selected dsVersion: $selectedVersion, selected ds profile: $installationProfile, selected ds/rs server No of DS: $dsNumber, No of RS: $rsNumber, total number of servers: $noOfServers"
printf "\n"

# check for Java environment
#
checkJava

# Check if netstat/lsof is installed and then check all the ports to avoid conflicts..
#
#netstat -V &>/dev/null
checkLsof

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
checkDirectories $noOfServers $destPath

# Check if unzip utility exists
#
checkUnzip

# Check if DS-7.x.x.zip file exist on the directory
#
checkFileZip $selectedVersion

# Unzip files to directories
#
printf "Unzipping files to directories...\n"
for (( dir=0; dir<$noOfServers; dir++ ))
do
        unzip $selectedVersion -d $destPath${dir} 2>&1 >/dev/null &
        progressBar 0
        unzipMessage
done


# Create deployment key
#
if [ $dsFamily -eq 2 ];then
  printf "creating DEPLOYMENT_KEY...please wait it might take some time..\n"
  export installationPassword
	$binPath./dskeymgr create-deployment-key --deploymentKeyPassword $installationPassword > $setupPath/DEPLOYMENT_KEY
  commandResult=$?
  printMsg $commandResult
  exportKey $setupPath
fi

if [ $dsFamily -eq 3 ];then
  printf "creating DEPLOYMENT-ID...please wait it might take some time..\n"
  export installationPassword
	$binPath./dskeymgr create-deployment-id --deploymentIdPassword $installationPassword > $setupPath/DEPLOYMENT_KEY
  printMsg $commandResult
  exportKey $setupPath
fi

printf "\n"
printf "Check if variable deploymentKey is available: $deploymentKey"
printf "\n"


# Insert hostNames into /etc/hosts file
#
insertHostNames $noOfServers $hostName $domain




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

  if [ $dsFamily -eq 2 ];then
	   for (( i=0; i<$noOfServers; i++ ))
	   do
		     setupCommand="$destPath${i}/opendj/./setup \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentKeyPassword $installationPassword \ \n--deploymentKey $deploymentKey \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--hostName $hostName${i}$domain \ \n--serverId $serverId${i} \ \n--replicationPort $repp \ \n$bootStrapSrv${installationProfile}  \ \n--acceptLicense"

		     printf "$setupCommand\n\n\n" >> $setupPath/INSTALLATION
		     ((ldd++))
		     ((admm++))
		     ((ldss++))
		     ((repp++))
	   done
  fi

  if [ $dsFamily -eq 3 ];then
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




exit -1




# Call setup 7x installation
#
execute7xSetup $ldapPort $ldapsPort $adminPort $replPort $noOfServers $hostName $domain $destPath $installationPassword $deploymentKey $serverId $installationProfile $dsFamily












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
