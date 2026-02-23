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
