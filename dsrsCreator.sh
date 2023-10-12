#!/bin/bash
# This is a usiversal setup script for DS versios 5x 6X 7x
#
# Created on 01/Oct/2023
# Author = G.Nikolaidis
# Version 1.00
#
# Before execuete the script make sure you have installed Java version 11 or later
# the unzip and lsof utility
# include the DS.zip file in the same directory where you execute the script
# chmod 755 the script to make it executable and execute it as root or sudo


clear

# **************************** SETTINGS ***********************************
#                          !!! important !!!
# you MUST change the below settings to meet your installation requirments!
#
# *************************************************************************
#Destination path will be in the format /opt/ds7xRepl0, /opt/ds7xRepl1, /opt/ds7xRepl2, /opt/ds7xRepl3, /opt/ds7xReplx ...
destPath=~/dsrsTopo

#Path for stand alone DS RS servers
#
dsAlonePath=${destPath}DS
rsAlonePath=${destPath}RS

#hostname will be in format ds0.example.com, ds1.example.com, ds2.example.com, dsx.example.com
hostName=ds
domain=.example.com

#serverId will be in the format MASTER0, MASTER1, MASTER2, MASTERx
srvID=MASTER

#password to be used for uid=admin for uid=Monitor cn=Directory Manager
installationPassword=DrowssaP
export installationPassword

#installationProfile=ds-evaluation
generateUsers=10000

#Default protocol ports to be used
#on each additional server the port will be +1 ie. server0 ldapPort:1389, server1 ldapPort:1390, server2 ldapPort:1391 etc
#ldaps port server0 ldapsPort:1686, server1 ldapsPort:1687 etc
ldapPort=1389
ldapsPort=1636
httpsPort=8443
replPort=8989
adminPort=4444

#DS/RS setup profiles
#
dsEval="--profile ds-evaluation --set ds-evaluation/generatedUsers:$generateUsers "
dsAmCtsAmReap="--profile am-cts --set am-cts/amCtsAdminPassword:5up35tr0ng "
dsAmCtsSes="--profile am-cts --set am-cts/amCtsAdminPassword:5up35tr0ng --set am-cts/tokenExpirationPolicy:am-sessions-only "
dsAmCtsDs="--profile am-cts --set am-cts/amCtsAdminPassword:5up35tr0ng --set am-cts/tokenExpirationPolicy:ds "
dsAmConfig="--profile am-config --set am-config/amConfigAdminPassword:5up35tr0ng "
dsAmIdentities="--profile am-identity-store --set am-identity-store/amIdentityStoreAdminPassword:5up35tr0ng "
idmRepo="--profile idm-repo --set idm-repo/domain:forgerock.com "

# dseval        dc=example,dc=com
# cts           ou=tokens
# amConfig      ou=am-config
# amIdentities  ou=identities
# idmRepo       dc=openidm,dc=forgerock,dc=com
profileBaseDN=(dc=example,dc=com ou=tokens ou=am-config ou=identities dc=openidm,dc=forgerock,dc=com)

# Path of the first installed server
# and bin path
setupPath=${destPath}0/opendj
binPath=$setupPath/bin/

firstDSRSpath=${dsAlonePath}0/opendj
firstDSRSbinPath=${firstDSRSpath}/bin/

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


progressBar2()
{
  sleepTime=$1
  pid=$2
  while ps -p $pid &>/dev/null; do
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
  local destinationPath=$1
  local numberOfServer=$2
  for (( k=0; k<$numberOfServer; k++ ))
  do
          if [ -d $destinationPath${k} ];then
                  echo; printf "Directory already exists $destinationPath${k}, please delete or rename it\n"
                  printf "Installation abort!\n"
                  tput cnorm
                  exit -1
          else
                  printf "Creating directory $destinationPath${k}...\n"
                  mkdir $destinationPath${k}
                  if [ $? -eq 0 ];then
                          printf "Created successful..Done\n"
                  else
                          printf "Can not create directory $destinationPath${k} check the directory permissions!\n"
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
  if [[ $commandOutput -eq 0 ]];then
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
          sed -i '' "/127.0.0.1/ s/$/ ${hostName}${name}${domain}/" /etc/hosts
  fi

  done
  printf "insert hostNames into /etc/hosts..Done\n"
}


startServers()
{
    printf "Starting DS/RS servers...\n"
    for (( startServer=0; startServer<$noOfServers; startServer++ ))
    do
        $destPath${startServer}/opendj/bin/./start-ds
        process_id=$!
        wait $process_id
        printf "Server$startServer started..Done\n\n\n"
    done
}



