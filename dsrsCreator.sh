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

# ******************************************** SETTINGS ******************************************************************
# ************************************************************************************************************************
# ************************************************************************************************************************
#                                         !!! important !!!
#
# Optional:         Change the below settings to meet your installation requirments!
#
# ************************************************************************************************************************
# ************************************************************************************************************************
#Destination path will be in the format ~/dsrsTopo1, ~/dsrsTopo2,
destPath=~/dsrsTopo

#Path for stand alone DS RS servers ex. dsrsTopoDS1 or dsrsTopoRS1 etc
#
dsAlonePath=${destPath}DS
rsAlonePath=${destPath}RS

#hostname will be in format dsrs1.example.com, dsrs2.example.com, dsOnly1.example.com, rsOnly1.example.com etc
hostName=dsrs
dsOnlyHostName=dsOnly
rsOnlyHostName=rsOnly
domain=.example.com

#serverId will be in the format MASTER0, MASTER1, MASTER2, MASTERx
srvID=MASTER

#for servers earlier than ds 7.x server id must be numeric
#
numericServerID=100

#password to be used for uid=admin for uid=Monitor cn=Directory Manager
installationPassword=DrowssaP
export installationPassword

#installationProfile=ds-evaluation
generateUsers=10000

#Default protocol ports to be used
#on each additional server the port will be +1 ie. server0 ldapPort:1389, server1 ldapPort:1390, server2 ldapPort:1391 etc
#ldaps port server0 ldapsPort:1686, server1 ldapsPort:1687 etc
admPort=4444
ldPort=1389
ldsPort=1636
hPort=8080
hsPort=8443
replPort=8989


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

firstDSpath=${dsAlonePath}0/opendj
firstDSbinPath=${firstDSpath}/bin/

firstRSpath=${rsAlonePath}0/opendj
firstRSbinPath=${firstRSpath}/bin/


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


selectedFamilyVersion()
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
  1) if [[ $dsFamily -eq 1 && $dsVersion -gt 6 ]]; then
        installationProfile="--profile ds-evaluation "
     else   
        installationProfile=$dsEval
     fi   
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


insertHostNames()
{ 
  hNmame=$1
  nServers=$2  
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

  for (( name=0; name<$nServers; name++ ))
  do
  cat /etc/hosts |grep "$hNmame${name}$domain"
  if [ $? -eq 0 ];then
          printf "hostNames already exist on /etc/hosts..Done\n"
  else
          sed -i '' "/127.0.0.1/ s/$/ ${hNmame}${name}${domain}/" /etc/hosts
  fi

  done
  printf "insert hostNames into /etc/hosts..Done\n"
}


startServers()
{
    local noOfDS=$1
    local dPath=$2
    printf "Starting DS/RS servers...\n"
    for (( startServer=0; startServer<$noOfDS; startServer++ ))
    do
        $dPath${startServer}/opendj/bin/./start-ds
        process_id=$!
        wait $process_id
        printf "Server$startServer started..Done\n\n\n"
    done
}


startServersStandAlone()
{
    if [[ dsNumber -gt 0 ]]; then
        printf "Starting stand alone DS servers...\n"
        startServers $dsNumber $dsAlonePath
    fi

    if [[ rsNumber -gt 0 ]]; then
        printf "Starting stand alone RS servers...\n"
        startServers $rsNumber $rsAlonePath
    fi
    
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
  exportKey
}


createDepKey2()
{
  theBinPath=$1
  theSetupPath=$2  
  printf "creating DEPLOYMENT_KEY...please wait it might take some time..\n"
  $theBinPath./dskeymgr create-deployment-key --deploymentKeyPassword $installationPassword > $theSetupPath/DEPLOYMENT_KEY
  commandResult=$?
  printMsg $commandResult
  exportKey
}


selectedDN()
{
    dsProf=$1
    case "$dsProf" in
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
}


