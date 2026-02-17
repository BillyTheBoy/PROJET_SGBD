create or replace NONEDITIONABLE TRIGGER InsertionLocation
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
