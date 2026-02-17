-- On supprime les tables si elles existent déjà --
DROP TABLE Vehicule CASCADE CONSTRAINTS;
DROP TABLE VehiculeRetraite CASCADE CONSTRAINTS;
DROP TABLE Modeles CASCADE CONSTRAINTS;
DROP TABLE Categories CASCADE CONSTRAINTS;
DROP TABLE Formules CASCADE CONSTRAINTS;
DROP TABLE Tarifs CASCADE CONSTRAINTS;
DROP TABLE Location CASCADE CONSTRAINTS;

DROP SEQUENCE num_vehicule_sequence;
DROP SEQUENCE num_location_sequence;
DROP SEQUENCE num_categorie_sequence;


-- Creation des Séquences pour numVeh et numLoc --
CREATE SEQUENCE num_vehicule_sequence
    START WITH 1
    INCREMENT BY 1;
    
CREATE SEQUENCE num_location_sequence
    START WITH 1
    INCREMENT BY 1;
    
CREATE SEQUENCE num_categorie_sequence
    START WITH 1
    INCREMENT BY 1;

-- Creation de la table categories --  
CREATE TABLE Categories (
            numCat NUMBER(9) PRIMARY KEY,
            categorie VARCHAR2(20) NOT NULL,
            prixKm NUMBER(9) NOT NULL CHECK ( prixkm>0 )
);
-- Creation de la table modeles --

CREATE TABLE Modeles(
            modele VARCHAR2(20) PRIMARY KEY NOT NULL,
            marque VARCHAR2(20) NOT NULL,
            numCat NUMBER(9) REFERENCES Categories(numCat) NOT NULL
);
            
        
-- Creation de la table formules --            
            
CREATE TABLE Formules(
            formule VARCHAR2(20) PRIMARY KEY NOT NULL,
            nbJours NUMBER(9) NOT NULL CHECK ( nbJours >=0 ),
            forfaitKm NUMBER(9) NOT NULL CHECK (forfaitKm >= 0)
);


            
-- Creation de la table vehicule --

CREATE TABLE Vehicule( 
            numVeh NUMBER(9) PRIMARY KEY,
            modele VARCHAR2(20) REFERENCES Modeles(modele) NOT NULL,
            km NUMBER(9) NOT NULL CHECK (km >= 0),
            situation VARCHAR2(20) CHECK (situation in ('disponible','location','retraite')) NOT NULL,
            nbJoursLoc NUMBER(9) DEFAULT 0 NOT NULL,
            CAV NUMBER(9)  DEFAULT 0 CHECK (CAV >= 0) NOT NULL 
);

-- Creation de la table vehicule retraite --

CREATE TABLE VehiculeRetraite(
            numVeh NUMBER(9) Primary Key REFERENCES Vehicule(numVeh),
            dateRetraite DATE NOT NULL
);
            



-- Creation de la table tarifs --

CREATE TABLE Tarifs(
            numCat NUMBER(9)  REFERENCES Categories(numCat) NOT NULL,
            formule VARCHAR2(20)  REFERENCES Formules(formule) NOT NULL,
            tarif NUMBER(9) CHECK (tarif >= 0) NOT NULL,
            PRIMARY KEY(numCat,formule)   -- C'est 2 cles primaire
            );
 



-- Creation de la table location --

CREATE TABLE Location(
            numLoc VARCHAR2(20) PRIMARY KEY,
            numVeh NUMBER REFERENCES Vehicule(numVeh)NOT NULL ,
            formule VARCHAR2(20) NOT NULL REFERENCES Formules(formule),
            dateDepart DATE NOT NULL,
            dateRetour DATE,
            kmLoc NUMBER CHECK (kmLoc >= 0),
            montant NUMBER CHECK (montant is NULL OR montant >= 0),
            CHECK (dateRetour is NULL OR dateRetour >= dateDepart)
);