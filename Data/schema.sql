CREATE TABLE fichiers (
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
CREATE TABLE etiquettes (
	fichier text NOT NULL, 
	etiquette text NOT NULL,
	CONSTRAINT unicite UNIQUE (fichier, etiquette)
	);
CREATE VIEW untagged AS 
	SELECT DISTINCT fichiers.fichier FROM fichiers 
	LEFT OUTER JOIN etiquettes USING(fichier) 
	WHERE etiquettes.fichier IS NULL
/* untagged(fichier) */;
CREATE VIEW somaire AS 
	SELECT etiquette AS Étiquette, count(fichier) AS Nombre 
	FROM etiquettes 
	GROUP BY etiquette 
	ORDER BY count(fichier) DESC
/* somaire("Étiquette",Nombre) */;