replicationStatus65x()
{
    local srvBinPath=$1
    local hName=$2
    local num=0

    $srvBinPath./dsreplication status --hostname ${hName}${num}${domain} --port ${admPort} --adminUid admin --adminPassword $installationPassword --no-prompt --trustAll
}


# Create installation text for normal DS RS servers
#
installationText()
{
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

    selectedDN $dsProfile

    initReplication="$binPath./dsrepl initialize \\n--baseDN $bDN \\n--toAllServers \\n--hostname $hostName${num}$domain \\n--port $admPort \\n--bindDN "uid=admin" \\n--bindPassword $installationPassword \\n--trustStorePath $setupPath/config/keystore \\n--trustStorePasswordFile $setupPath/config/keystore.pin \\n--no-prompt"
    printf "$initReplication\n\n\nDEPLOYMENT_KEY:$depKey\nPassword: $installationPassword\n" >> $setupPath/INSTALLATION
  fi  
}


# Create installation text for stand alone DS RS servers
#
installationText2()
{
  # Create INSTALLATION text for stand alone DS RS servers
  # ldap ldaps admin replication replication port https
  #
  ldd=$1
  ldss=$2
  admm=$3
  repp=$4
  repbb=$4
  htps=$5
  dsNum=$6
  rsNum=$7
  dsOnlyHName=$8
  rsOnlyHName=$9

  local num=0
  printf "Installation instructions..\n\n\n" > $firstDSpath/INSTALLATION
  
  #create bootstrapServers only when there are RS servers to be installed
  if [[ $rsNum -gt 0 ]]; then
    for (( b=0; b<$rsNum; b++ ))
    do
        bootStrapSrv="$bootStrapSrv--bootstrapReplicationServer $rsOnlyHName${b}$domain:$repbb\n"
        ((repbb++))
    done
  fi
  
  #create ds only servers
  if [[ $dsFamily -eq 2 && $dsNum -gt 0 ]];then
       #add bootstrapServers to ds only servers only when RS servers to be installed
       if [[ $rsNum -gt 0 ]]; then 
        for (( i=0; i<$dsNum; i++ ))
            do
                setupCommand="$dsAlonePath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentKeyPassword $installationPassword \ \n--deploymentKey $depKey \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpsPort $htps \ \n--hostName $dsOnlyHName${i}$domain \ \n--serverId $srvID${i} \ \n${bootStrapSrv}${installationProfile}  \ \n--acceptLicense"

                printf "$setupCommand\n\n\n" >> $firstDSpath/INSTALLATION
                ((ldd++))
                ((admm++))
                ((ldss++))
                ((htps++))
            done
       fi
  fi


  if [[ $dsFamily -eq 2 && $dsNum -gt 0 ]];then     
        #do not add bootstrapServers to ds only servers since there are no RS servers to be installed
        if [[ $rsNum -lt 1 ]]; then 
         for (( i=0; i<$dsNum; i++ ))
            do
                setupCommand="$dsAlonePath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentKeyPassword $installationPassword \ \n--deploymentKey $depKey \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpsPort $htps \ \n--hostName $dsOnlyHName${i}$domain \ \n--serverId $srvID${i} \ \n${installationProfile}  \ \n--acceptLicense"

                printf "$setupCommand\n\n\n" >> $firstDSpath/INSTALLATION
                ((ldd++))
                ((admm++))
                ((ldss++))
                ((htps++))
            done 
        fi

  fi

  #create the rs only servers
  if [[ $dsFamily -eq 2 && $rsNum -gt 0 ]];then
       for (( i=0; i<$rsNum; i++ ))
        do
             setupCommand="$rsAlonePath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentKeyPassword $installationPassword \ \n--deploymentKey $depKey \ \n--adminConnectorPort $admm \ \n--hostName $rsOnlyHName${i}$domain \ \n--serverId $srvID${i} \ \n--replicationPort $repp \ \n${bootStrapSrv}  \ \n--acceptLicense"
             #if only RS servers is installed then create the installation text to the first RS server
             if [[ $dsNum -lt 1 ]]; then
                printf "$setupCommand\n\n\n" >> $firstRSpath/INSTALLATION
             else
                printf "$setupCommand\n\n\n" >> $firstDSpath/INSTALLATION    
             fi
             ((admm++))
             ((repp++))
        done
  fi


  #create ds only servers
  if [[ $dsFamily -eq 3 && $dsNum -gt 0 ]];then
       #add bootstrapServers to ds only servers only when RS servers to be installed
       if [[ $rsNum -gt 0 ]]; then 
        for (( i=0; i<$dsNum; i++ ))
            do
                setupCommand="$dsAlonePath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentIdPassword $installationPassword \ \n--deploymentId $depKey \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpsPort $htps \ \n--hostName $dsOnlyHName${i}$domain \ \n--serverId $srvID${i} \ \n${bootStrapSrv}${installationProfile} \ \n--acceptLicense"

                printf "$setupCommand\n\n\n" >> $firstDSpath/INSTALLATION
                ((ldd++))
                ((admm++))
                ((ldss++))
                ((htps++))
            done
       fi
  fi 

  if [[ $dsFamily -eq 3 && $dsNum -gt 0 ]];then
        #do not add bootstrapServers to ds only servers since there are no RS servers to be installed
        if [[ $rsNum -lt 1 ]]; then   
            for (( i=0; i<$dsNum; i++ ))
                do
                    setupCommand="$dsAlonePath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentIdPassword $installationPassword \ \n--deploymentId $depKey \ \n--ldapPort $ldd \ \n--adminConnectorPort $admm \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpsPort $htps \ \n--hostName $dsOnlyHName${i}$domain \ \n--serverId $srvID${i} \ \n${installationProfile} \ \n--acceptLicense"

                    printf "$setupCommand\n\n\n" >> $firstDSpath/INSTALLATION
                    ((ldd++))
                    ((admm++))
                    ((ldss++))
                    ((htps++))
                done
       fi     
  fi

  #create the RS servers
  if [[ $dsFamily -eq 3 && $rsNum -gt 0 ]];then 
    for (( i=0; i<$dsNum; i++ ))
        do
            setupCommand="$rsAlonePath${i}/opendj/./setup \ \n--rootUserDN "uid=admin" \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--deploymentIdPassword $installationPassword \ \n--deploymentId $depKey \ \n--adminConnectorPort $admm \ \n--hostName $rsOnlyHName${i}$domain \ \n--serverId $srvID${i} \ \n--replicationPort $repp \ \n${bootStrapSrv} \ \n--acceptLicense"

            if [[ $dsNum -lt 1 ]]; then
                printf "$setupCommand\n\n\n" >> $firstRSpath/INSTALLATION
             else
                printf "$setupCommand\n\n\n" >> $firstDSpath/INSTALLATION    
             fi
            ((admm++))
            ((repp++))
        done     
  fi


  if [ $dsNum -gt 1 ];then

    selectedDN $dsProfile

    initReplication="$firstDSbinPath./dsrepl initialize \\n--baseDN $bDN \\n--toAllServers \\n--hostname $dsOnlyHName${num}$domain \\n--port $admPort \\n--bindDN "uid=admin" \\n--bindPassword $installationPassword \\n--trustStorePath $firstDSpath/config/keystore \\n--trustStorePasswordFile $firstDSpath/config/keystore.pin \\n--no-prompt"
    printf "$initReplication\n\n\nDEPLOYMENT_KEY:$depKey\nPassword: $installationPassword\n" >> $firstDSpath/INSTALLATION
  fi  
}



