package require sqlite3

namespace eval ::Sudet:: {
	namespace export {dbInnit dbSync insertTag removeTag getTags getAllTags getOcurence}
}

proc ::Sudet::dbConnect {} {

	set req_dbInnit {CREATE TABLE fichiers (
	fichier text NOT NULL UNIQUE,
	date date,
	mode text
	);

	CREATE TABLE parametres (
	fichier text NOT NULL,
	parametre text NOT NULL,
	valeur, text NOT NULL,
	CONSTRAINT unicite UNIQUE (fichier, parametre)
	);
	req_dbInnit 
	CREATE TABLE etiquettes (
	fichier text NOT NULL, 
	etiquette text NOT NULL,
	CONSTRAINT unicite UNIQUE (fichier, etiquette)
	);

	CREATE VIEW untagged AS 
	SELECT DISTINCT fichiers.fichier FROM fichiers 
	LEFT OUTER JOIN etiquettes USING(fichier) 
	WHERE etiquettes.fichier IS NULL;

	CREATE VIEW somaire AS 
	SELECT etiquette AS Étiquette, count(fichier) AS Nombre 
	FROM etiquettes 
	GROUP BY etiquette 
	ORDER BY count(fichier) DESC;}

	if {[file exist ./db.sqlite]} {
		sqlite3 db ./db.sqlite	
	} else {
		sqlite3 db ./db.sqlite	
		db eval $req_dbInnit
	}
}

proc ::Sudet::dbSync {} {
	set filelist [glob -nocomplain *.txt]
	foreach f $filelist {
		db eval [format "INSERT INTO fichiers	(fichier) VALUES (\"%s\")" $f]
	}
}

proc ::Sudet::insertTag {filename tag} {
	db eval "INSERT INTO etiquettes VALUES (\"$filename\", \"$tag\")"
}

proc ::Sudet::removeTag {filename tag} {
	db eval "DELETE FROM etiquettes where fichier=\"$filename\" AND etiquette=\"$tag\""
}

proc ::Sudet::getTags {f} {
	return [db eval "SELECT etiquette FROM etiquettes WHERE fichier=\"$f\""]
}

proc ::Sudet::getAllTags {} {
	return [db eval "SELECT DISTINCT etiquette FROM etiquettes"]
}

proc ::Sudet::getOcurence {etiquette} {
	set query "SELECT Nombre FROM somaire WHERE Étiquette=\"$etiquette\"" 
	return [lindex [db eval $query] 0]
}

