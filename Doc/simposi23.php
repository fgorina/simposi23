<?php
// cridat així: https://seguridadwebsimpo.pagaia.club/wp-content/QR_Prova_01.php?Accio=101&PartId=747
// On Accio indica el qué s'està demanat. Per exemple 010 = Ha arrivat; 011 ha recollit obsequi; 020 Esmorzar 1er dia
// On PartId es l'identificador del participant. Un numero sequencial i ùnic que genera el gravity Forms



// VALIDACIO ENTRADA. 

function valida($params, $secret, $alg){
	
	
	$keys = array_keys($params);
	sort($keys);
	
	$body = "";
	foreach($keys as $key){

		if($key != "hash"){
			$body = $body . $params[$key];
			}	
		}


	$myhash = hash($alg, $body . $secret);
		
	return ($myhash ==  $params["hash"]);
}

function buildAnswer($op, $data, $status, $alg, $secret){

	$t = (string)microtime(true);  // Es podria fer servir time()
	$answer = $t . "\n" . $status . "\n". $op . "\n" . $data;
	$hash = hash($alg , $answer . $secret);
	return  $hash . "\n" . $answer;

}

// Formata en format csv el resultat de un query

function formatResults($result){

	$data = "";
	while(($row = $result->fetch_row()) != null){
		
			$flag = false;
			foreach ($row as $field){
				if ($flag){
					$data = $data . ";";
				}else{
					$flag = true;
				}
				$data = $data . $field;		
			}
			$data = $data .  "\n";
		
		}
		
		return $data;
		
}

function arrayToString($a){

	$data = "";
	$l = count($a);
	
	for($i = 0; $i < $l; $i++){
		$flag = false;
			foreach ($a[$i] as $field){
				if ($flag){
					$data = $data . ";";
				}else{
					$flag = true;
				}
				$data = $data . $field;		
			}
			$data = $data .  "\n";
	
	}
	
	return $data;
}

// FUNCIONS 

// participants. Retorna la llista dels participants

function queryTable($table, $id, $mysqli){

	$tableNames = [];
	$tableNames["participants"] = "wpdj_pagaia_qr_sympo2023";
	$tableNames["serveis"] = "wpdj_pagaia_qr_sympo2023_serveis";
	$tableNames["productes"] = "wpdj_pagaia_qr_sympo2023_productes";
	$tableNames["compres"] = "wpdj_pagaia_qr_sympo2023_compres";
	$tableNames["modalitats"] = "wpdj_pagaia_qr_sympo2023_modalitats";
	$tableNames["estats"] = "wpdj_pagaia_qr_sympo2023_estatss";

	$databaseTable = $tableNames[$table];
	
	if($databaseTable == null){
		return ["ERROR", "Taula no existent\n"];
	}
	
	$data = "";
	
	if($id != ""){
		$query = "select * from " . $databaseTable . " where id = ".$id;
	}else{
		$query = "select * from " . $databaseTable . " order by id";
	}
	
	$result = $mysqli->query($query);
	
	
	if($result != false){
		$data = formatResults($result);	
		return ["OK", $data];
	} else {
		$data = $mysqli->error;
		return ["ERROR", $data];
	}


}

function registrar($id, $mysqli){

	$query = "select * from wpdj_pagaia_qr_sympo2023 where id = ". $id;
	$result = $mysqli->query($query);
	
	
	$a = $result->fetch_all();
	if(count($a) != 1){
		return ["ERROR", "No hi ha un únic participant amb id {$id}"];
	}

	$v = $a[0];
	
	if($v[3] == 0){
		$query = "update wpdj_pagaia_qr_sympo2023 set m_arribat = 1 where id = " . $id;
		$mysqli->query($query);
	}
	
	
	$query = "select * from wpdj_pagaia_qr_sympo2023 where id = ". $id;
	$result = $mysqli->query($query);
	
	$data = formatResults($result);	
	
	return ["OK", $data];

}

function consumir($idParticipant, $idServei, $mysqli){

	$query = "select * from wpdj_pagaia_qr_sympo2023 where id = ". $idParticipant;
	$result = $mysqli->query($query);
	$a = $result->fetch_all();
	if(count($a) != 1){
		return ["ERROR", "No hi ha un únic participant amb id {$idParticipant}\n"];
	}
	$participant = $a[0];
	$data = arrayToString($a);
	
	$query = "select field, descripcio from wpdj_pagaia_qr_sympo2023_serveis where id = " . $idServei;
	$results = $mysqli->query($query);
	$s = $results->fetch_all();
	if(count($s) != 1){
		return ["ERROR", "No hi ha un servei amb la id  {$idServei}\n{$data}"];
	}

	$field = $s[0][0];

	// Now check if it is ok consumir
	
	
	
	$estat = $participant[$idServei + 3];
	$registrat = $participant[3];
	
	if($estat  == 1 && $registrat == 1){		// If registrat and pagat
	
		$query = "update wpdj_pagaia_qr_sympo2023 set  {$field} = 2 where id = " . $idParticipant;
		$mysqli->query($query);
	}
	
	$query = "select * from wpdj_pagaia_qr_sympo2023 where id = ". $idParticipant;
	$result = $mysqli->query($query);
	
	$data = formatResults($result);	

	// Return data according to original estat
	
	if($registrat != 1){
		return ["ERRORR", "{$participant[1]} encara no s'ha registrat.\n{$data}"];	
	}  else {
		if ($estat == 1){
			return ["OK", $data];
		}else if($estat == 0){
			return ["ERRORP", "{$participant[1]}  no ha pagat el servei {$s[0][1]}\n{$data}"];	
		}  
		else if ($estat == 2){
			return ["ERROR", "{$participant[1]}  ja ha consumit el servei {$s[0][1]}\n{$data}"];
		}else {
			return ["ERROR", "{$participant[1]}  te un estat desconegut \n{$data}"];
		}
	}

}