# Create installation text for DS 6.5.x
# 
installation65xText()
{
  local ldd=$1
  local ldss=$2
  local admm=$3
  local htp=$4
  local htps=$5
  local sID=$6
  local rPort=$7
  
  local firstSrv=0
  local num=0
  local j=0
  local adm=$admm
  local repPort=$rPort
  local noSrv=$noOfServers

  printf "Installation instructions..\n\n\n" > $setupPath/INSTALLATION

  selectedDN $dsProfile

  # If number of servers is 1 then the script should abort installation and warn that 2 or more servers needed otherwise install stand alone servers
  # DONE

  #create servers
  for (( i=0; i<$noOfServers; i++ ))
        do
             setupCommand1="$destPath${i}/opendj/./setup directory-server \ \n--rootUserDN cn=Directory Manager \ \n--rootUserPassword $installationPassword \ \n--monitorUserPassword $installationPassword \ \n--hostName $hostName${i}$domain \ \n--ldapPort $ldd \ \n--enableStartTLS \ \n--ldapsPort $ldss \ \n--httpPort $htp \ \n--httpsPort $htps \ \n--adminConnectorPort $adm \ \n${installationProfile} \ \n--acceptLicense"

             printf "$setupCommand1\n\n\n" >> $setupPath/INSTALLATION
             ((ldd++))
             ((ldss++))
             ((adm++))
             ((htp++))
             ((htps++))             
        done

  #create server ID for each server
  adm=$admm
  for (( i=0; i<$noOfServers; i++ ))
        do
             setupCommand2="$destPath${i}/opendj/bin/./dsconfig set-global-configuration-prop \ \n--hostName $hostName${i}$domain \ \n--adminConnectorPort $adm \ \n--bindDN cn=Directory Manager \ \n--bindPassword $installationPassword \ \n--set server-id:${sID} \ \n--trustAll \ \n--no-prompt"  

             printf "$setupCommand2\n\n\n" >> $setupPath/INSTALLATION
             ((adm++))
             ((sID++))
        done

  
  #configure the replication
  adm=$admm
  ((noSrv--))
  for (( i=0; i<$noSrv; i++ ))
        do
            ((j++))
            ((adm++))
            ((repPort++))
            setupCommand3="${destPath}${firstSrv}/opendj/bin/./dsreplication configure \ \n--adminUID admin \ \n--adminPassword $installationPassword \ \n--baseDN $bDN \ \n--host1 ${hostName}${firstSrv}${domain} \ \n--port1 $admPort \ \n--bindDN1 cn=Directory Manager \ \n--bindPassword1 $installationPassword \ \n--replicationPort1 $replPort \ \n--host2 $hostName${j}$domain \ \n--port2 ${adm} \ \n--bindDN2 cn=Directory Manager \ \n--bindPassword2 $installationPassword \ \n--replicationPort2 ${repPort} \ \n--trustAll \ \n--no-prompt"

            printf "$setupCommand3\n\n\n" >> $setupPath/INSTALLATION
        done


  #initialise the replication
  j=0
  adm=$admm
  for (( i=0; i<$noSrv; i++ ))
        do
            ((j++))
            ((adm++))
            setupCommand4="${destPath}${firstSrv}/opendj/bin/./dsreplication initialize \ \n--adminUID admin \ \n--adminPassword $installationPassword \ \n--baseDN $bDN \ \n--hostSource ${hostName}${firstSrv}${domain} \ \n--portSource $admPort \ \n--hostDestination $hostName${j}$domain \ \n--portDestination ${adm} \ \n--trustAll \ \n--no-prompt"

            printf "$setupCommand4\n\n\n" >> $setupPath/INSTALLATION
        done
  printf "\n Finish with text set up..\n"      
}


