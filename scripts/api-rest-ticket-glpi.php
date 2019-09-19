<?php

ini_set('display_errors', 'On');
error_reporting(E_ALL | E_STRICT);
var_dump(function_exists('curl_version'));

# Adresse pour accéder à l'API de GLPI : ici par Varnish qui expose sur localhost sur le port 8080
# Nécessite d'activer l'API dans GLPI et autoriser l'IP du client
# pour le savoir curl sur url 
#$api_url="http://127.0.0.1:8080/apirest.php";
$api_url="http://192.168.158.129:8080/apirest.php";
# NB il faut prendre "API Token" d'un user  via Administration > Utilisateurs > UserXX > Clé Acces distant
# ATTENTION NE PAS UTILISER : Jeton Personnel mais API Token
$usertoken="9Mb867u5FSF6UWULpSb0OzlKgeRjQcotzXvm6woX";

echo "=========================================";
echo "\n      GLPI API DEMONSTRATION \n";
echo "=========================================";

if ( $argc != 3) {
	echo "\n ERREUR ! \n";
	echo "\n Ecriture d'un Ticket GLPI via API";
	echo "\n USAGE : $argv[0] <Titre> <Description> \n ";
	exit(2);
}

###
### 1 - Init
###

echo "\n [+] API GLPI : Session Initializing \n";

echo ("\n   User Token  ===> " . $usertoken);

# Les Headers de la requete contenant le token
$headers = array(
('Content-Type: application/json'),
('Authorization: user_token ' . $usertoken)
);

$initurl=$api_url."/initSession/";
echo ("\n   Init Url ===> " . $initurl);

$ch  = curl_init();
curl_setopt($ch, CURLOPT_URL, $initurl);
curl_setopt($ch, CURLOPT_POST, 0);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_VERBOSE, true);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$request_result = curl_exec($ch);
echo $request_result;

curl_close($ch);
$obj = json_decode($request_result,true);
print_r ($obj);
$session_token="";
$session_token=$obj['session_token'];

if ($session_token == ""){
 echo "\n\n FATAL ! erreur de recuperation du token de session\n";
 exit(2);
}

echo ("\n   [+] SESSION TOKEN ===> " . $session_token);

###
### 2- Creation Ticket
###


echo "\n [+] API GLPI : TICKET CREATION \n";

$titre =  htmlentities($argv[1]);
$description =  htmlentities($argv[2]);

$headers = array(
	('Content-Type: application/json'),
	('Session-Token: '.$session_token)
);

$ch = curl_init();
$url=$api_url . "/Ticket/";
   
   
# type : 1 : Incident 
#        2 : Demande
# a traiter dans ticket.class.php
# 'entities_id' , 'urgency', 'priority', 'itilcategories_id', 
$fields='{
	"input": {
		"name": "' .$titre. '","requesttypes_id": "1","content": "'.$description.'","type": "2"
	}
}';

curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
$request_result = curl_exec($ch);

echo ($request_result);
curl_close ($ch);
$obj = json_decode($request_result,true);

?>