exportKey()
{
  depKey=$(cat $theSetupPath/DEPLOYMENT_KEY |awk '{ print $1 }')
  export depKey
  printf "DEPLOYMENT_KEY/ID: $depKey\n"
}



createDepKey()
{
  theBinPath=$1
  theSetupPath=$2 
  printf "creating DEPLOYMENT-ID...please wait it might take some time..\n"
  $theBinPath/dskeymgr create-deployment-id --deploymentIdPassword $installationPassword > $theSetupPath/DEPLOYMENT_KEY
  commandResult=$?
  printMsg $commandResult
  exportKey $theSetupPath
}


createDepKey2()
{
  theBinPath=$1
  theSetupPath=$2  
  printf "creating DEPLOYMENT_KEY...please wait it might take some time..\n"
  $theBinPath./dskeymgr create-deployment-key --deploymentKeyPassword $installationPassword > $theSetupPath/DEPLOYMENT_KEY
  commandResult=$?
  printMsg $commandResult
  exportKey $theSetupPath
}


installationText()
{
  # Create INSTALLATION text
  # ldap ldaps admin replication replication port https
  #
  ldd=$1
  ldss=$2
  admm=$3
  repp=$4
  repbb=$4
  htps=$5
  
  local num=0
  printf "Installation instructions..\n\n\n" > $setupPath/INSTALLATION

  for (( b=0; b<$noOfServers; b++ ))
  do
        bootStrapSrv="$bootStrapSrv--bootstrapReplicationServer $hostName${b}$domain:$repbb\n"
        ((repbb++))
  done

  if [ $dsFamily -eq 2 ];then
       for (( i=0; i<$noOfServers; i++ ))
        do
             setupCommand="$destPath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentKeyPassword $installationPassword \ \n--deploymentKey $depKey \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpsPort $htps \ \n--hostName $hostName${i}$domain \ \n--serverId $srvID${i} \ \n--replicationPort $repp \ \n${bootStrapSrv}${installationProfile}  \ \n--acceptLicense"

             printf "$setupCommand\n\n\n" >> $setupPath/INSTALLATION
             ((ldd++))
             ((admm++))
             ((ldss++))
             ((repp++))
             ((htps++))
        done
  fi

  if [ $dsFamily -eq 3 ];then
       for (( i=0; i<$noOfServers; i++ ))
         do
            setupCommand="$destPath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentIdPassword $installationPassword \ \n--deploymentId $depKey \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpsPort $htps \ \n--hostName $hostName${i}$domain \ \n--serverId $srvID${i} \ \n--replicationPort $repp \ \n${bootStrapSrv}${installationProfile} \ \n--acceptLicense"

            printf "$setupCommand\n\n\n" >> $setupPath/INSTALLATION
            ((ldd++))
            ((admm++))
            ((ldss++))
            ((repp++))
            ((htps++))
         done
  fi

  if [ $noOfServers -gt 1 ];then
    s=0

    case "$dsProfile" in
    1) bDN=${profileBaseDN[0]}
       # dsEval
       ;;
    2) bDN=${profileBaseDN[1]}
       # cts
       ;;
    3) bDN=${profileBaseDN[1]}
       # cts
       ;;
    4) bDN=${profileBaseDN[1]}
       # cts
       ;;
    5) bDN=${profileBaseDN[2]}
       # amConfig
       ;;
    6) bDN=${profileBaseDN[3]}
       # amIdentities
       ;;
    7) bDN=${profileBaseDN[4]}
       # idmRepo
       ;;         
    *)
       ;;   
    esac

    initReplication="$binPath./dsrepl initialize \\n--baseDN $bDN \\n--toAllServers \\n--hostname $hostName${num}$domain \\n--port $adminPort \\n--bindDN "uid=admin" \\n--bindPassword $installationPassword \\n--trustStorePath $setupPath/config/keystore \\n--trustStorePasswordFile $setupPath/config/keystore.pin \\n--no-prompt"
    printf "$initReplication\n\n\nDEPLOYMENT_KEY:$depKey\nPassword: $installationPassword\n" >> $setupPath/INSTALLATION
  fi  
}


exStatusCommand()
{
    local num=0
    $binPath./dsrepl status --showGroups --showReplicas --hostname $hostName${num}$domain --port $adminPort --bindDN "uid=admin" --bindPassword $installationPassword --trustStorePath $setupPath/config/keystore --trustStorePassword:file $setupPath/config/keystore.pin --no-prompt
}