exStatusCommand()
{   local srvBinPath=$1
    local hName=$2
    local sPath=$3
    local num=0
    $binPath./dsrepl status --showGroups --showReplicas --hostname $hostName${num}$domain --port $admPort --bindDN "uid=admin" --bindPassword $installationPassword --trustStorePath $setupPath/config/keystore --trustStorePassword:file $setupPath/config/keystore.pin --no-prompt
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


# Execute setup for normal ds rs servers version 7x
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

    for (( i=0; i<$noOfServers; i++ ))
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

  startServers $noOfServers $destPath

  if [ $noOfServers -gt 1 ];then
    printf "starting replication initialisation please wait..\n"
    sleep 10
    selectedDN $dsProfile

    $binPath./dsrepl initialize --baseDN $bDN --toAllServers --hostname $hostName${num}$domain --port $admPort --bindDN "uid=admin" --bindPassword $installationPassword --trustStorePath $setupPath/config/keystore --trustStorePasswordFile $setupPath/config/keystore.pin --no-prompt
    process_id=$!
    wait $process_id
    printf "Replication initialisation started..\n\n"
  fi
}



# Execute setup for stand alone ds rs servers version 7x
#
executeStandAlone7xSetup()
{
  ld=$1
  lds=$2
  adm=$3
  rep=$4
  repb=$4
  htps=$5
  dsNum=$6
  rsNum=$7
  dsOnlyHName=$8
  rsOnlyHName=$9
  local num=0
  printf "executing DS ./setup command...\n"
  
  #create bootStrapServer when rs servers are installed
  if [[ $rsNum -gt 0 ]]; then
    for (( b=0; b<$rsNum; b++ ))
        do
            bootStrapServers=$bootStrapServers" "--bootstrapReplicationServer" "${rsOnlyHName}${b}${domain}:${repb}
            ((repb++))
        done
  fi

  #create ds only servers
  if [[ $dsFamily -eq 2 && dsNum -gt 0 ]]; then
       #add bootstrapServers to ds only servers only when RS servers to be installed
       if [[ $rsNum -gt 0 ]]; then 

            for (( i=0; i<$dsNum; i++ ))
                do
                    ${dsAlonePath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentKey $depKey --deploymentKeyPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${dsOnlyHName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld  --enableStartTLS --ldapsPort $lds --httpsPort $htps ${bootStrapServers} ${installationProfile} --acceptLicense 2>&1 >/dev/null &
                    process_id=$!
                    progressBar2 1 $process_id
                    ((ld++))
                    ((adm++))
                    ((lds++))
                    ((htps++))
                    setupMessage
                done
        fi
  fi      

  if [[ $dsFamily -eq 2 && $dsNum -gt 0 ]]; then     
        #do not add bootstrapServers to ds only servers since there are no RS servers to be installed
        if [[ $rsNum -lt 1 ]]; then 

            for (( i=0; i<$dsNum; i++ ))
                do
                    ${dsAlonePath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentKey $depKey --deploymentKeyPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${dsOnlyHName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld  --enableStartTLS --ldapsPort $lds --httpsPort $htps ${installationProfile} --acceptLicense 2>&1 >/dev/null &
                    process_id=$!
                    progressBar2 1 $process_id
                    ((ld++))
                    ((adm++))
                    ((lds++))
                    ((htps++))
                    setupMessage
                done
        fi
  fi

  #create the rs only servers
  if [[ $dsFamily -eq 2 && $rsNum -gt 0 ]]; then
        for (( i=0; i<$rsNum; i++ ))
                do
                    ${rsAlonePath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentKey $depKey --deploymentKeyPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${rsOnlyHName}${i}${domain} --adminConnectorPort $adm --replicationPort $repp ${bootStrapServers} --acceptLicense 2>&1 >/dev/null &
                    process_id=$!
                    progressBar2 1 $process_id
                    ((adm++))
                    ((rep++))
                    setupMessage
                done
  fi


  #create ds only servers
  if [[ $dsFamily -eq 3 && $dsNum -gt 0 ]]; then
       #add bootstrapServers to ds only servers only when RS servers to be installed
       if [[ $rsNum -gt 0 ]]; then 
            for (( i=0; i<$dsNum; i++ ))
                do
                    ${dsAlonePath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentId $depKey --deploymentIdPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${dsOnlyHName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld --enableStartTLS --ldapsPort $lds --httpsPort $htps ${bootStrapServers} ${installationProfile} --acceptLicense 2>&1 >/dev/null &
                    process_id=$!
                    progressBar2 1 $process_id
                    ((ld++))
                    ((adm++))
                    ((lds++))
                    ((htps++))
                    setupMessage
                done
       fi
  fi
  
  if [[ $dsFamily -eq 3 && $dsNum -gt 0 ]]; then
        #do not add bootstrapServers to ds only servers since there are no RS servers to be installed
        if [[ $rsNum -lt 1 ]]; then
            for (( i=0; i<$dsNum; i++ ))
                do
                    ${dsAlonePath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentId $depKey --deploymentIdPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${dsOnlyHName}${i}${domain} --adminConnectorPort $adm --ldapPort $ld --enableStartTLS --ldapsPort $lds --httpsPort $htps ${installationProfile} --acceptLicense 2>&1 >/dev/null &
                    process_id=$!
                    progressBar2 1 $process_id
                    ((ld++))
                    ((adm++))
                    ((lds++))
                    ((htps++))
                    setupMessage
                done
       fi
  fi

  #create the RS servers
  if [[ $dsFamily -eq 3 && $rsNum -gt 0 ]]; then 
        for (( i=0; i<$rsNum; i++ ))
            do
                ${rsAlonePath}${i}/opendj/./setup --serverId ${srvID}${i} --deploymentId $depKey --deploymentIdPassword $installationPassword --rootUserDN uid=admin --rootUserPassword $installationPassword --monitorUserPassword $installationPassword --hostName ${rsOnlyHName}${i}${domain} --adminConnectorPort $adm --replicationPort ${rep} ${bootStrapServers} ${installationProfile} --acceptLicense 2>&1 >/dev/null &
                process_id=$!
                progressBar2 1 $process_id
                ((adm++))
                ((rep++))
                setupMessage
            done
  fi

  startServersStandAlone

  if [ $dsNum -gt 1 ];then
    printf "starting replication initialisation please wait..\n"
    sleep 10
    selectedDN $dsProfile

    $firstDSbinPath./dsrepl initialize --baseDN $bDN --toAllServers --hostname $dsOnlyHName${num}$domain --port $admPort --bindDN "uid=admin" --bindPassword $installationPassword --trustStorePath $firstDSpath/config/keystore --trustStorePasswordFile $firstDSpath/config/keystore.pin --no-prompt
    printf "Replication initialisation started..\n\n"
  fi
}


execute656xSetup()
{ 
  ldd=$1
  ldss=$2
  admm=$3
  htp=$4
  htps=$5
  sID=$6
  rPort=$7
  
  local firstSrv=0
  local num=0
  local j=0
  local adm=$admm
  local repPort=$rPort
  local noSrv=$noOfServers

  printf "executing DS ./setup command for DS 6.5.x..\n"

  selectedDN $dsProfile

  # If number of servers is 1 then the script should abort installation and warn that 2 or more servers needed otherwise install stand alone servers
  # DONE

  #install 65x servers
  for (( i=0; i<$noOfServers; i++ ))
    do
        $destPath${i}/opendj/./setup directory-server --rootUserDN 'cn=Directory Manager' --rootUserPassword ${installationPassword} --monitorUserPassword ${installationPassword} --hostName ${hostName}${i}${domain} --ldapPort ${ldd} --enableStartTLS --ldapsPort ${ldss} --httpPort ${htp} --httpsPort ${htps} --adminConnectorPort ${adm} ${installationProfile} --acceptLicense 2>&1 >/dev/null &
        process_id=$!
        progressBar2 1 $process_id
        ((adm++))
        ((ldd++))
        ((ldss++))
        ((htp++))
        ((htps++))
        setupMessage
    done

  #startServers $noOfServers $destPath
  printf "\n Preparing server IDs replication configuration and replication..\n"
  #create server ID for each server
  adm=$admm
  for (( i=0; i<$noOfServers; i++ ))
        do
             $destPath${i}/opendj/bin/./dsconfig set-global-configuration-prop --hostName ${hostName}${i}${domain} --port ${adm} --bindDN 'cn=Directory Manager' --bindPassword ${installationPassword} --set server-id:${sID} --trustAll --no-prompt 2>&1 >/dev/null &
             process_id=$!
             wait $process_id
             ((sID++))
             ((adm++))
        done  

  #configure the replication
  adm=$admm
  ((noSrv--))
  for (( i=0; i<$noSrv; i++ ))
        do
            ((j++))
            ((adm++))
            ((repPort++))
            ${destPath}${firstSrv}/opendj/bin/./dsreplication configure --adminUID admin --adminPassword ${installationPassword} --baseDN ${bDN} --host1 ${hostName}${firstSrv}${domain} --port1 ${admPort} --bindDN1 'cn=Directory Manager' --bindPassword1 ${installationPassword} --replicationPort1 ${replPort} --host2 ${hostName}${j}${domain} --port2 ${adm} --bindDN2 'cn=Directory Manager' --bindPassword2 ${installationPassword} --replicationPort2 ${repPort} --trustAll --no-prompt 2>&1 >/dev/null &
            process_id=$!
            wait $process_id
        done 


  #initialise the replication
  j=0
  adm=$admm
  for (( i=0; i<$noSrv; i++ ))
        do
            ((j++))
            ((adm++))
            ${destPath}${firstSrv}/opendj/bin/./dsreplication initialize --adminUID admin --adminPassword ${installationPassword} --baseDN ${bDN} --hostSource ${hostName}${firstSrv}${domain} --portSource ${admPort} --hostDestination ${hostName}${j}${domain} --portDestination ${adm} --trustAll --no-prompt
            process_id=$!
            wait $process_id
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

printf "                            Universal topology Creator\n"
printf "************************************************************************************\n"
printf "************************************************************************************\n"
printf "Creation of hostnames by category:\n"
printf "DS-RS servers: dsrs1.example.com, dsrs2.example.com\n"
printf "DS only servers: dsOnly1.example.com, dsOnly2.example.com\n"
printf "RS only servers: rsOnly1.example.com, rsOnly2.example.com\n"
printf "Default installation directory: $destPath\n"
printf "Default installation password: $installationPassword\n"
printf "Default serverID: ${srvID}x\n"
printf "Default ports: ldap:${ldPort}, ldaps:${ldsPort}, http:${hPort}, https:${hsPort}, replication:${replPort}, admin:${admPort}\n"
printf "************************************************************************************\n"
printf "************************************************************************************\n"
printf "                            Please select DS family\n"
printf "************************************************************************************\n"
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

  while [[ $dsFamily -eq 1 && $dsVersion -gt 6 && $noOfServers -lt 2 ]]
  do
     printf "You need to choose more than 1 servers to be part of ds 6.5.x replication\n"
     printf "otherwise select 2. Stand Alone DS RS servers\n"
     read noOfServers
  done

fi


# Installation of normal DS/RS servers at version DS 7x
# 
printf "\n Installation of normal DS/RS servers at version DS 7x \n"
if [[ $dsFamily -gt 1 ]]; then

    # Call function to check the product ds Family and Version
    #
    selectedFamilyVersion $dsFamily $dsVersion

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
    for j in $ldPort $ldsPort $hsPort $replPort $admPort
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
        createDepKey2 $binPath $setupPath
    fi

    if [[ $dsFamily -eq 3 ]];then
        createDepKey $binPath $setupPath
    fi

    # Insert hostNames into /etc/hosts file
    #
    insertHostNames $hostName $noOfServers

    # Call function to create installation text
    #
    installationText $ldPort $ldsPort $admPort $replPort $hsPort

    # Call function to execute installation of DS/RS 7.x family
    #
    execute7xSetup $ldPort $ldsPort $admPort $replPort $hsPort

    # Execute status command
    #
    exStatusCommand $binPath $hostName $destPath

    # Create start stop command for all servers
    #
    createStartStop

    # End of installation message
    #
    endOfInstallation

fi


#Installation of stand alone Ds and RS servers
#
printf "\n Installation of stand alone Ds and RS servers \n"
if [[ $typeOfInstallation -eq 1 && $standAlone -eq 2 ]]; then
    # Call function to check the product ds Family and Version
    #
    selectedFamilyVersion $dsFamily $dsVersion
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

        for j in $ldPort $ldsPort $hsPort $admPort
        do
            printf "Checking protocol port: $j\n"
            checkPorts $j $dsNumber
        done
    fi

    if [[ rsNumber -gt 0 ]]; then   
        ldapP=$((ldPort + dsNumber))
        ldapsP=$((ldsPort + dsNumber))
        httpsP=$((hsPort + dsNumber))
        adminP=$((admPort + dsNumber))
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
    if [[ $dsFamily -eq 2 ]]; then
        if [[ dsNumber -gt 0 ]]; then    
            createDepKey2 $firstDSbinPath $firstDSpath
        else
            createDepKey2 $firstRSbinPath $firstRSpath
        fi    
    fi

    if [[ $dsFamily -eq 3 ]]; then
        if [[ dsNumber -gt 0 ]]; then    
            createDepKey $firstDSbinPath $firstDSpath
        else
            createDepKey $firstRSbinPath $firstRSpath
        fi
    fi

    # Insert hostNames into /etc/hosts file
    #
    if [[ dsNumber -gt 0 ]]; then
        insertHostNames $dsOnlyHostName $dsNumber
    fi

    if [[ rsNumber -gt 0 ]]; then
        insertHostNames $rsOnlyHostName $rsNumber
    fi

    # Call function to create installation text for ds rs only servers
    #
    installationText2 $ldPort $ldsPort $admPort $replPort $hsPort $dsNumber $rsNumber $dsOnlyHostName $rsOnlyHostName


    # Call function to excute installation for stand alone ds rs only servers
    #
    executeStandAlone7xSetup $ldPort $ldsPort $admPort $replPort $hsPort $dsNumber $rsNumber $dsOnlyHostName $rsOnlyHostName

    
    # Execute status command
    #
    if [[ dsNumber -gt 0 ]];then
        exStatusCommand $firstDSbinPath $dsOnlyHostName $dsAlonePath
    fi

    # Create start stop command for all servers
    #
    #createStartStop
    #currently left this out

    # End of installation message
    #
    endOfInstallation
fi


# Installation of normal DS/RS servers at version DS 6.5.x
# 
printf "\n Installation of normal DS/RS servers at version DS 6.5.x \n"
if [[ $dsFamily -eq 1 && dsVersion -gt 6 ]]; then

    # Call function to check the product ds Family and Version and get in return the selected ds version
    #
    selectedFamilyVersion $dsFamily $dsVersion

    # Call function to select profile and get in return the selected profile for the installation to be used
    # available from ds version ds 6.5.x and on
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
    for j in $ldPort $ldsPort $hPort $hsPort $replPort $admPort
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

    # Insert hostNames into /etc/hosts file
    #
    #insertHostNames $hostName $noOfServers

    # Call function to create installation text
    #
    installation65xText $ldPort $ldsPort $admPort $hPort $hsPort $numericServerID $replPort
    process_id=$!
    wait $process_id
    # Call function to execute installation of DS/RS 6.5.x family
    #
    execute656xSetup $ldPort $ldsPort $admPort $hPort $hsPort $numericServerID $replPort

    # Execute status command
    #
    replicationStatus65x $binPath $hostName

    # Create start stop command for all servers
    #
    createStartStop

    # End of installation message
    #
    endOfInstallation
fi





#END
