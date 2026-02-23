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

CREATE OR REPLACE TRIGGER InsertCategorie
BEFORE INSERT ON Categories FOR EACH ROW
DECLARE 
    v_categorie NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_categorie FROM Categories WHERE categorie = :NEW.categorie;
    IF v_categorie != 0 THEN 
        RAISE_APPLICATION_ERROR(-20001,'La categorie existe déjà');
    END IF;

    :NEW.numCat := num_categorie_sequence.NEXTVAL;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/

CREATE OR REPLACE NONEDITIONABLE TRIGGER InsertionLocation
BEFORE INSERT ON Location FOR EACH ROW
DECLARE 
        v_nbjours formules.nbJours%TYPE;
        v_situation vehicule.situation%TYPE;
        v_tarif tarifs.tarif%TYPE;
BEGIN
    SELECT situation INTO v_situation FROM Vehicule WHERE numVEH = :NEW.numVeh;
    SELECT nbJours INTO v_nbjours FROM Formules WHERE  formule = :NEW.formule;
    SELECT T.tarif INTO v_tarif
    FROM tarifs T
    JOIN Modeles M ON T.numcat = M.numcat
    JOIN Vehicule V ON M.modele = V.modele
    WHERE V.numVeh = :NEW.numVeh AND T.formule = :NEW.formule;

    IF v_situation != 'disponible' THEN
        RAISE_APPLICATION_ERROR(-20001, 'L vehicule n''est pas disponible pour la location');
    END IF;

    :NEW.dateRetour := v_nbJours + :NEW.dateDepart;

    :NEW.numLoc := 'L-'|| num_location_sequence.NEXTVAL;

    :NEW.montant := v_tarif;

    :NEW.kmLoc := 0;

    UPDATE Vehicule
    SET situation  = 'location'
    WHERE numVeh = :NEW.numVeh;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002,'Erreur : Aucune donnée trouvées');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/

CREATE OR REPLACE NONEDITIONABLE TRIGGER insertionVehicule
BEFORE INSERT ON Vehicule FOR EACH ROW
DECLARE
    v_modele NUMBER;
BEGIN
    

    :NEW.numVeh := num_vehicule_sequence.NEXTVAL;
    :NEW.situation := 'disponible';
    :NEW.NbJoursLoc := 0;
    :NEW.CAV := 0;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/

CREATE OR REPLACE NONEDITIONABLE TRIGGER SuppressionLocation
BEFORE DELETE ON LOCATION FOR EACH ROW
BEGIN
    IF :OLD.KmLoc != 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'L’annulation ne concerne que les locations dont KmLoc est égal à 0');
    END IF;
    UPDATE Vehicule
    SET situation  = 'disponible'
    WHERE numVeh = :OLD.numVeh;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/

CREATE OR REPLACE TRIGGER UpdateLocation
BEFORE UPDATE ON LOCATION FOR EACH ROW
DECLARE
    v_km NUMBER;
    c_prixkm  NUMBER;
    f_forfaitkm NUMBER;
BEGIN
    IF :NEW.Numloc!= :OLD.Numloc OR :NEW.Numveh != :OLD.Numveh OR :NEW.Formule != :OLD.Formule OR :NEW.DateDepart != :OLD.DateDepart OR :NEW.Montant != :OLD.Montant THEN
        RAISE_APPLICATION_ERROR(-20001,'La modification ne concerne que KmLoc et DateRetour');
    END IF;
    IF :NEW.DateRetour < :OLD.DateRetour THEN
        RAISE_APPLICATION_ERROR(-20002, 'Attention : la date de retour a été dépassée pour le véhicule : '||:OLD.Numveh);
    END IF;
    
    SELECT prixkm INTO c_prixkm 
    FROM Vehicule V
    JOIN Modeles M ON V.modele = M.modele
    JOIN Categories C ON C.Numcat = M.Numcat
    WHERE V.Numveh = :NEW.Numveh;
    
    SELECT forfaitkm INTO f_forfaitkm
    FROM Formules
    WHERE formule = :NEW.formule;
    
    :NEW.Montant := GREATEST(0,:New.KmLoc - f_forfaitkm) * c_prixkm;
    
    UPDATE Vehicule
    SET 
    km = km + :NEW.Kmloc,
    Nbjoursloc = Nbjoursloc + :New.DateRetour - :New.DateDepart + 1,
    CAV = CAV + :NEW.Montant
    WHERE Numveh = :NEW.Numveh;
    
    SELECT km INTO v_km FROM Vehicule WHERE Numveh = :NEW.Numveh;
    
    IF v_km > 50000 THEN
        UPDATE Vehicule
        SET situation = 'retraite'
        WHERE Numveh = :NEW.Numveh;
        INSERT INTO VehiculeRetraite(numveh,dateRetraite)
        VALUES(:NEW.numveh,:NEW.DateRetour);
        DBMS_OUTPUT.PUT_LINE('Le vehicule numero : '||:NEW.Numveh||'a pris sa retraite');
    ELSE
        UPDATE Vehicule
        SET situation = 'disponible'
        WHERE Numveh = :NEW.Numveh;
    END IF;    
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Pas de données trouvées');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
/