function comprar($idParticipant, $idProducte, $terminal, $mysqli){

	$query = "select * from wpdj_pagaia_qr_sympo2023 where id = ". $idParticipant;
	$result = $mysqli->query($query);
	$a = $result->fetch_all();
	if(count($a) != 1){
		return ["ERROR", "No hi ha un únic participant amb id {$idParticipant}\n"];
	}
	$participant = $a[0];
	$data = arrayToString($a);
	
	$query = "select descripcio, preu from wpdj_pagaia_qr_sympo2023_productes where id = " . $idProducte;
	$results = $mysqli->query($query);
	$s = $results->fetch_all();
	if(count($s) != 1){
		return ["ERROR", "No hi ha un producte amb la id  {$idProducte}\n{$data}"];
	}

	$descripcio = $s[0][0];
	$preu = $s[0][1];
	
	// Now get serveis associats
	$query = "select s.field from  wpdj_pagaia_qr_sympo2023_serveis  s where s.id_producte = " . $idProducte . 
		" order by field";
	$resultss = $mysqli->query($query);
	$fields = $resultss->fetch_all();

	
	$registrat = $participant[3];
	$id = $idParticipant * 100 + $idProducte;
	
	if($registrat == 1){
	
	// Primer hem de comprovar que no hem comprat ja això (o no?)
	
		$query = "select id from wpdj_pagaia_qr_sympo2023_compres where id = " . $id;
		$resultss = $mysqli->query($query);
		$jacomprat = $resultss->fetch_all();
		
		if (count($jacomprat) > 0){
			return ["ERROR", "El producte {$descripcio} ja s'ha comprat per {$participant[1]}\n{$data}"];
		}
	
		// Insert una nova compra. 
	
		$query = "insert into wpdj_pagaia_qr_sympo2023_compres ( id, data, id_participant, id_producte, terminal ) values " .
		"({$id}, now(), {$idParticipant}, {$idProducte}, {$terminal})";

	
		$mysqli->query($query);
	 

		// Now update participant amb la nova compra	
		$query = "update wpdj_pagaia_qr_sympo2023 set   ";
	
		for ($il = 0; $il < count($fields); $il++){
			if($il != 0){
				$query = $query . ", ";
			}
	
			$query = $query . $fields[$il][0]  . " = greatest(1,  " . $fields[$il][0] . ") ";
		}
		
	
		$query = $query . " where  id = " . $idParticipant;
	
		$mysqli->query($query);

	}

	// Return new data!!!

	
	$query = "select * from wpdj_pagaia_qr_sympo2023 where id = ". $idParticipant;
	$result = $mysqli->query($query);
	
	$data = formatResults($result);	

	// Return data according to original estat
	
	if($registrat != 1){
		return ["ERRORR", "{$participant[1]} encara no s'ha registrat.\n{$data}"];	
	}  else {

		return ["OK", $data];
		
	}

}


// A aquesta funció gestionem les operacions. Canviar per el cas real.

function gestionaOp($op, $id, $terminal, $mysqli){

	switch($op){
		case "registrar":
			if($id != ""){
				list($status, $data) = registrar($id, $mysqli);
			}else{
				$status = "ERROR";
				$data = "Es obligatoria la Id per registrar-se";
			}
			break;
			
			
		case "consumir":
			if($id != ""){		
				$idParticipant = floor($id / 100);
				$idServei = $id % 100;
				
				list($status, $data) = consumir($idParticipant, $idServei,  $mysqli);
			}else{
				$status = "ERROR";
				$data = "Es obligatori especificar que consumim";
			}
		break;
		
		case "comprar" :
			if($id != ""){		
				$idParticipant = floor($id / 100);
				$idProducte = $id % 100;
			 
				
				list($status, $data) = comprar($idParticipant, $idProducte,  $terminal, $mysqli);
			}else{
				$status = "ERROR";
				$data = "Es obligatori especificar que consumim";
			}
		break;
		
		default:
			
			list($status, $data) = queryTable($op, $id, $mysqli);
			break;
		

	}

	return[$status, $data];

}
header("Access-Control-Allow-Origin: *" );
header("Access-Control-Allow-Methods: GET");

// Main function. No s'ha de tocar
$db_host = 'localhost';
$db_user = 'fgorina';
$db_password = 'axz93klm';
$db_db = 'simposi23';
$db_port = 8889;

$secret = "asdjadskfjdaslkfj";
$alg = "md5";

$theop=$_GET['op'];
$theid=$_GET['id'];
$terminal = $_GET['terminal'];



if(valida($_GET, $secret, $alg)){

	$mysqli = new mysqli($db_host, $db_user, $db_password, $db_db);
	
	if($mysqli->connect_error){
		echo buildAnswer($theop, mysqli_connect_error(), 'ERROR', $alg, $secret);
		exit();
	}

	list($status, $data) = gestionaOp($theop, $theid, $terminal,  $mysqli);
	echo buildAnswer($theop, $data, $status, $alg, $secret);
	$mysqli->close();
		
}else{
	echo "IR" ;
	exit();
}
?>