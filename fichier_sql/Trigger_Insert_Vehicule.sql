create or replace NONEDITIONABLE TRIGGER insertionVehicule
BEFORE INSERT ON Vehicule FOR EACH ROW
DECLARE
    v_modele NUMBER;
BEGIN
    IF :NEW.modele IS NULL OR :NEW.Km IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Les parametre ne doit pas etre null');
    END IF;
    IF :NEW.NumVeh IS NOT NULL OR :NEW.Situation IS NOT NULL OR :NEW.NbJoursLoc IS NOT NULL OR :NEW.CAV IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20002, 'Tu peux pas donner Numveg, Situation, NbJoursLoc et CAV, ils sont declarer auto');
    END IF;
    SELECT COUNT(*) INTO v_modele FROM MODELES WHERE modele = :NEW.modele;
    IF v_modele = 0 THEN
         RAISE_APPLICATION_ERROR(-20003, 'Le Modele n''existe pas');
    END IF;

    :NEW.numVeh := num_vehicule_sequence.NEXTVAL;
    :NEW.situation := 'disponible';
    :NEW.NbJoursLoc := 0;
    :NEW.CAV := 0;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Erreur Oracle : ' || SQLCODE || ' ; Message Oracle : ' || SQLERRM);
END;