# The creation is on the wrong path
createStartStop()
{
    printf "\n\nCreating srvDS.sh command to start and stop all your servers,\n"
    printf "Command created on the default path, execute ./srvDS.sh stop or ./srvDS start\n\n"

    numSrv=$noOfServers
    printf "#!/bin/bash\n\nSrv=$numSrv\n\ndPath=$destPath\n" > $setupPath/srvDS.sh

    command='p=$1\nif [ "$p" = "start" ];then\n\tfor (( j=0; j<$Srv; j++ ))\n\tdo\n\t\t$dPath${j}/opendj/bin/./start-ds\n\tdone\nelse\n\tfor (( j=0; j<$Srv; j++ ))\n\tdo\n\t\t$dPath${j}/opendj/bin/./stop-ds\n\tdone\nfi\n'

    printf "$command" >> $setupPath/srvDS.sh
    chmod 755 $setupPath/srvDS.sh
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
  htps=$5

  local num=0
  printf "executing DS ./setup command...\n"

  for (( b=0; b<$noOfServers; b++ ))
  do
          bootStrapServers=$bootStrapServers" "--bootstrapReplicationServer" "${hostName}${b}${domain}:${repb}
          ((repb++))
  done

  if [ $dsFamily -eq 2 ];then

    for (( i=0; i<$noServers; i++ ))
    do
        ${destPath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentKey $depKey --deploymentKeyPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${hostName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld  --enableStartTLS --ldapsPort $lds --httpsPort $htps --replicationPort ${rep} ${bootStrapServers} ${installationProfile} --acceptLicense 2>&1 >/dev/null &
        process_id=$!
        progressBar2 1 $process_id
        ((ld++))
        ((adm++))
        ((lds++))
        ((rep++))
        ((htps++))
        setupMessage
    done
  fi

  if [ $dsFamily -eq 3 ];then
    for (( i=0; i<$noOfServers; i++ ))
      do
        echo "${destPath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentId $depKey --deploymentIdPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${hostName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld --enableStartTLS --ldapsPort $lds --httpsPort $htps --replicationPort ${rep} ${bootStrapServers} ${installationProfile} --acceptLicense 2>&1 >/dev/null &">TEST.TXT
        ${destPath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentId $depKey --deploymentIdPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${hostName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld --enableStartTLS --ldapsPort $lds --httpsPort $htps --replicationPort ${rep} ${bootStrapServers} ${installationProfile} --acceptLicense 2>&1 >/dev/null &
        process_id=$!
        progressBar2 1 $process_id
        ((ld++))
        ((adm++))
        ((lds++))
        ((rep++))
        ((htps++))
        setupMessage
      done
  fi

  startServers

  if [ $noOfServers -gt 1 ];then
    printf "starting replication initialisation please wait..\n"
    sleep 10
    case "$dsProfile" in
    1) bDN=${profileBaseDN[0]}
       # dsEval
       ;;
    2) bDN=${profileBaseDN[1]}
       # cts
       ;;
    3) bDN=${profileBaseDN[1]}
       # cts
       ;;
    4) bDN=${profileBaseDN[1]}
       # cts
       ;;
    5) bDN=${profileBaseDN[2]}
       # amConfig
       ;;
    6) bDN=${profileBaseDN[3]}
       # amIdentities
       ;;
    7) bDN=${profileBaseDN[4]}
       # idmRepo
       ;;         
    *)
       ;;   
    esac 
    $binPath./dsrepl initialize --baseDN $bDN --toAllServers --hostname $hostName${num}$domain --port $adminPort --bindDN "uid=admin" --bindPassword $installationPassword --trustStorePath $setupPath/config/keystore --trustStorePasswordFile $setupPath/config/keystore.pin --no-prompt
    printf "Replication initialisation started..\n\n"
  fi
}



unzipDSRSsetupFile()
{
    local destinationPath=$1
    local numberOfServer=$2
    printf "Unzipping files to directories...\n"
    for (( dir=0; dir<$numberOfServer; dir++ ))
    do
        unzip $selectedVersion -d $destinationPath${dir} 2>&1 >/dev/null &
        process_id=$!
        progressBar2 0 $process_id
        unzipMessage
    done
}













