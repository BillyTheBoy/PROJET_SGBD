create or replace NONEDITIONABLE TRIGGER insertionVehicule
BEFORE INSERT ON Vehicule FOR EACH ROW
DECLARE
    v_modele NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_modele FROM MODELES WHERE modele = :NEW.modele;
    IF v_modele = 0 THEN
         RAISE_APPLICATION_ERROR(-20001, 'Le Modele n''existe pas');
    END IF;

    :NEW.numVeh := num_vehicule_sequence.NEXTVAL;
    :NEW.situation := 'disponible';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