endOfInstallation()
{
    printf "Installation successful..Done\n"
    printf "Sagionara...\n"
    tput cnorm
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
printf "1. Normal DS/RS servers\n"
printf "2. Stand Alone DS RS servers\n"
printf "Enter your choise: "
read standAlone
printf "\n"
while [[ "$standAlone" != "1" && "$standAlone" != "2" ]]
do
  clear
  printf "    Select type of Servers\n"
  printf "*********************************\n"
  printf "1. Normal DS/RS servers\n"
  printf "2. Stand Alone DS RS servers\n"
  printf "Enter your choise: "
  read standAlone
done

clear

if [[ $standAlone -eq 2 ]]; then
  typeOfInstallation=2  
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

  typeOfInstallation=1  
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


if [[ $standAlone -eq 1 ]]; then

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


# Installation of normal DS/RS servers at version DS 7x
# 
if [[ $typeOfInstallation -eq 1 ]]; then

    # Call function to check the product ds Family and Version
    #
    sselectedFamilyVersion $dsFamily $dsVersion

    # Call function to select profile
    #
    selectProfile $dsProfile

    # Call function to check for Java environment
    #
    checkJava

    # Call function to check if netstat/lsof is installed and then check all the ports to avoid conflicts..
    #
    # netstat -V &>/dev/null
    checkLsof

    # checkPorts for DS/RS servers
    #
    for j in $ldapPort $ldapsPort $httpsPort $replPort $adminPort
    do
        printf "Checking protocol port: $j\n"
        checkPorts $j $noOfServers
    done

    # Call function to check for existing directories
    # and create new directories
    #
    checkDirectories $destPath $noOfServers

    # Call function to check if unzip utility exists
    #
    checkUnzip

    # Call function to check if DS-7.x.x.zip file exist on the directory
    #
    checkFileZip $selectedVersion

    # Unzip files to directories
    #
    printf "Unzipping files to directories...\n"
    printf "\n"
    printf "Check for number of servers are: $noOfServers"
    printf "\n"
    for (( dir=0; dir<$noOfServers; dir++ ))
    do
        unzip $selectedVersion -d $destPath${dir} 2>&1 >/dev/null &
        process_id=$!
        progressBar2 0 $process_id
        unzipMessage
    done

    # Create deployment key
    #
    if [[ $dsFamily -eq 2 ]];then
        createDepKey2 $destPath $setupPath
    fi

    if [[ $dsFamily -eq 3 ]];then
        createDepKey $destPath
    fi

    # Insert hostNames into /etc/hosts file
    #
    insertHostNames

    # Call function to create installation text
    #
    installationText $ldapPort $ldapsPort $adminPort $replPort $httpsPort

    # Call function to execute installation of DS/RS 7.x family
    #
    execute7xSetup $ldapPort $ldapsPort $adminPort $replPort $httpsPort

    # Execute status command
    #
    exStatusCommand

    # Create start stop command for all servers
    #
    createStartStop

    # End of installation message
    #
    endOfInstallation

fi






if [[ $typeOfInstallation -eq 1 && $standAlone -eq 2 ]]; then
    # Call function to check the product ds Family and Version
    #
    sselectedFamilyVersion $dsFamily $dsVersion
    # check this function


    # Call function to select profile
    #
    if [[ dsNumber -gt 0 ]];then
        selectProfile $dsProfile
    fi
    # Call function to check for Java environment
    #
    checkJava

    # Call function to check if netstat/lsof is installed and then check all the ports to avoid conflicts..
    #
    # netstat -V &>/dev/null
    checkLsof

    # checkPorts for stand alone DS and RS servers
    #
    if [[ dsNumber -gt 0 ]]; then

        for j in $ldapPort $ldapsPort $httpsPort $adminPort
        do
            printf "Checking protocol port: $j\n"
            checkPorts $j $dsNumber
        done
    fi

    if [[ rsNumber -gt 0 ]]; then   
        ldapP=$((ldapPort + dsNumber))
        ldapsP=$((ldapsPort + dsNumber))
        httpsP=$((httpsPort + dsNumber))
        adminP=$((adminPort + dsNumber))
        for j in $ldapP $ldapsP $httpsP $replPort $adminP
        do
            printf "Checking protocol port: $j\n"
            checkPorts $j $rsNumber
        done
    fi

    # Call function to check for existing directories
    # and create new directories
    #
    checkDirectories $dsAlonePath $dsNumber
    checkDirectories $rsAlonePath $rsNumber

    # Call function to check if unzip utility exists
    #
    checkUnzip

    # Call function to check if DS-7.x.x.zip file exist on the directory
    #
    checkFileZip $selectedVersion

    # Unzip files to directories
    #
    unzipDSRSsetupFile $dsAlonePath $dsNumber
    unzipDSRSsetupFile $rsAlonePath $rsNumber


    # Create deployment key
    #
    if [[ $dsFamily -eq 2 ]];then
        createDepKey2 $firstDSRSbinPath $firstDSRSpath
    fi

    if [[ $dsFamily -eq 3 ]];then
        createDepKey $firstDSRSbinPath $firstDSRSpath
    fi

    # Insert hostNames into /etc/hosts file
    #
    insertHostNames
fi



#END
